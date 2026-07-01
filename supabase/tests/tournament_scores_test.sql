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
    '60000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'score-one@example.com',
    '{"name":"Score one"}'::jsonb,
    now(),
    now()
  ),
  (
    '60000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'score-two@example.com',
    '{"name":"Score two"}'::jsonb,
    now(),
    now()
  );

insert into public.tournaments (id, name, team_count, starts_at, ends_at)
values
  ('61000000-0000-0000-0000-000000000001', 'Score tournament one', 4, now() + interval '1 day', now() + interval '2 days'),
  ('61000000-0000-0000-0000-000000000002', 'Score tournament two', 4, now() + interval '1 day', now() + interval '2 days');

select lives_ok(
  $$
    insert into public.tournament_scores (user_id, tournament_id, points)
    values
      ('60000000-0000-0000-0000-000000000001', '61000000-0000-0000-0000-000000000001', 0),
      ('60000000-0000-0000-0000-000000000001', '61000000-0000-0000-0000-000000000002', 0)
  $$,
  'one user can have scores in different tournaments'
);

select lives_ok(
  $$
    insert into public.tournament_scores (user_id, tournament_id, points)
    values ('60000000-0000-0000-0000-000000000002', '61000000-0000-0000-0000-000000000001', 0)
  $$,
  'different users can have scores in the same tournament'
);

select throws_ok(
  $$
    insert into public.tournament_scores (user_id, tournament_id, points)
    values ('60000000-0000-0000-0000-000000000001', '61000000-0000-0000-0000-000000000001', 6)
  $$,
  '23505',
  'duplicate key value violates unique constraint "tournament_scores_user_tournament_unique"',
  'one user cannot have two score rows in the same tournament'
);

select * from finish();
rollback;
