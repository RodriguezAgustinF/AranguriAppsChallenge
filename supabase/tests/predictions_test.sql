begin;
select plan(3);

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
    '50000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'prediction-one@example.com',
    '{"name":"Prediction one"}'::jsonb,
    now(),
    now()
  ),
  (
    '50000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'prediction-two@example.com',
    '{"name":"Prediction two"}'::jsonb,
    now(),
    now()
  );

insert into public.tournaments (id, name, team_count, starts_at, ends_at)
values (
  '51000000-0000-0000-0000-000000000001',
  'Prediction tournament',
  4,
  now() + interval '1 day',
  now() + interval '2 days'
);

insert into public.stages (id, tournament_id, type, stage_order)
values (
  '52000000-0000-0000-0000-000000000001',
  '51000000-0000-0000-0000-000000000001',
  'SEMI_FINAL',
  1
);

insert into public.matches (id, tournament_id, stage_id, bracket_position)
values
  (
    '53000000-0000-0000-0000-000000000001',
    '51000000-0000-0000-0000-000000000001',
    '52000000-0000-0000-0000-000000000001',
    1
  ),
  (
    '53000000-0000-0000-0000-000000000002',
    '51000000-0000-0000-0000-000000000001',
    '52000000-0000-0000-0000-000000000001',
    2
  );

select lives_ok(
  $$
    insert into public.predictions (user_id, match_id, home_score, away_score)
    values
      ('50000000-0000-0000-0000-000000000001', '53000000-0000-0000-0000-000000000001', 1, 0),
      ('50000000-0000-0000-0000-000000000001', '53000000-0000-0000-0000-000000000002', 2, 1)
  $$,
  'one user can predict different matches'
);

select lives_ok(
  $$
    insert into public.predictions (user_id, match_id, home_score, away_score)
    values ('50000000-0000-0000-0000-000000000002', '53000000-0000-0000-0000-000000000001', 0, 1)
  $$,
  'different users can predict the same match'
);

select throws_ok(
  $$
    insert into public.predictions (user_id, match_id, home_score, away_score)
    values ('50000000-0000-0000-0000-000000000001', '53000000-0000-0000-0000-000000000001', 3, 2)
  $$,
  '23505',
  'duplicate key value violates unique constraint "predictions_user_match_unique"',
  'one user cannot create two predictions for the same match'
);

select * from finish();
rollback;
