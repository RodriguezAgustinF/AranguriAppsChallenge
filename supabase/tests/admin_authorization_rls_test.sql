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
    'f5000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'admin-authorization@example.com',
    '{"name":"Admin Authorization"}'::jsonb,
    now(),
    now()
  ),
  (
    'f5000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'user-authorization@example.com',
    '{"name":"User Authorization"}'::jsonb,
    now(),
    now()
  );

update public.profiles
set role = 'ADMIN'
where id = 'f5000000-0000-0000-0000-000000000001';

set local role authenticated;
set local request.jwt.claims = '{"sub":"f5000000-0000-0000-0000-000000000001","role":"authenticated"}';

select is(public.is_admin(), true, 'the ADMIN profile is recognized');

select lives_ok(
  $$
    insert into public.teams (id, name, abbreviation, logo_path)
    values ('f5100000-0000-0000-0000-000000000001', 'Admin Team', 'ADT', 'admin/team.webp')
  $$,
  'an ADMIN can create a team'
);

select lives_ok(
  $$
    insert into public.tournaments (id, name, team_count, starts_at, ends_at)
    values (
      'f5200000-0000-0000-0000-000000000001',
      'Admin Tournament',
      4,
      now() + interval '1 day',
      now() + interval '2 days'
    )
  $$,
  'an ADMIN can create a tournament'
);

select lives_ok(
  $$
    insert into public.tournament_teams (tournament_id, team_id)
    values (
      'f5200000-0000-0000-0000-000000000001',
      'f5100000-0000-0000-0000-000000000001'
    )
  $$,
  'an ADMIN can enroll a team'
);

set local request.jwt.claims = '{"sub":"f5000000-0000-0000-0000-000000000002","role":"authenticated"}';

select is(public.is_admin(), false, 'a USER profile is not recognized as ADMIN');

select throws_ok(
  $$
    insert into public.teams (name, abbreviation, logo_path)
    values ('Forbidden Team', 'FBT', 'user/forbidden.webp')
  $$,
  '42501',
  'new row violates row-level security policy for table "teams"',
  'a USER cannot create a team'
);

select lives_ok(
  $$
    update public.tournaments
    set name = 'Forbidden change'
    where id = 'f5200000-0000-0000-0000-000000000001'
  $$,
  'an unauthorized update is safely filtered by RLS'
);

select is(
  (select name from public.tournaments where id = 'f5200000-0000-0000-0000-000000000001'),
  'Admin Tournament',
  'the tournament remains unchanged for a USER'
);

reset role;

select * from finish();

rollback;
