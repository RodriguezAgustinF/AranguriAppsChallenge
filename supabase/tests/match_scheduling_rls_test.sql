begin;

select plan(5);

insert into auth.users (id, instance_id, aud, role, email, raw_user_meta_data, created_at, updated_at)
values
  ('a5000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'scheduler@example.com', '{}'::jsonb, now(), now()),
  ('a5000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'viewer@example.com', '{}'::jsonb, now(), now());

update public.profiles set role = 'ADMIN' where id = 'a5000000-0000-0000-0000-000000000001';

insert into public.tournaments (id, name, team_count, starts_at)
values ('a5100000-0000-0000-0000-000000000001', 'Scheduling', 4, now() + interval '1 day');
insert into public.teams (id, name, abbreviation, logo_path)
values
  ('a5110000-0000-0000-0000-000000000001', 'Schedule Home', 'SCH', 'tests/schedule-home.webp'),
  ('a5110000-0000-0000-0000-000000000002', 'Schedule Away', 'SCA', 'tests/schedule-away.webp');
insert into public.tournament_teams (tournament_id, team_id)
values
  ('a5100000-0000-0000-0000-000000000001', 'a5110000-0000-0000-0000-000000000001'),
  ('a5100000-0000-0000-0000-000000000001', 'a5110000-0000-0000-0000-000000000002');
insert into public.stages (id, tournament_id, type, stage_order)
values ('a5200000-0000-0000-0000-000000000001', 'a5100000-0000-0000-0000-000000000001', 'FINAL', 1);
insert into public.matches (id, tournament_id, stage_id, bracket_position, home_team_id, away_team_id)
values ('a5300000-0000-0000-0000-000000000001', 'a5100000-0000-0000-0000-000000000001', 'a5200000-0000-0000-0000-000000000001', 1, 'a5110000-0000-0000-0000-000000000001', 'a5110000-0000-0000-0000-000000000002');

set local role authenticated;
set local request.jwt.claims = '{"sub":"a5000000-0000-0000-0000-000000000001","role":"authenticated"}';

select lives_ok(
  $$update public.matches set starts_at = now() + interval '2 days' where id = 'a5300000-0000-0000-0000-000000000001'$$,
  'an ADMIN can schedule a match'
);
select isnt((select starts_at from public.matches where id = 'a5300000-0000-0000-0000-000000000001'), null, 'the schedule is persisted');
select throws_ok(
  $$update public.matches set home_score = 1 where id = 'a5300000-0000-0000-0000-000000000001'$$,
  '42501',
  'permission denied for table matches',
  'the scheduling grant cannot alter results'
);

set local request.jwt.claims = '{"sub":"a5000000-0000-0000-0000-000000000002","role":"authenticated"}';
select lives_ok(
  $$update public.matches set starts_at = now() + interval '3 days' where id = 'a5300000-0000-0000-0000-000000000001'$$,
  'a USER scheduling attempt is safely filtered by RLS'
);
select cmp_ok(
  (select starts_at from public.matches where id = 'a5300000-0000-0000-0000-000000000001'),
  '<',
  now() + interval '2 days 1 minute',
  'the USER attempt does not change the schedule'
);

reset role;
select * from finish();
rollback;
