begin;

select plan(4);

insert into public.tournaments (id, name, team_count, starts_at, ends_at)
values
  ('e1000000-0000-0000-0000-000000000001', 'Source tournament one', 4, now() + interval '1 day', now() + interval '2 days'),
  ('e1000000-0000-0000-0000-000000000002', 'Source tournament two', 4, now() + interval '1 day', now() + interval '2 days');

insert into public.stages (id, tournament_id, type, stage_order)
values
  ('e1100000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000001', 'SEMI_FINAL', 1),
  ('e1100000-0000-0000-0000-000000000002', 'e1000000-0000-0000-0000-000000000001', 'FINAL', 2),
  ('e1100000-0000-0000-0000-000000000003', 'e1000000-0000-0000-0000-000000000002', 'SEMI_FINAL', 1),
  ('e1100000-0000-0000-0000-000000000004', 'e1000000-0000-0000-0000-000000000002', 'FINAL', 2);

insert into public.teams (id, name, abbreviation, logo_path)
values
  ('e1200000-0000-0000-0000-000000000001', 'Source One', 'SO1', 'source/one.webp'),
  ('e1200000-0000-0000-0000-000000000002', 'Source Two', 'SO2', 'source/two.webp');

insert into public.tournament_teams (tournament_id, team_id)
values
  ('e1000000-0000-0000-0000-000000000001', 'e1200000-0000-0000-0000-000000000001'),
  ('e1000000-0000-0000-0000-000000000001', 'e1200000-0000-0000-0000-000000000002'),
  ('e1000000-0000-0000-0000-000000000002', 'e1200000-0000-0000-0000-000000000001'),
  ('e1000000-0000-0000-0000-000000000002', 'e1200000-0000-0000-0000-000000000002');

insert into public.matches (
  id,
  tournament_id,
  stage_id,
  bracket_position,
  home_team_id,
  away_team_id
)
values
  ('e1300000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000001', 'e1100000-0000-0000-0000-000000000001', 1, 'e1200000-0000-0000-0000-000000000001', 'e1200000-0000-0000-0000-000000000002'),
  ('e1300000-0000-0000-0000-000000000002', 'e1000000-0000-0000-0000-000000000001', 'e1100000-0000-0000-0000-000000000001', 2, 'e1200000-0000-0000-0000-000000000001', 'e1200000-0000-0000-0000-000000000002'),
  ('e1300000-0000-0000-0000-000000000003', 'e1000000-0000-0000-0000-000000000002', 'e1100000-0000-0000-0000-000000000003', 1, 'e1200000-0000-0000-0000-000000000001', 'e1200000-0000-0000-0000-000000000002');

select lives_ok(
  $$
    insert into public.matches (
      id, tournament_id, stage_id, bracket_position,
      home_source_match_id, away_source_match_id
    )
    values (
      'e1300000-0000-0000-0000-000000000010',
      'e1000000-0000-0000-0000-000000000001',
      'e1100000-0000-0000-0000-000000000002',
      1,
      'e1300000-0000-0000-0000-000000000001',
      'e1300000-0000-0000-0000-000000000002'
    )
  $$,
  'sources from the immediately previous stage of the same tournament are accepted'
);

select throws_ok(
  $$
    insert into public.matches (
      tournament_id, stage_id, bracket_position,
      home_source_match_id, away_source_match_id
    )
    values (
      'e1000000-0000-0000-0000-000000000002',
      'e1100000-0000-0000-0000-000000000004',
      1,
      'e1300000-0000-0000-0000-000000000001',
      'e1300000-0000-0000-0000-000000000003'
    )
  $$,
  '23514',
  'source matches must belong to the same tournament',
  'a source from another tournament is rejected'
);

select throws_ok(
  $$
    insert into public.matches (
      tournament_id, stage_id, bracket_position,
      home_source_match_id, away_source_match_id
    )
    values (
      'e1000000-0000-0000-0000-000000000001',
      'e1100000-0000-0000-0000-000000000001',
      3,
      'e1300000-0000-0000-0000-000000000001',
      'e1300000-0000-0000-0000-000000000002'
    )
  $$,
  '23514',
  'source matches must belong to the immediately previous stage',
  'a source from the same stage is rejected'
);

select throws_ok(
  $$
    insert into public.matches (
      tournament_id, stage_id, bracket_position,
      home_source_match_id, away_source_match_id
    )
    values (
      'e1000000-0000-0000-0000-000000000001',
      'e1100000-0000-0000-0000-000000000002',
      2,
      'e1300000-0000-0000-0000-000000000001',
      'e1300000-0000-0000-0000-000000000002'
    )
  $$,
  '23505',
  'a source match can feed only one bracket slot',
  'a source match cannot be reused by another slot'
);

select * from finish();

rollback;
