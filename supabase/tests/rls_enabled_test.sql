begin;

select plan(9);

select is(
  relrowsecurity,
  true,
  'profiles has RLS enabled'
)
from pg_catalog.pg_class
where oid = 'public.profiles'::regclass;

select is(relrowsecurity, true, 'tournaments has RLS enabled')
from pg_catalog.pg_class
where oid = 'public.tournaments'::regclass;

select is(relrowsecurity, true, 'teams has RLS enabled')
from pg_catalog.pg_class
where oid = 'public.teams'::regclass;

select is(relrowsecurity, true, 'tournament_teams has RLS enabled')
from pg_catalog.pg_class
where oid = 'public.tournament_teams'::regclass;

select is(relrowsecurity, true, 'stages has RLS enabled')
from pg_catalog.pg_class
where oid = 'public.stages'::regclass;

select is(relrowsecurity, true, 'matches has RLS enabled')
from pg_catalog.pg_class
where oid = 'public.matches'::regclass;

select is(relrowsecurity, true, 'predictions has RLS enabled')
from pg_catalog.pg_class
where oid = 'public.predictions'::regclass;

select is(relrowsecurity, true, 'tournament_scores has RLS enabled')
from pg_catalog.pg_class
where oid = 'public.tournament_scores'::regclass;

set local role anon;

select throws_ok(
  $$
    insert into public.tournaments (name, team_count, starts_at, ends_at)
    values ('Blocked by default', 4, now() + interval '1 day', now() + interval '2 days')
  $$,
  '42501',
  'permission denied for table tournaments',
  'anon cannot insert before privileges and a policy exist'
);

reset role;

select * from finish();

rollback;
