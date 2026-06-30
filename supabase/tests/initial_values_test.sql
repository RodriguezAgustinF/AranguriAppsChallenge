begin;
select plan(7);

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
  'e0000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'initial-values@example.com',
  '{"name":"Initial values","role":"ADMIN"}'::jsonb,
  now(),
  now()
);

insert into public.tournaments (id, name, team_count, starts_at, ends_at)
values ('e1000000-0000-0000-0000-000000000001', 'Initial tournament', 4, now() + interval '1 day', now() + interval '2 days');

insert into public.teams (id, name, abbreviation, logo_path)
values
  ('e2000000-0000-0000-0000-000000000001', 'Initial home', 'INH', 'teams/initial-home.png'),
  ('e2000000-0000-0000-0000-000000000002', 'Initial away', 'INA', 'teams/initial-away.png');

insert into public.tournament_teams (id, tournament_id, team_id)
values
  ('e3000000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000001', 'e2000000-0000-0000-0000-000000000001'),
  ('e3000000-0000-0000-0000-000000000002', 'e1000000-0000-0000-0000-000000000001', 'e2000000-0000-0000-0000-000000000002');

insert into public.stages (id, tournament_id, type, stage_order)
values ('e4000000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000001', 'SEMI_FINAL', 1);

insert into public.matches (id, tournament_id, stage_id, bracket_position, home_team_id, away_team_id)
values ('e5000000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000001', 'e4000000-0000-0000-0000-000000000001', 1, 'e2000000-0000-0000-0000-000000000001', 'e2000000-0000-0000-0000-000000000002');

insert into public.tournament_scores (user_id, tournament_id)
values ('e0000000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000001');

select is((select role::text from public.profiles where id = 'e0000000-0000-0000-0000-000000000001'), 'USER', 'new profiles start as USER');
select is((select status from public.tournament_overview where id = 'e1000000-0000-0000-0000-000000000001'), 'UPCOMING', 'new future tournaments are upcoming');
select is((select bracket_generated_at from public.tournaments where id = 'e1000000-0000-0000-0000-000000000001'), null::timestamptz, 'new tournaments have no generated bracket');
select is((select draw_position from public.tournament_teams where id = 'e3000000-0000-0000-0000-000000000001'), null::integer, 'enrollments begin without a draw position');
select is((select starts_at from public.matches where id = 'e5000000-0000-0000-0000-000000000001'), null::timestamptz, 'new matches are unscheduled');
select is((select result_published_at from public.matches where id = 'e5000000-0000-0000-0000-000000000001'), null::timestamptz, 'new matches have no official result');
select is((select points from public.tournament_scores where user_id = 'e0000000-0000-0000-0000-000000000001' and tournament_id = 'e1000000-0000-0000-0000-000000000001'), 0, 'new tournament scores start at zero');

select * from finish();
rollback;
