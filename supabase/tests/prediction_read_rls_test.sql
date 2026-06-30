begin;

select plan(4);

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
    'f3000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'prediction-owner@example.com',
    '{"name":"Prediction Owner"}'::jsonb,
    now(),
    now()
  ),
  (
    'f3000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'prediction-other@example.com',
    '{"name":"Prediction Other"}'::jsonb,
    now(),
    now()
  );

insert into public.tournaments (id, name, team_count, starts_at, ends_at)
values (
  'f3100000-0000-0000-0000-000000000001',
  'Prediction visibility',
  4,
  now() + interval '1 day',
  now() + interval '2 days'
);

insert into public.stages (id, tournament_id, type, stage_order)
values (
  'f3200000-0000-0000-0000-000000000001',
  'f3100000-0000-0000-0000-000000000001',
  'SEMI_FINAL',
  1
);

insert into public.teams (id, name, abbreviation, logo_path)
values
  ('f3300000-0000-0000-0000-000000000001', 'Prediction Home', 'PRH', 'predictions/home.webp'),
  ('f3300000-0000-0000-0000-000000000002', 'Prediction Away', 'PRA', 'predictions/away.webp');

insert into public.tournament_teams (tournament_id, team_id)
values
  ('f3100000-0000-0000-0000-000000000001', 'f3300000-0000-0000-0000-000000000001'),
  ('f3100000-0000-0000-0000-000000000001', 'f3300000-0000-0000-0000-000000000002');

insert into public.matches (
  id,
  tournament_id,
  stage_id,
  bracket_position,
  home_team_id,
  away_team_id,
  starts_at
)
values (
  'f3400000-0000-0000-0000-000000000001',
  'f3100000-0000-0000-0000-000000000001',
  'f3200000-0000-0000-0000-000000000001',
  1,
  'f3300000-0000-0000-0000-000000000001',
  'f3300000-0000-0000-0000-000000000002',
  now() + interval '36 hours'
);

insert into public.predictions (id, user_id, match_id, home_score, away_score)
values
  (
    'f3500000-0000-0000-0000-000000000001',
    'f3000000-0000-0000-0000-000000000001',
    'f3400000-0000-0000-0000-000000000001',
    2,
    1
  ),
  (
    'f3500000-0000-0000-0000-000000000002',
    'f3000000-0000-0000-0000-000000000002',
    'f3400000-0000-0000-0000-000000000001',
    1,
    0
  );

set local role authenticated;
set local request.jwt.claims = '{"sub":"f3000000-0000-0000-0000-000000000001","role":"authenticated"}';

select is(
  (select count(*) from public.predictions),
  1::bigint,
  'an authenticated user sees only one own prediction'
);

select is(
  (
    select home_score
    from public.predictions
    where id = 'f3500000-0000-0000-0000-000000000001'
  ),
  2,
  'an authenticated user can read their own prediction'
);

select is(
  (
    select count(*)
    from public.predictions
    where id = 'f3500000-0000-0000-0000-000000000002'
  ),
  0::bigint,
  'an authenticated user cannot read another user prediction by id'
);

reset role;
set local role anon;

select throws_ok(
  $$ select count(*) from public.predictions $$,
  '42501',
  'permission denied for table predictions',
  'anonymous visitors cannot read predictions'
);

reset role;

select * from finish();

rollback;
