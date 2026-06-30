begin;
select plan(6);

insert into public.tournaments (id, name, team_count, starts_at, ends_at)
values (
  '70000000-0000-0000-0000-000000000001',
  'Score basics',
  4,
  now() + interval '1 day',
  now() + interval '2 days'
);

insert into public.stages (id, tournament_id, type, stage_order)
values (
  '71000000-0000-0000-0000-000000000001',
  '70000000-0000-0000-0000-000000000001',
  'SEMI_FINAL',
  1
);

insert into public.teams (id, name, abbreviation, logo_path)
values
  ('72000000-0000-0000-0000-000000000001', 'Score home', 'SCH', 'teams/score-home.png'),
  ('72000000-0000-0000-0000-000000000002', 'Score away', 'SCA', 'teams/score-away.png');

insert into public.tournament_teams (tournament_id, team_id)
values
  ('70000000-0000-0000-0000-000000000001', '72000000-0000-0000-0000-000000000001'),
  ('70000000-0000-0000-0000-000000000001', '72000000-0000-0000-0000-000000000002');

insert into public.matches (
  id,
  tournament_id,
  stage_id,
  bracket_position,
  home_team_id,
  away_team_id
)
values (
  '73000000-0000-0000-0000-000000000001',
  '70000000-0000-0000-0000-000000000001',
  '71000000-0000-0000-0000-000000000001',
  1,
  '72000000-0000-0000-0000-000000000001',
  '72000000-0000-0000-0000-000000000002'
);

insert into auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  raw_user_meta_data,
  created_at,
  updated_at
)
values (
  '74000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'score-basics@example.com',
  '{"name":"Score basics"}'::jsonb,
  now(),
  now()
);

select throws_ok(
  $$
    insert into public.matches (
      tournament_id,
      stage_id,
      bracket_position,
      home_team_id,
      away_team_id
    )
    values (
      '70000000-0000-0000-0000-000000000001',
      '71000000-0000-0000-0000-000000000001',
      2,
      '72000000-0000-0000-0000-000000000001',
      '72000000-0000-0000-0000-000000000001'
    )
  $$,
  '23514',
  'new row for relation "matches" violates check constraint "matches_teams_distinct"',
  'a team cannot occupy both sides of a match'
);

select throws_ok(
  $$
    update public.matches
    set home_score = -1,
        away_score = 0,
        result_published_at = now()
    where id = '73000000-0000-0000-0000-000000000001'
  $$,
  '23514',
  'new row for relation "matches" violates check constraint "matches_home_score_nonnegative"',
  'negative official home goals are rejected'
);

select throws_ok(
  $$
    update public.matches
    set home_score = 0,
        away_score = -1,
        result_published_at = now()
    where id = '73000000-0000-0000-0000-000000000001'
  $$,
  '23514',
  'new row for relation "matches" violates check constraint "matches_away_score_nonnegative"',
  'negative official away goals are rejected'
);

select throws_ok(
  $$
    insert into public.predictions (user_id, match_id, home_score, away_score)
    values ('74000000-0000-0000-0000-000000000001', '73000000-0000-0000-0000-000000000001', -1, 0)
  $$,
  '23514',
  'new row for relation "predictions" violates check constraint "predictions_home_score_nonnegative"',
  'negative predicted home goals are rejected'
);

select throws_ok(
  $$
    insert into public.predictions (user_id, match_id, home_score, away_score)
    values ('74000000-0000-0000-0000-000000000001', '73000000-0000-0000-0000-000000000001', 0, -1)
  $$,
  '23514',
  'new row for relation "predictions" violates check constraint "predictions_away_score_nonnegative"',
  'negative predicted away goals are rejected'
);

select lives_ok(
  $$
    insert into public.predictions (user_id, match_id, home_score, away_score)
    values ('74000000-0000-0000-0000-000000000001', '73000000-0000-0000-0000-000000000001', 0, 0)
  $$,
  'zero goals remain valid'
);

select * from finish();
rollback;
