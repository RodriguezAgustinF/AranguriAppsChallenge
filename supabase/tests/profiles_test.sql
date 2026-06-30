begin;
select plan(6);

select has_table('public', 'profiles', 'profiles table exists');
select col_is_pk('public', 'profiles', 'id', 'profiles.id is the primary key');

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
  '11111111-1111-1111-1111-111111111111',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'profile-test@example.com',
  '{"name":"  Test User  ","role":"ADMIN"}'::jsonb,
  now(),
  now()
);

select is(
  (select count(*)::integer from public.profiles where id = '11111111-1111-1111-1111-111111111111'),
  1,
  'creating an auth identity creates exactly one profile'
);

select is(
  (select name from public.profiles where id = '11111111-1111-1111-1111-111111111111'),
  'Test User',
  'the profile name is trimmed'
);

select is(
  (select role::text from public.profiles where id = '11111111-1111-1111-1111-111111111111'),
  'USER',
  'role metadata cannot create an admin profile'
);

delete from auth.users
where id = '11111111-1111-1111-1111-111111111111';

select is(
  (select count(*)::integer from public.profiles where id = '11111111-1111-1111-1111-111111111111'),
  0,
  'deleting the auth identity deletes its profile'
);

select * from finish();
rollback;
