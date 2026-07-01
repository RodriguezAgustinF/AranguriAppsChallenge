begin;
select plan(5);

insert into public.tournaments (id, name, team_count, starts_at, ends_at)
values (
  '80000000-0000-0000-0000-000000000001',
  'Result completeness',
  4,
  now() + interval '1 day',
  now() + interval '2 days'
);

insert into public.stages (id, tournament_id, type, stage_order)
values (
  '81000000-0000-0000-0000-000000000001',
  '80000000-0000-0000-0000-000000000001',
  'SEMI_FINAL',
  1
);

insert into public.teams (id, name, abbreviation, logo_path)
values
  ('83000000-0000-0000-0000-000000000001', 'Result home', 'REH', 'teams/result-home.png'),
  ('83000000-0000-0000-0000-000000000002', 'Result away', 'REA', 'teams/result-away.png');

insert into public.tournament_teams (tournament_id, team_id)
values
  ('80000000-0000-0000-0000-000000000001', '83000000-0000-0000-0000-000000000001'),
  ('80000000-0000-0000-0000-000000000001', '83000000-0000-0000-0000-000000000002');

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
    '82000000-0000-0000-0000-000000000001',
    '80000000-0000-0000-0000-000000000001',
    '81000000-0000-0000-0000-000000000001',
    1,
    '83000000-0000-0000-0000-000000000001',
    '83000000-0000-0000-0000-000000000002'
  ),
  (
    '82000000-0000-0000-0000-000000000002',
    '80000000-0000-0000-0000-000000000001',
    '81000000-0000-0000-0000-000000000001',
    2,
    '83000000-0000-0000-0000-000000000001',
    '83000000-0000-0000-0000-000000000002'
  );

select lives_ok(
  $$
    update public.matches
    set home_score = null,
        away_score = null,
        result_published_at = null
    where id = '82000000-0000-0000-0000-000000000001'
  $$,
  'an unpublished match has no official score'
);

select lives_ok(
  $$
    update public.matches
    set home_score = 2,
        away_score = 1,
        result_published_at = now()
    where id = '82000000-0000-0000-0000-000000000001'
  $$,
  'a complete official result includes both scores and publication time'
);

select throws_ok(
  $$
    update public.matches
    set home_score = 1
    where id = '82000000-0000-0000-0000-000000000002'
  $$,
  '23514',
  'new row for relation "matches" violates check constraint "matches_official_scores_complete"',
  'an official result cannot contain only one score'
);

select throws_ok(
  $$
    update public.matches
    set home_score = 1,
        away_score = 0
    where id = '82000000-0000-0000-0000-000000000002'
  $$,
  '23514',
  'new row for relation "matches" violates check constraint "matches_result_publication_coherent"',
  'official scores require a publication time'
);

select throws_ok(
  $$
    update public.matches
    set result_published_at = now()
    where id = '82000000-0000-0000-0000-000000000002'
  $$,
  '23514',
  'new row for relation "matches" violates check constraint "matches_result_publication_coherent"',
  'a publication time requires official scores'
);

select * from finish();
rollback;
