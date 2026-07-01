begin;

alter table public.matches
  add constraint matches_teams_distinct
  check (home_team_id is null or away_team_id is null or home_team_id <> away_team_id),
  add constraint matches_home_score_nonnegative
  check (home_score >= 0),
  add constraint matches_away_score_nonnegative
  check (away_score >= 0);

alter table public.predictions
  add constraint predictions_home_score_nonnegative
  check (home_score >= 0),
  add constraint predictions_away_score_nonnegative
  check (away_score >= 0);

commit;
