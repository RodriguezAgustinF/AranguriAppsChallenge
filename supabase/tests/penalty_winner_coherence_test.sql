begin;
select plan(8);

insert into public.tournaments (id, name, team_count, starts_at, ends_at)
values (
  'a0000000-0000-0000-0000-000000000001',
  'Penalty coherence',
  4,
  now() + interval '1 day',
  now() + interval '2 days'
);

insert into public.stages (id, tournament_id, type, stage_order)
values (
  'a1000000-0000-0000-0000-000000000001',
  'a0000000-0000-0000-0000-000000000001',
  'SEMI_FINAL',
  1
);

insert into public.teams (id, name, abbreviation, logo_path)
values
  ('a2000000-0000-0000-0000-000000000001', 'Penalty home', 'PEH', 'teams/penalty-home.png'),
  ('a2000000-0000-0000-0000-000000000002', 'Penalty away', 'PEA', 'teams/penalty-away.png'),
  ('a2000000-0000-0000-0000-000000000003', 'Penalty outsider', 'PEO', 'teams/penalty-outsider.png');

insert into public.tournament_teams (tournament_id, team_id)
select 'a0000000-0000-0000-0000-000000000001', id
from public.teams
where id::text like 'a2000000-0000-0000-0000-%';

insert into public.matches (
  id,
  tournament_id,
  stage_id,
  bracket_position,
  home_team_id,
  away_team_id
)
values (
  'a3000000-0000-0000-0000-000000000001',
  'a0000000-0000-0000-0000-000000000001',
  'a1000000-0000-0000-0000-000000000001',
  1,
  'a2000000-0000-0000-0000-000000000001',
  'a2000000-0000-0000-0000-000000000002'
);

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
  'a4000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'penalties@example.com',
  '{"name":"Penalties"}'::jsonb,
  now(),
  now()
);

select lives_ok(
  $$
    update public.matches
    set home_score = 1,
        away_score = 1,
        penalty_winner_team_id = 'a2000000-0000-0000-0000-000000000001',
        result_published_at = now()
    where id = 'a3000000-0000-0000-0000-000000000001'
  $$,
  'a tied official result accepts a participating penalty winner'
);

select throws_ok(
  $$
    update public.matches
    set penalty_winner_team_id = null
    where id = 'a3000000-0000-0000-0000-000000000001'
  $$,
  '23514',
  'new row for relation "matches" violates check constraint "matches_penalty_winner_coherent"',
  'a tied official result requires a penalty winner'
);

select throws_ok(
  $$
    update public.matches
    set home_score = 2,
        away_score = 1
    where id = 'a3000000-0000-0000-0000-000000000001'
  $$,
  '23514',
  'new row for relation "matches" violates check constraint "matches_penalty_winner_coherent"',
  'a non-tied official result forbids a penalty winner'
);

select throws_ok(
  $$
    update public.matches
    set penalty_winner_team_id = 'a2000000-0000-0000-0000-000000000003'
    where id = 'a3000000-0000-0000-0000-000000000001'
  $$,
  '23514',
  'new row for relation "matches" violates check constraint "matches_penalty_winner_coherent"',
  'an official penalty winner must participate in the match'
);

select lives_ok(
  $$
    insert into public.predictions (
      user_id,
      match_id,
      home_score,
      away_score,
      penalty_winner_team_id
    )
    values (
      'a4000000-0000-0000-0000-000000000001',
      'a3000000-0000-0000-0000-000000000001',
      0,
      0,
      'a2000000-0000-0000-0000-000000000002'
    )
  $$,
  'a tied prediction accepts a participating penalty winner'
);

select throws_ok(
  $$
    update public.predictions
    set penalty_winner_team_id = null
    where user_id = 'a4000000-0000-0000-0000-000000000001'
      and match_id = 'a3000000-0000-0000-0000-000000000001'
  $$,
  '23514',
  'new row for relation "predictions" violates check constraint "predictions_penalty_winner_required_on_draw"',
  'a tied prediction requires a penalty winner'
);

select throws_ok(
  $$
    update public.predictions
    set home_score = 2,
        away_score = 1
    where user_id = 'a4000000-0000-0000-0000-000000000001'
      and match_id = 'a3000000-0000-0000-0000-000000000001'
  $$,
  '23514',
  'new row for relation "predictions" violates check constraint "predictions_penalty_winner_required_on_draw"',
  'a non-tied prediction forbids a penalty winner'
);

select throws_ok(
  $$
    update public.predictions
    set penalty_winner_team_id = 'a2000000-0000-0000-0000-000000000003'
    where user_id = 'a4000000-0000-0000-0000-000000000001'
      and match_id = 'a3000000-0000-0000-0000-000000000001'
  $$,
  '23514',
  'penalty winner must be a participant of the predicted match',
  'a predicted penalty winner must participate in the match'
);

select * from finish();
rollback;
