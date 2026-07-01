begin;
select plan(5);

insert into public.tournaments (id, name, team_count, starts_at, ends_at)
values (
  '90000000-0000-0000-0000-000000000001',
  'Initial bracket shape',
  4,
  now() + interval '1 day',
  now() + interval '2 days'
);

insert into public.stages (id, tournament_id, type, stage_order)
values
  ('91000000-0000-0000-0000-000000000001', '90000000-0000-0000-0000-000000000001', 'SEMI_FINAL', 1),
  ('91000000-0000-0000-0000-000000000002', '90000000-0000-0000-0000-000000000001', 'FINAL', 2);

insert into public.teams (id, name, abbreviation, logo_path)
values
  ('92000000-0000-0000-0000-000000000001', 'Bracket one', 'BRO', 'teams/bracket-one.png'),
  ('92000000-0000-0000-0000-000000000002', 'Bracket two', 'BRT', 'teams/bracket-two.png'),
  ('92000000-0000-0000-0000-000000000003', 'Bracket three', 'BRH', 'teams/bracket-three.png'),
  ('92000000-0000-0000-0000-000000000004', 'Bracket four', 'BRF', 'teams/bracket-four.png');

insert into public.tournament_teams (tournament_id, team_id)
select '90000000-0000-0000-0000-000000000001', id
from public.teams
where id in (
  '92000000-0000-0000-0000-000000000001',
  '92000000-0000-0000-0000-000000000002',
  '92000000-0000-0000-0000-000000000003',
  '92000000-0000-0000-0000-000000000004'
);

select lives_ok(
  $$
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
        '93000000-0000-0000-0000-000000000001',
        '90000000-0000-0000-0000-000000000001',
        '91000000-0000-0000-0000-000000000001',
        1,
        '92000000-0000-0000-0000-000000000001',
        '92000000-0000-0000-0000-000000000002'
      ),
      (
        '93000000-0000-0000-0000-000000000002',
        '90000000-0000-0000-0000-000000000001',
        '91000000-0000-0000-0000-000000000001',
        2,
        '92000000-0000-0000-0000-000000000003',
        '92000000-0000-0000-0000-000000000004'
      )
  $$,
  'initial matches start with two teams and no sources'
);

select lives_ok(
  $$
    insert into public.matches (
      tournament_id,
      stage_id,
      bracket_position,
      home_source_match_id,
      away_source_match_id
    )
    values (
      '90000000-0000-0000-0000-000000000001',
      '91000000-0000-0000-0000-000000000002',
      1,
      '93000000-0000-0000-0000-000000000001',
      '93000000-0000-0000-0000-000000000002'
    )
  $$,
  'dependent matches start with two sources and no teams'
);

select throws_ok(
  $$
    insert into public.matches (
      tournament_id,
      stage_id,
      bracket_position,
      home_team_id
    )
    values (
      '90000000-0000-0000-0000-000000000001',
      '91000000-0000-0000-0000-000000000001',
      3,
      '92000000-0000-0000-0000-000000000001'
    )
  $$,
  '23514',
  'initial bracket matches require both teams and no sources',
  'an initial match cannot start with only one team'
);

select throws_ok(
  $$
    insert into public.matches (
      tournament_id,
      stage_id,
      bracket_position,
      home_team_id,
      home_source_match_id,
      away_source_match_id
    )
    values (
      '90000000-0000-0000-0000-000000000001',
      '91000000-0000-0000-0000-000000000002',
      2,
      '92000000-0000-0000-0000-000000000001',
      '93000000-0000-0000-0000-000000000001',
      '93000000-0000-0000-0000-000000000002'
    )
  $$,
  '23514',
  'dependent bracket matches require two sources and no teams on insert',
  'a dependent match cannot start with a resolved team'
);

select throws_ok(
  $$
    insert into public.matches (
      tournament_id,
      stage_id,
      bracket_position,
      home_source_match_id
    )
    values (
      '90000000-0000-0000-0000-000000000001',
      '91000000-0000-0000-0000-000000000002',
      3,
      '93000000-0000-0000-0000-000000000001'
    )
  $$,
  '23514',
  'bracket matches require either zero or two sources',
  'a dependent match cannot start with only one source'
);

select * from finish();
rollback;
