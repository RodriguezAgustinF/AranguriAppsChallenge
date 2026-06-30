begin;

select plan(5);

insert into public.tournaments (id, name, team_count, starts_at, ends_at)
values (
  'f1000000-0000-0000-0000-000000000001',
  'Published result immutability',
  4,
  now() + interval '1 day',
  now() + interval '2 days'
);

insert into public.stages (id, tournament_id, type, stage_order)
values (
  'f1100000-0000-0000-0000-000000000001',
  'f1000000-0000-0000-0000-000000000001',
  'SEMI_FINAL',
  1
);

insert into public.teams (id, name, abbreviation, logo_path)
values
  ('f1200000-0000-0000-0000-000000000001', 'Immutable Home', 'IMH', 'immutable/home.webp'),
  ('f1200000-0000-0000-0000-000000000002', 'Immutable Away', 'IMA', 'immutable/away.webp');

insert into public.tournament_teams (tournament_id, team_id)
values
  ('f1000000-0000-0000-0000-000000000001', 'f1200000-0000-0000-0000-000000000001'),
  ('f1000000-0000-0000-0000-000000000001', 'f1200000-0000-0000-0000-000000000002');

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
    'f1300000-0000-0000-0000-000000000001',
    'f1000000-0000-0000-0000-000000000001',
    'f1100000-0000-0000-0000-000000000001',
    1,
    'f1200000-0000-0000-0000-000000000001',
    'f1200000-0000-0000-0000-000000000002'
  ),
  (
    'f1300000-0000-0000-0000-000000000002',
    'f1000000-0000-0000-0000-000000000001',
    'f1100000-0000-0000-0000-000000000001',
    2,
    'f1200000-0000-0000-0000-000000000001',
    'f1200000-0000-0000-0000-000000000002'
  );

select lives_ok(
  $$
    update public.matches
    set home_score = 2,
        away_score = 1,
        result_published_at = now()
    where id = 'f1300000-0000-0000-0000-000000000001'
  $$,
  'an unpublished match can receive its official result'
);

select throws_ok(
  $$
    update public.matches
    set home_score = 3
    where id = 'f1300000-0000-0000-0000-000000000001'
  $$,
  '55000',
  'a match with an official result is immutable',
  'a published score cannot be changed'
);

select throws_ok(
  $$
    update public.matches
    set starts_at = now() + interval '36 hours'
    where id = 'f1300000-0000-0000-0000-000000000001'
  $$,
  '55000',
  'a match with an official result is immutable',
  'published match metadata cannot be changed'
);

select throws_ok(
  $$
    delete from public.matches
    where id = 'f1300000-0000-0000-0000-000000000001'
  $$,
  '55000',
  'a match with an official result is immutable',
  'a match with a published result cannot be deleted'
);

select lives_ok(
  $$
    delete from public.matches
    where id = 'f1300000-0000-0000-0000-000000000002'
  $$,
  'an unpublished match is not blocked by result immutability'
);

select * from finish();

rollback;
