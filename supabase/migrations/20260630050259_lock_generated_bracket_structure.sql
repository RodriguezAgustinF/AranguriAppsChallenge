begin;

create function public.protect_tournament_structure_after_bracket()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  target_tournament_id uuid;
begin
  target_tournament_id := case when tg_op = 'DELETE' then old.tournament_id else new.tournament_id end;

  if exists (
    select 1
    from public.tournaments
    where id = target_tournament_id
      and bracket_generated_at is not null
  ) then
    raise exception using
      errcode = '55000',
      message = case tg_table_name
        when 'tournament_teams' then 'tournament enrollments are immutable after bracket generation'
        else 'tournament stages are immutable after bracket generation'
      end;
  end if;

  return case when tg_op = 'DELETE' then old else new end;
end;
$$;

create trigger protect_tournament_teams_after_bracket
  before insert or update or delete on public.tournament_teams
  for each row execute function public.protect_tournament_structure_after_bracket();

create trigger protect_stages_after_bracket
  before insert or update or delete on public.stages
  for each row execute function public.protect_tournament_structure_after_bracket();

create function public.protect_matches_after_bracket()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  target_tournament_id uuid;
  bracket_exists boolean;
begin
  target_tournament_id := case when tg_op = 'DELETE' then old.tournament_id else new.tournament_id end;

  select bracket_generated_at is not null
  into bracket_exists
  from public.tournaments
  where id = target_tournament_id;

  if not coalesce(bracket_exists, false) then
    return case when tg_op = 'DELETE' then old else new end;
  end if;

  if tg_op in ('INSERT', 'DELETE') then
    raise exception using
      errcode = '55000',
      message = 'bracket matches cannot be inserted or deleted after bracket generation';
  end if;

  if new.tournament_id is distinct from old.tournament_id
    or new.stage_id is distinct from old.stage_id
    or new.bracket_position is distinct from old.bracket_position
    or new.home_source_match_id is distinct from old.home_source_match_id
    or new.away_source_match_id is distinct from old.away_source_match_id
  then
    raise exception using
      errcode = '55000',
      message = 'bracket positions and sources are immutable after bracket generation';
  end if;

  if (
    new.home_team_id is distinct from old.home_team_id
    or new.away_team_id is distinct from old.away_team_id
  ) and coalesce(current_setting('app.allow_bracket_progression', true), 'false') <> 'true'
  then
    raise exception using
      errcode = '55000',
      message = 'bracket participants can only advance through the result publication operation';
  end if;

  return new;
end;
$$;

create trigger protect_matches_after_bracket
  before insert or update or delete on public.matches
  for each row execute function public.protect_matches_after_bracket();

create function public.protect_tournament_bracket_settings()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if old.bracket_generated_at is not null
    and (
      new.team_count is distinct from old.team_count
      or new.bracket_generated_at is distinct from old.bracket_generated_at
    )
  then
    raise exception using
      errcode = '55000',
      message = 'tournament capacity and bracket generation timestamp are immutable after bracket generation';
  end if;

  return new;
end;
$$;

create trigger protect_tournament_bracket_settings
  before update of team_count, bracket_generated_at on public.tournaments
  for each row execute function public.protect_tournament_bracket_settings();

revoke execute on function public.protect_tournament_structure_after_bracket() from public, anon, authenticated;
revoke execute on function public.protect_matches_after_bracket() from public, anon, authenticated;
revoke execute on function public.protect_tournament_bracket_settings() from public, anon, authenticated;

commit;
