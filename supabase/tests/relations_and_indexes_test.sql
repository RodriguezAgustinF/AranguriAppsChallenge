begin;
select plan(12);

select has_index('public', 'tournaments', 'tournaments_starts_at_idx', 'tournaments are indexed by start time');
select has_index('public', 'tournament_teams', 'tournament_teams_team_id_idx', 'enrollments are indexed by team');
select has_index('public', 'matches', 'matches_tournament_starts_at_idx', 'matches are indexed for tournament schedules');
select has_index('public', 'matches', 'matches_home_team_id_idx', 'home teams are indexed');
select has_index('public', 'matches', 'matches_away_team_id_idx', 'away teams are indexed');
select has_index('public', 'matches', 'matches_home_source_match_id_idx', 'home sources are indexed');
select has_index('public', 'matches', 'matches_away_source_match_id_idx', 'away sources are indexed');
select has_index('public', 'predictions', 'predictions_match_id_idx', 'predictions are indexed by match');
select has_index('public', 'tournament_scores', 'tournament_scores_tournament_id_idx', 'scores are indexed by tournament');

insert into public.tournaments (id, name, team_count, starts_at, ends_at)
values
  ('40000000-0000-0000-0000-000000000001', 'Relations one', 4, now() + interval '1 day', now() + interval '2 days'),
  ('40000000-0000-0000-0000-000000000002', 'Relations two', 4, now() + interval '1 day', now() + interval '2 days');

insert into public.stages (id, tournament_id, type, stage_order)
values
  ('41000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', 'SEMI_FINAL', 1),
  ('41000000-0000-0000-0000-000000000002', '40000000-0000-0000-0000-000000000002', 'SEMI_FINAL', 1);

insert into public.teams (id, name, abbreviation, logo_path)
values
  ('42000000-0000-0000-0000-000000000001', 'Enrolled team', 'ENR', 'teams/enrolled.png'),
  ('42000000-0000-0000-0000-000000000002', 'Other team', 'OTH', 'teams/other.png');

insert into public.tournament_teams (tournament_id, team_id)
values ('40000000-0000-0000-0000-000000000001', '42000000-0000-0000-0000-000000000001');

select lives_ok(
  $$
    insert into public.matches (
      tournament_id,
      stage_id,
      bracket_position,
      home_team_id
    )
    values (
      '40000000-0000-0000-0000-000000000001',
      '41000000-0000-0000-0000-000000000001',
      1,
      '42000000-0000-0000-0000-000000000001'
    )
  $$,
  'a match accepts its own tournament stage and enrolled team'
);

select throws_ok(
  $$
    insert into public.matches (tournament_id, stage_id, bracket_position)
    values (
      '40000000-0000-0000-0000-000000000001',
      '41000000-0000-0000-0000-000000000002',
      2
    )
  $$,
  '23503',
  'insert or update on table "matches" violates foreign key constraint "matches_stage_tournament_fkey"',
  'a match cannot reference a stage from another tournament'
);

select throws_ok(
  $$
    insert into public.matches (
      tournament_id,
      stage_id,
      bracket_position,
      home_team_id
    )
    values (
      '40000000-0000-0000-0000-000000000001',
      '41000000-0000-0000-0000-000000000001',
      2,
      '42000000-0000-0000-0000-000000000002'
    )
  $$,
  '23503',
  'insert or update on table "matches" violates foreign key constraint "matches_home_tournament_team_fkey"',
  'a match cannot use a team that is not enrolled in its tournament'
);

select * from finish();
rollback;
