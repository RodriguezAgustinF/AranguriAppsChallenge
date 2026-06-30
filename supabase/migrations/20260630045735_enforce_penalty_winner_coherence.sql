begin;

alter table public.matches
  add constraint matches_penalty_winner_coherent
  check (
    (home_score is null and penalty_winner_team_id is null)
    or (
      home_score is not null
      and away_score is not null
      and (
        (
          home_score = away_score
          and penalty_winner_team_id is not null
          and coalesce(
            penalty_winner_team_id = home_team_id
            or penalty_winner_team_id = away_team_id,
            false
          )
        )
        or (
          home_score <> away_score
          and penalty_winner_team_id is null
        )
      )
    )
  );

alter table public.predictions
  add constraint predictions_penalty_winner_required_on_draw
  check (
    (home_score = away_score and penalty_winner_team_id is not null)
    or (home_score <> away_score and penalty_winner_team_id is null)
  );

create function public.validate_prediction_penalty_winner()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.penalty_winner_team_id is not null
    and not exists (
      select 1
      from public.matches as match
      where match.id = new.match_id
        and new.penalty_winner_team_id in (match.home_team_id, match.away_team_id)
    )
  then
    raise exception using
      errcode = '23514',
      message = 'penalty winner must be a participant of the predicted match',
      constraint = 'predictions_penalty_winner_is_participant';
  end if;

  return new;
end;
$$;

revoke execute on function public.validate_prediction_penalty_winner() from public, anon, authenticated;

create trigger validate_prediction_penalty_winner_before_write
  before insert or update of match_id, penalty_winner_team_id
  on public.predictions
  for each row execute function public.validate_prediction_penalty_winner();

commit;
