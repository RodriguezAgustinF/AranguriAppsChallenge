begin;

select plan(9);

insert into public.tournaments (id, name, team_count, starts_at, ends_at)
values (
  'f2000000-0000-0000-0000-000000000001',
  'Public competition',
  4,
  now() + interval '1 day',
  now() + interval '2 days'
);

insert into public.stages (id, tournament_id, type, stage_order)
values (
  'f2100000-0000-0000-0000-000000000001',
  'f2000000-0000-0000-0000-000000000001',
  'SEMI_FINAL',
  1
);

insert into public.teams (id, name, abbreviation, logo_path)
values
  ('f2200000-0000-0000-0000-000000000001', 'Public Home', 'PUH', 'public/home.webp'),
  ('f2200000-0000-0000-0000-000000000002', 'Public Away', 'PUA', 'public/away.webp');

insert into public.tournament_teams (tournament_id, team_id)
values
  ('f2000000-0000-0000-0000-000000000001', 'f2200000-0000-0000-0000-000000000001'),
  ('f2000000-0000-0000-0000-000000000001', 'f2200000-0000-0000-0000-000000000002');

insert into public.matches (
  id,
  tournament_id,
  stage_id,
  bracket_position,
  home_team_id,
  away_team_id
)
values (
  'f2300000-0000-0000-0000-000000000001',
  'f2000000-0000-0000-0000-000000000001',
  'f2100000-0000-0000-0000-000000000001',
  1,
  'f2200000-0000-0000-0000-000000000001',
  'f2200000-0000-0000-0000-000000000002'
);

set local role anon;

select is(
  (select name from public.tournaments where id = 'f2000000-0000-0000-0000-000000000001'),
  'Public competition',
  'anon can read a tournament'
);

select is(
  (select count(*) from public.teams where id::text like 'f2200000-0000-0000-0000-%'),
  2::bigint,
  'anon can read competition teams'
);

select is(
  (select count(*) from public.tournament_teams where tournament_id = 'f2000000-0000-0000-0000-000000000001'),
  2::bigint,
  'anon can read tournament enrollments'
);

select is(
  (select type from public.stages where id = 'f2100000-0000-0000-0000-000000000001'),
  'SEMI_FINAL'::public.stage_type,
  'anon can read bracket stages'
);

select is(
  (select bracket_position from public.matches where id = 'f2300000-0000-0000-0000-000000000001'),
  1,
  'anon can read matches'
);

select is(
  (select status from public.tournament_overview where id = 'f2000000-0000-0000-0000-000000000001'),
  'UPCOMING',
  'anon can read the security-invoker tournament overview'
);

select throws_ok(
  $$ delete from public.matches where id = 'f2300000-0000-0000-0000-000000000001' $$,
  '42501',
  'permission denied for table matches',
  'public read access does not grant delete access'
);

reset role;
set local role authenticated;

select is(
  (select name from public.teams where id = 'f2200000-0000-0000-0000-000000000001'),
  'Public Home',
  'authenticated users can read teams'
);

select is(
  (select count(*) from public.matches where tournament_id = 'f2000000-0000-0000-0000-000000000001'),
  1::bigint,
  'authenticated users can read matches'
);

reset role;

select * from finish();

rollback;
