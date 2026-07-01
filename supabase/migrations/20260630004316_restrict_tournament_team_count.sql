begin;

alter table public.tournaments
  add constraint tournaments_team_count_allowed
  check (team_count in (4, 8, 16, 32));

commit;
