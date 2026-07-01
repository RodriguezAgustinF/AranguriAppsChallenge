begin;
drop view public.tournament_overview;
alter table public.tournaments drop constraint tournaments_date_range_valid,
  alter column ends_at drop not null,
  add constraint tournaments_optional_end_valid check (ends_at is null or starts_at < ends_at);

create or replace function public.validate_tournament_dates() returns trigger language plpgsql set search_path = '' as $$
begin
  if tg_op = 'UPDATE' and old.starts_at <= clock_timestamp() and new.starts_at is distinct from old.starts_at then
    raise exception using errcode='23514', message='the start of a started tournament cannot be changed';
  end if;
  if new.starts_at <= clock_timestamp() then
    raise exception using errcode='23514', message='tournament start must be in the future';
  end if;
  if tg_op = 'UPDATE' and exists (
    select 1 from public.matches
    where tournament_id = new.id and starts_at is not null and starts_at < new.starts_at
  ) then
    raise exception using errcode='23514', message='tournament start must not be after a scheduled match';
  end if;
  return new;
end; $$;

create or replace function public.validate_match_start() returns trigger language plpgsql set search_path = '' as $$
declare tournament_start timestamptz;
begin
  if new.starts_at is null or (tg_op = 'UPDATE' and new.starts_at is not distinct from old.starts_at) then return new; end if;
  if tg_op = 'UPDATE' and old.starts_at is not null and old.starts_at <= clock_timestamp() then raise exception using errcode='23514', message='a started match cannot be rescheduled'; end if;
  if new.starts_at <= clock_timestamp() then raise exception using errcode='23514', message='match start must be in the future'; end if;
  select starts_at into tournament_start from public.tournaments where id = new.tournament_id;
  if new.starts_at < tournament_start then raise exception using errcode='23514', message='match start must not be before the tournament'; end if;
  return new;
end; $$;

create view public.tournament_overview with (security_invoker = true) as
select tournament.*,
  case when final_match.result_published_at is not null then 'FINISHED' when clock_timestamp() < tournament.starts_at then 'UPCOMING' else 'IN_PROGRESS' end as status,
  case when final_match.result_published_at is null then null when final_match.home_score > final_match.away_score then final_match.home_team_id when final_match.away_score > final_match.home_score then final_match.away_team_id else final_match.penalty_winner_team_id end as champion_team_id
from public.tournaments as tournament
left join public.stages as final_stage on final_stage.tournament_id = tournament.id and final_stage.type = 'FINAL'
left join public.matches as final_match on final_match.stage_id = final_stage.id;
grant select on public.tournament_overview to anon, authenticated;
commit;
