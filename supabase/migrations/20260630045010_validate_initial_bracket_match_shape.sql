begin;

alter table public.matches
  add constraint matches_sources_complete
  check ((home_source_match_id is null) = (away_source_match_id is null));

create function public.validate_new_bracket_match()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.home_source_match_id is null and new.away_source_match_id is null then
    if new.home_team_id is null or new.away_team_id is null then
      raise exception using
        errcode = '23514',
        message = 'initial bracket matches require both teams and no sources',
        constraint = 'matches_insert_shape_valid';
    end if;
  elsif new.home_source_match_id is not null and new.away_source_match_id is not null then
    if new.home_team_id is not null or new.away_team_id is not null then
      raise exception using
        errcode = '23514',
        message = 'dependent bracket matches require two sources and no teams on insert',
        constraint = 'matches_insert_shape_valid';
    end if;
  else
    raise exception using
      errcode = '23514',
      message = 'bracket matches require either zero or two sources',
      constraint = 'matches_sources_complete';
  end if;

  return new;
end;
$$;

revoke execute on function public.validate_new_bracket_match() from public, anon, authenticated;

create trigger validate_new_bracket_match_before_insert
  before insert on public.matches
  for each row execute function public.validate_new_bracket_match();

commit;
