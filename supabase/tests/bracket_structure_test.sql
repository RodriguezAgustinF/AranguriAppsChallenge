begin;
select plan(8);

insert into public.tournaments (id, name, team_count, starts_at, ends_at)
values (
  '30000000-0000-0000-0000-000000000001',
  'Bracket test',
  4,
  now() + interval '1 day',
  now() + interval '2 days'
);

insert into public.stages (id, tournament_id, type, stage_order)
values (
  '31000000-0000-0000-0000-000000000001',
  '30000000-0000-0000-0000-000000000001',
  'SEMI_FINAL',
  1
);

insert into public.teams (id, name, abbreviation, logo_path)
values
  ('33000000-0000-0000-0000-000000000001', 'Structure one', 'STO', 'teams/structure-one.png'),
  ('33000000-0000-0000-0000-000000000002', 'Structure two', 'STT', 'teams/structure-two.png'),
  ('33000000-0000-0000-0000-000000000003', 'Structure three', 'STR', 'teams/structure-three.png'),
  ('33000000-0000-0000-0000-000000000004', 'Structure four', 'STF', 'teams/structure-four.png');

insert into public.tournament_teams (tournament_id, team_id)
select '30000000-0000-0000-0000-000000000001', id
from public.teams
where id::text like '33000000-0000-0000-0000-%';

select col_is_fk('public', 'matches', 'home_source_match_id', 'home source references matches');
select col_is_fk('public', 'matches', 'away_source_match_id', 'away source references matches');

select throws_ok(
  $$
    insert into public.stages (tournament_id, type, stage_order)
    values ('30000000-0000-0000-0000-000000000001', 'FINAL', 0)
  $$,
  '23514',
  'new row for relation "stages" violates check constraint "stages_stage_order_positive"',
  'stage order must be positive'
);

select throws_ok(
  $$
    insert into public.stages (tournament_id, type, stage_order)
    values ('30000000-0000-0000-0000-000000000001', 'FINAL', 1)
  $$,
  '23505',
  'duplicate key value violates unique constraint "stages_tournament_order_unique"',
  'stage order is unique within a tournament'
);

select throws_ok(
  $$
    insert into public.stages (tournament_id, type, stage_order)
    values ('30000000-0000-0000-0000-000000000001', 'SEMI_FINAL', 2)
  $$,
  '23505',
  'duplicate key value violates unique constraint "stages_tournament_type_unique"',
  'stage type is unique within a tournament'
);

insert into public.stages (id, tournament_id, type, stage_order)
values (
  '31000000-0000-0000-0000-000000000002',
  '30000000-0000-0000-0000-000000000001',
  'FINAL',
  2
);

insert into public.matches (
  id,
  tournament_id,
  stage_id,
  bracket_position,
  home_team_id,
  away_team_id
)
values
  (
    '32000000-0000-0000-0000-000000000001',
    '30000000-0000-0000-0000-000000000001',
    '31000000-0000-0000-0000-000000000001',
    1,
    '33000000-0000-0000-0000-000000000001',
    '33000000-0000-0000-0000-000000000002'
  ),
  (
    '32000000-0000-0000-0000-000000000002',
    '30000000-0000-0000-0000-000000000001',
    '31000000-0000-0000-0000-000000000001',
    2,
    '33000000-0000-0000-0000-000000000003',
    '33000000-0000-0000-0000-000000000004'
  );

select throws_ok(
  $$
    insert into public.matches (
      tournament_id,
      stage_id,
      bracket_position,
      home_team_id,
      away_team_id
    )
    values (
      '30000000-0000-0000-0000-000000000001',
      '31000000-0000-0000-0000-000000000002',
      0,
      '33000000-0000-0000-0000-000000000001',
      '33000000-0000-0000-0000-000000000002'
    )
  $$,
  '23514',
  'new row for relation "matches" violates check constraint "matches_bracket_position_positive"',
  'bracket position must be positive'
);

select throws_ok(
  $$
    insert into public.matches (
      tournament_id,
      stage_id,
      bracket_position,
      home_team_id,
      away_team_id
    )
    values (
      '30000000-0000-0000-0000-000000000001',
      '31000000-0000-0000-0000-000000000001',
      1,
      '33000000-0000-0000-0000-000000000001',
      '33000000-0000-0000-0000-000000000002'
    )
  $$,
  '23505',
  'duplicate key value violates unique constraint "matches_stage_position_unique"',
  'bracket position is unique within a stage'
);

select throws_ok(
  $$
    insert into public.matches (
      tournament_id,
      stage_id,
      bracket_position,
      home_source_match_id,
      away_source_match_id
    )
    values (
      '30000000-0000-0000-0000-000000000001',
      '31000000-0000-0000-0000-000000000002',
      1,
      '32000000-0000-0000-0000-000000000001',
      '32000000-0000-0000-0000-000000000001'
    )
  $$,
  '23514',
  'new row for relation "matches" violates check constraint "matches_sources_distinct"',
  'both bracket slots cannot depend on the same source match'
);

select * from finish();
rollback;
