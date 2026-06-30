begin;

select plan(6);

select is(
  (
    select count(*)
    from public.teams
    where id::text like 'd0000000-0000-0000-0000-%'
  ),
  4::bigint,
  'the development team catalog contains four deterministic teams'
);

select is(
  (
    select count(*)
    from public.teams
    where id::text like 'd0000000-0000-0000-0000-%'
      and logo_path like 'seed/%.webp'
  ),
  4::bigint,
  'every seeded team has a stable Storage path'
);

select is(
  (
    select name
    from public.tournaments
    where id = 'd1000000-0000-0000-0000-000000000001'
  ),
  'Copa de desarrollo',
  'the development tournament exists'
);

select ok(
  (
    select starts_at > now()
    from public.tournaments
    where id = 'd1000000-0000-0000-0000-000000000001'
  ),
  'the seeded tournament always starts in the future'
);

select is(
  (
    select count(*)
    from public.tournament_teams
    where tournament_id = 'd1000000-0000-0000-0000-000000000001'
      and draw_position is null
  ),
  4::bigint,
  'all four teams are enrolled and remain unsorted'
);

select is(
  (
    select count(*)
    from public.stages
    where tournament_id = 'd1000000-0000-0000-0000-000000000001'
  ),
  0::bigint,
  'the seed does not bypass the future bracket generation operation'
);

select * from finish();

rollback;
