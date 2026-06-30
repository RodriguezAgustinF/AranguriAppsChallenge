begin;

alter table public.tournament_teams
  add constraint tournament_teams_tournament_team_unique
  unique (tournament_id, team_id),
  add constraint tournament_teams_tournament_draw_position_unique
  unique (tournament_id, draw_position);

commit;
