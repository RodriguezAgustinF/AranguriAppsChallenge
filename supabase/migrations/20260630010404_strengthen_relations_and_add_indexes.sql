begin;

alter table public.stages
  add constraint stages_id_tournament_unique
  unique (id, tournament_id);

alter table public.matches
  drop constraint matches_stage_id_fkey,
  drop constraint matches_home_team_id_fkey,
  drop constraint matches_away_team_id_fkey,
  drop constraint matches_penalty_winner_team_id_fkey,
  add constraint matches_stage_tournament_fkey
  foreign key (stage_id, tournament_id)
  references public.stages (id, tournament_id)
  on delete cascade,
  add constraint matches_home_tournament_team_fkey
  foreign key (tournament_id, home_team_id)
  references public.tournament_teams (tournament_id, team_id)
  on delete restrict,
  add constraint matches_away_tournament_team_fkey
  foreign key (tournament_id, away_team_id)
  references public.tournament_teams (tournament_id, team_id)
  on delete restrict,
  add constraint matches_penalty_winner_tournament_team_fkey
  foreign key (tournament_id, penalty_winner_team_id)
  references public.tournament_teams (tournament_id, team_id)
  on delete restrict;

create index tournaments_starts_at_idx
  on public.tournaments (starts_at);

create index tournament_teams_team_id_idx
  on public.tournament_teams (team_id);

create index matches_tournament_starts_at_idx
  on public.matches (tournament_id, starts_at);

create index matches_home_team_id_idx
  on public.matches (home_team_id);

create index matches_away_team_id_idx
  on public.matches (away_team_id);

create index matches_home_source_match_id_idx
  on public.matches (home_source_match_id);

create index matches_away_source_match_id_idx
  on public.matches (away_source_match_id);

create index predictions_match_id_idx
  on public.predictions (match_id);

create index tournament_scores_tournament_id_idx
  on public.tournament_scores (tournament_id);

commit;
