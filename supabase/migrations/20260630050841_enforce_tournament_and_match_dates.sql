begin;

alter table public.tournaments
  add constraint tournaments_date_range_valid
  check (starts_at < ends_at);

create function public.validate_tournament_dates()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE'
    and old.starts_at <= clock_timestamp()
    and (
      new.starts_at is distinct from old.starts_at
      or new.ends_at is distinct from old.ends_at
    )
  then
    raise exception using
      errcode = '23514',
      message = 'dates of a started tournament cannot be changed';
  end if;

  if new.starts_at <= clock_timestamp() then
    raise exception using
      errcode = '23514',
      message = 'tournament start must be in the future';
  end if;

  if tg_op = 'UPDATE' and exists (
    select 1
    from public.matches
    where tournament_id = new.id
      and starts_at is not null
      and (starts_at < new.starts_at or starts_at >= new.ends_at)
  ) then
    raise exception using
      errcode = '23514',
      message = 'tournament dates must contain all scheduled matches';
  end if;

  return new;
end;
$$;

create trigger validate_tournament_dates_before_write
  before insert or update of starts_at, ends_at on public.tournaments
  for each row execute function public.validate_tournament_dates();

create function public.validate_match_start()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  tournament_start timestamptz;
  tournament_end timestamptz;
begin
  if new.starts_at is null
    or (tg_op = 'UPDATE' and new.starts_at is not distinct from old.starts_at)
  then
    return new;
  end if;

  if tg_op = 'UPDATE'
    and old.starts_at is not null
    and old.starts_at <= clock_timestamp()
  then
    raise exception using
      errcode = '23514',
      message = 'a started match cannot be rescheduled';
  end if;

  if new.starts_at <= clock_timestamp() then
    raise exception using
      errcode = '23514',
      message = 'match start must be in the future';
  end if;

  select starts_at, ends_at
  into tournament_start, tournament_end
  from public.tournaments
  where id = new.tournament_id;

  if new.starts_at < tournament_start or new.starts_at >= tournament_end then
    raise exception using
      errcode = '23514',
      message = 'match start must be within the tournament date range';
  end if;

  return new;
end;
$$;

create trigger validate_match_start_before_write
  before insert or update of starts_at on public.matches
  for each row execute function public.validate_match_start();

revoke execute on function public.validate_tournament_dates() from public, anon, authenticated;
revoke execute on function public.validate_match_start() from public, anon, authenticated;

commit;
