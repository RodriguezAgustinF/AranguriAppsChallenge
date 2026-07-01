begin;

create function public.calculate_prediction_points(
  predicted_home_score integer,
  predicted_away_score integer,
  predicted_penalty_winner_team_id uuid,
  official_home_score integer,
  official_away_score integer,
  official_penalty_winner_team_id uuid,
  home_team_id uuid,
  away_team_id uuid
)
returns integer
language sql
immutable
set search_path = ''
as $$
  select case
    when (
      case
        when predicted_home_score > predicted_away_score then home_team_id
        when predicted_away_score > predicted_home_score then away_team_id
        else predicted_penalty_winner_team_id
      end
    ) is distinct from (
      case
        when official_home_score > official_away_score then home_team_id
        when official_away_score > official_home_score then away_team_id
        else official_penalty_winner_team_id
      end
    ) then 0
    when predicted_home_score = official_home_score
      and predicted_away_score = official_away_score
      and (
        official_home_score <> official_away_score
        or predicted_penalty_winner_team_id = official_penalty_winner_team_id
      ) then 6
    else 3
  end;
$$;

revoke execute on function public.calculate_prediction_points(integer, integer, uuid, integer, integer, uuid, uuid, uuid)
from public, anon, authenticated;

create function public.publish_match_result(
  target_match_id uuid,
  official_home_score integer,
  official_away_score integer,
  official_penalty_winner_team_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  target_tournament_id uuid;
  current_match public.matches%rowtype;
  current_stage_type public.stage_type;
  winning_team_id uuid;
  following_match_id uuid;
  updated_score_count integer := 0;
begin
  if not public.is_admin() then
    raise exception using errcode = '42501', message = 'only administrators can publish match results';
  end if;

  select tournament_id into target_tournament_id
  from public.matches
  where id = target_match_id;

  if target_tournament_id is null then
    raise exception using errcode = 'P0002', message = 'match not found';
  end if;

  perform id from public.tournaments where id = target_tournament_id for update;

  select * into current_match
  from public.matches
  where id = target_match_id
  for update;

  select type into current_stage_type
  from public.stages
  where id = current_match.stage_id;

  if current_match.result_published_at is not null then
    if current_match.home_score = official_home_score
      and current_match.away_score = official_away_score
      and current_match.penalty_winner_team_id is not distinct from official_penalty_winner_team_id
    then
      winning_team_id := case
        when official_home_score > official_away_score then current_match.home_team_id
        when official_away_score > official_home_score then current_match.away_team_id
        else official_penalty_winner_team_id
      end;
      return jsonb_build_object('match_id', target_match_id, 'winner_team_id', winning_team_id, 'already_published', true);
    end if;
    raise exception using errcode = '55000', message = 'a match with an official result is immutable';
  end if;

  if current_match.home_team_id is null or current_match.away_team_id is null then
    raise exception using errcode = '23514', message = 'both match participants must be resolved';
  end if;
  if current_match.starts_at is null or current_match.starts_at > clock_timestamp() then
    raise exception using errcode = '23514', message = 'the match must have started before publishing its result';
  end if;
  if official_home_score is null or official_away_score is null
    or official_home_score < 0 or official_away_score < 0
  then
    raise exception using errcode = '23514', message = 'official scores must be nonnegative integers';
  end if;

  if official_home_score = official_away_score then
    if official_penalty_winner_team_id is null
      or official_penalty_winner_team_id not in (current_match.home_team_id, current_match.away_team_id)
    then
      raise exception using errcode = '23514', message = 'a drawn match requires a participating penalty winner';
    end if;
    winning_team_id := official_penalty_winner_team_id;
  else
    if official_penalty_winner_team_id is not null then
      raise exception using errcode = '23514', message = 'a non-drawn match cannot have a penalty winner';
    end if;
    winning_team_id := case
      when official_home_score > official_away_score then current_match.home_team_id
      else current_match.away_team_id
    end;
  end if;

  update public.matches
  set home_score = official_home_score,
      away_score = official_away_score,
      penalty_winner_team_id = official_penalty_winner_team_id,
      result_published_at = clock_timestamp()
  where id = target_match_id;

  update public.tournament_scores as score
  set points = score.points + awarded.points
  from (
    select prediction.user_id,
      public.calculate_prediction_points(
        prediction.home_score,
        prediction.away_score,
        prediction.penalty_winner_team_id,
        official_home_score,
        official_away_score,
        official_penalty_winner_team_id,
        current_match.home_team_id,
        current_match.away_team_id
      ) as points
    from public.predictions as prediction
    where prediction.match_id = target_match_id
  ) as awarded
  where score.user_id = awarded.user_id
    and score.tournament_id = target_tournament_id;
  get diagnostics updated_score_count = row_count;

  select id into following_match_id
  from public.matches
  where home_source_match_id = target_match_id or away_source_match_id = target_match_id
  for update;

  if current_stage_type <> 'FINAL' and following_match_id is null then
    raise exception using errcode = '23514', message = 'the winning team has no following bracket match';
  end if;

  if following_match_id is not null then
    perform set_config('app.allow_bracket_progression', 'true', true);
    update public.matches
    set home_team_id = case when home_source_match_id = target_match_id then winning_team_id else home_team_id end,
        away_team_id = case when away_source_match_id = target_match_id then winning_team_id else away_team_id end
    where id = following_match_id;
  end if;

  return jsonb_build_object(
    'match_id', target_match_id,
    'winner_team_id', winning_team_id,
    'next_match_id', following_match_id,
    'scores_updated', updated_score_count,
    'already_published', false
  );
end;
$$;

comment on function public.publish_match_result(uuid, integer, integer, uuid) is
  'Atomically publishes an immutable result, updates prediction scores and advances the winner.';

revoke execute on function public.publish_match_result(uuid, integer, integer, uuid) from public, anon;
grant execute on function public.publish_match_result(uuid, integer, integer, uuid) to authenticated;

commit;
