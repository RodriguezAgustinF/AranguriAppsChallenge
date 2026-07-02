begin;

create or replace function public.validate_tournament_dates()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE'
    and old.bracket_generated_at is not null
    and old.starts_at <= clock_timestamp()
    and new.starts_at is distinct from old.starts_at
  then
    raise exception using
      errcode = '23514',
      message = 'the start of a started tournament cannot be changed';
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
      and starts_at < new.starts_at
  ) then
    raise exception using
      errcode = '23514',
      message = 'tournament start must not be after a scheduled match';
  end if;

  return new;
end;
$$;

commit;
