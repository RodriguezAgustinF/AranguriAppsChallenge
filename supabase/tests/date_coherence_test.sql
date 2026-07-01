begin;
select plan(8);

select throws_ok(
  $$
    insert into public.tournaments (name, team_count, starts_at, ends_at)
    values ('Reversed dates', 4, now() + interval '2 days', now() + interval '1 day')
  $$,
  '23514',
  'new row for relation "tournaments" violates check constraint "tournaments_optional_end_valid"',
  'tournament end must be after its start'
);

select throws_ok(
  $$
    insert into public.tournaments (name, team_count, starts_at, ends_at)
    values ('Past start', 4, now() - interval '1 day', now() + interval '1 day')
  $$,
  '23514',
  'tournament start must be in the future',
  'a tournament cannot be created in the past'
);

insert into public.tournaments (id, name, team_count, starts_at, ends_at)
values (
  'c0000000-0000-0000-0000-000000000001',
  'Date coherence',
  4,
  now() + interval '1 day',
  now() + interval '2 days'
);

insert into public.stages (id, tournament_id, type, stage_order)
values ('c1000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'SEMI_FINAL', 1);

insert into public.teams (id, name, abbreviation, logo_path)
values
  ('c2000000-0000-0000-0000-000000000001', 'Date home', 'DAH', 'teams/date-home.png'),
  ('c2000000-0000-0000-0000-000000000002', 'Date away', 'DAA', 'teams/date-away.png');

insert into public.tournament_teams (tournament_id, team_id)
values
  ('c0000000-0000-0000-0000-000000000001', 'c2000000-0000-0000-0000-000000000001'),
  ('c0000000-0000-0000-0000-000000000001', 'c2000000-0000-0000-0000-000000000002');

insert into public.matches (id, tournament_id, stage_id, bracket_position, home_team_id, away_team_id)
values ('c3000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001', 1, 'c2000000-0000-0000-0000-000000000001', 'c2000000-0000-0000-0000-000000000002');

select throws_ok($$update public.matches set starts_at = now() + interval '12 hours' where id = 'c3000000-0000-0000-0000-000000000001'$$, '23514', 'match start must not be before the tournament', 'a match cannot start before its tournament');
select lives_ok($$update public.matches set starts_at = now() + interval '2 days' where id = 'c3000000-0000-0000-0000-000000000001'$$, 'a match may be scheduled after a legacy end date');
select throws_ok($$update public.matches set starts_at = now() - interval '1 minute' where id = 'c3000000-0000-0000-0000-000000000001'$$, '23514', 'match start must be in the future', 'a match cannot be scheduled in the past');
select lives_ok($$update public.matches set starts_at = now() + interval '36 hours' where id = 'c3000000-0000-0000-0000-000000000001'$$, 'a match can be scheduled inside the tournament range');
select lives_ok($$update public.tournaments set ends_at = null where id = 'c0000000-0000-0000-0000-000000000001'$$, 'the obsolete end can be removed');
select throws_ok($$update public.tournaments set starts_at = now() + interval '2 days' where id = 'c0000000-0000-0000-0000-000000000001'$$, '23514', 'tournament start must not be after a scheduled match', 'tournament start cannot exclude a scheduled match');

select * from finish();
rollback;
