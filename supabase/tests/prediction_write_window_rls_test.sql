begin;

select plan(8);

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
values
  (
    'f4000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'write-owner@example.com',
    '{"name":"Write Owner"}'::jsonb,
    now(),
    now()
  ),
  (
    'f4000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'write-other@example.com',
    '{"name":"Write Other"}'::jsonb,
    now(),
    now()
  );

insert into public.tournaments (id, name, team_count, starts_at, ends_at)
values (
  'f4100000-0000-0000-0000-000000000001',
  'Prediction write window',
  4,
  now() + interval '1 second',
  now() + interval '2 days'
);

insert into public.stages (id, tournament_id, type, stage_order)
values (
  'f4200000-0000-0000-0000-000000000001',
  'f4100000-0000-0000-0000-000000000001',
  'SEMI_FINAL',
  1
);

insert into public.teams (id, name, abbreviation, logo_path)
values
  ('f4300000-0000-0000-0000-000000000001', 'Write Home', 'WRH', 'write/home.webp'),
  ('f4300000-0000-0000-0000-000000000002', 'Write Away', 'WRA', 'write/away.webp');

insert into public.tournament_teams (tournament_id, team_id)
values
  ('f4100000-0000-0000-0000-000000000001', 'f4300000-0000-0000-0000-000000000001'),
  ('f4100000-0000-0000-0000-000000000001', 'f4300000-0000-0000-0000-000000000002');

insert into public.matches (
  id,
  tournament_id,
  stage_id,
  bracket_position,
  home_team_id,
  away_team_id,
  starts_at
)
values
  (
    'f4400000-0000-0000-0000-000000000001',
    'f4100000-0000-0000-0000-000000000001',
    'f4200000-0000-0000-0000-000000000001',
    1,
    'f4300000-0000-0000-0000-000000000001',
    'f4300000-0000-0000-0000-000000000002',
    now() + interval '1 day'
  ),
  (
    'f4400000-0000-0000-0000-000000000002',
    'f4100000-0000-0000-0000-000000000001',
    'f4200000-0000-0000-0000-000000000001',
    2,
    'f4300000-0000-0000-0000-000000000001',
    'f4300000-0000-0000-0000-000000000002',
    null
  ),
  (
    'f4400000-0000-0000-0000-000000000003',
    'f4100000-0000-0000-0000-000000000001',
    'f4200000-0000-0000-0000-000000000001',
    3,
    'f4300000-0000-0000-0000-000000000001',
    'f4300000-0000-0000-0000-000000000002',
    now() + interval '2 seconds'
  );

set local role authenticated;
set local request.jwt.claims = '{"sub":"f4000000-0000-0000-0000-000000000001","role":"authenticated"}';

select lives_ok(
  $$
    insert into public.predictions (id, user_id, match_id, home_score, away_score)
    values (
      'f4500000-0000-0000-0000-000000000001',
      'f4000000-0000-0000-0000-000000000001',
      'f4400000-0000-0000-0000-000000000001',
      2,
      1
    )
  $$,
  'a user can create an own prediction before kickoff'
);

select lives_ok(
  $$
    update public.predictions
    set home_score = 3
    where id = 'f4500000-0000-0000-0000-000000000001'
  $$,
  'a user can edit an own prediction before kickoff'
);

select is(
  (select home_score from public.predictions where id = 'f4500000-0000-0000-0000-000000000001'),
  3,
  'the permitted edit is persisted'
);

select throws_ok(
  $$
    insert into public.predictions (user_id, match_id, home_score, away_score)
    values (
      'f4000000-0000-0000-0000-000000000002',
      'f4400000-0000-0000-0000-000000000001',
      1,
      0
    )
  $$,
  '42501',
  'new row violates row-level security policy for table "predictions"',
  'a user cannot create a prediction for another identity'
);

select throws_ok(
  $$
    insert into public.predictions (user_id, match_id, home_score, away_score)
    values (
      'f4000000-0000-0000-0000-000000000001',
      'f4400000-0000-0000-0000-000000000002',
      1,
      0
    )
  $$,
  '42501',
  'new row violates row-level security policy for table "predictions"',
  'an unscheduled match does not accept predictions'
);

select lives_ok(
  $$
    insert into public.predictions (id, user_id, match_id, home_score, away_score)
    values (
      'f4500000-0000-0000-0000-000000000003',
      'f4000000-0000-0000-0000-000000000001',
      'f4400000-0000-0000-0000-000000000003',
      1,
      0
    )
  $$,
  'a prediction is accepted while the near kickoff is still in the future'
);

select pg_sleep(2.1);

select lives_ok(
  $$
    update public.predictions
    set home_score = 2
    where id = 'f4500000-0000-0000-0000-000000000003'
  $$,
  'an update after kickoff is safely filtered by RLS'
);

select is(
  (select home_score from public.predictions where id = 'f4500000-0000-0000-0000-000000000003'),
  1,
  'the prediction remains unchanged after kickoff'
);

reset role;

select * from finish();

rollback;
