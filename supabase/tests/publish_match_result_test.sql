begin;
select plan(21);

insert into auth.users (id, instance_id, aud, role, email, raw_user_meta_data, created_at, updated_at)
values
  ('e0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'result-admin@example.com', '{}'::jsonb, now(), now()),
  ('e0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'predictor-exact@example.com', '{}'::jsonb, now(), now()),
  ('e0000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'predictor-winner@example.com', '{}'::jsonb, now(), now()),
  ('e0000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'predictor-wrong@example.com', '{}'::jsonb, now(), now());
update public.profiles set role = 'ADMIN' where id = 'e0000000-0000-0000-0000-000000000001';

insert into public.tournaments (id, name, team_count, starts_at)
values ('e1000000-0000-0000-0000-000000000001', 'Result publication', 4, now() + interval '1 day');
insert into public.teams (id, name, abbreviation, logo_path)
values
  ('e2000000-0000-0000-0000-000000000001', 'Result A', 'RPA', 'tests/result-a.webp'),
  ('e2000000-0000-0000-0000-000000000002', 'Result B', 'RPB', 'tests/result-b.webp'),
  ('e2000000-0000-0000-0000-000000000003', 'Result C', 'RPC', 'tests/result-c.webp'),
  ('e2000000-0000-0000-0000-000000000004', 'Result D', 'RPD', 'tests/result-d.webp');
insert into public.tournament_teams (tournament_id, team_id, draw_position)
select 'e1000000-0000-0000-0000-000000000001', id, row_number() over (order by id)
from public.teams where id::text like 'e2000000-0000-0000-0000-%';
insert into public.stages (id, tournament_id, type, stage_order)
values
  ('e3000000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000001', 'SEMI_FINAL', 1),
  ('e3000000-0000-0000-0000-000000000002', 'e1000000-0000-0000-0000-000000000001', 'FINAL', 2);
insert into public.matches (id, tournament_id, stage_id, bracket_position, home_team_id, away_team_id)
values
  ('e4000000-0000-0000-0000-000000000001', 'e1000000-0000-0000-0000-000000000001', 'e3000000-0000-0000-0000-000000000001', 1, 'e2000000-0000-0000-0000-000000000001', 'e2000000-0000-0000-0000-000000000002'),
  ('e4000000-0000-0000-0000-000000000002', 'e1000000-0000-0000-0000-000000000001', 'e3000000-0000-0000-0000-000000000001', 2, 'e2000000-0000-0000-0000-000000000003', 'e2000000-0000-0000-0000-000000000004');
insert into public.matches (id, tournament_id, stage_id, bracket_position, home_source_match_id, away_source_match_id)
values ('e4000000-0000-0000-0000-000000000003', 'e1000000-0000-0000-0000-000000000001', 'e3000000-0000-0000-0000-000000000002', 1, 'e4000000-0000-0000-0000-000000000001', 'e4000000-0000-0000-0000-000000000002');
update public.tournaments set bracket_generated_at = now() where id = 'e1000000-0000-0000-0000-000000000001';

insert into public.predictions (user_id, match_id, home_score, away_score, penalty_winner_team_id)
values
  ('e0000000-0000-0000-0000-000000000002', 'e4000000-0000-0000-0000-000000000001', 1, 1, 'e2000000-0000-0000-0000-000000000001'),
  ('e0000000-0000-0000-0000-000000000003', 'e4000000-0000-0000-0000-000000000001', 2, 2, 'e2000000-0000-0000-0000-000000000001'),
  ('e0000000-0000-0000-0000-000000000004', 'e4000000-0000-0000-0000-000000000001', 1, 1, 'e2000000-0000-0000-0000-000000000002');
insert into public.tournament_scores (user_id, tournament_id)
values
  ('e0000000-0000-0000-0000-000000000002', 'e1000000-0000-0000-0000-000000000001'),
  ('e0000000-0000-0000-0000-000000000003', 'e1000000-0000-0000-0000-000000000001'),
  ('e0000000-0000-0000-0000-000000000004', 'e1000000-0000-0000-0000-000000000001');

alter table public.matches disable trigger validate_match_start_before_write;
update public.matches set starts_at = now() - interval '1 hour' where id = 'e4000000-0000-0000-0000-000000000001';
update public.matches set starts_at = now() + interval '2 days' where id = 'e4000000-0000-0000-0000-000000000002';
alter table public.matches enable trigger validate_match_start_before_write;

set local role authenticated;
set local request.jwt.claims = '{"sub":"e0000000-0000-0000-0000-000000000004","role":"authenticated"}';
select throws_ok($$select public.publish_match_result('e4000000-0000-0000-0000-000000000001', 1, 1, 'e2000000-0000-0000-0000-000000000001')$$, '42501', 'only administrators can publish match results', 'a USER cannot publish a result');

set local request.jwt.claims = '{"sub":"e0000000-0000-0000-0000-000000000001","role":"authenticated"}';
select throws_ok($$select public.publish_match_result('e4000000-0000-0000-0000-000000000001', 1, 1, null)$$, '23514', 'a drawn match requires a participating penalty winner', 'a draw requires a penalty winner');
select throws_ok($$select public.publish_match_result('e4000000-0000-0000-0000-000000000001', 2, 1, 'e2000000-0000-0000-0000-000000000001')$$, '23514', 'a non-drawn match cannot have a penalty winner', 'a decisive score rejects a penalty winner');
select lives_ok($$select public.publish_match_result('e4000000-0000-0000-0000-000000000001', 1, 1, 'e2000000-0000-0000-0000-000000000001')$$, 'an ADMIN publishes a coherent draw');
select is((select home_score from public.matches where id = 'e4000000-0000-0000-0000-000000000001'), 1, 'the official score is stored');
select is((select home_team_id from public.matches where id = 'e4000000-0000-0000-0000-000000000003'), 'e2000000-0000-0000-0000-000000000001'::uuid, 'the winner advances to the correct final slot');
reset role;
select is((select points from public.tournament_scores where user_id = 'e0000000-0000-0000-0000-000000000002'), 6, 'an exact score and penalty winner awards 6 points');
select is((select points from public.tournament_scores where user_id = 'e0000000-0000-0000-0000-000000000003'), 3, 'the correct advancing team awards 3 points');
select is((select points from public.tournament_scores where user_id = 'e0000000-0000-0000-0000-000000000004'), 0, 'the wrong advancing team awards 0 points');
set local role authenticated;
select lives_ok($$select public.publish_match_result('e4000000-0000-0000-0000-000000000001', 1, 1, 'e2000000-0000-0000-0000-000000000001')$$, 'an identical retry is idempotent');
reset role;
select is((select points from public.tournament_scores where user_id = 'e0000000-0000-0000-0000-000000000002'), 6, 'an idempotent retry does not award points twice');
set local role authenticated;
select throws_ok($$select public.publish_match_result('e4000000-0000-0000-0000-000000000001', 2, 1, null)$$, '55000', 'a match with an official result is immutable', 'a different retry is rejected');
select throws_ok($$select public.publish_match_result('e4000000-0000-0000-0000-000000000002', 2, 0, null)$$, '23514', 'the match must have started before publishing its result', 'a future match cannot receive a result');

reset role;
select isnt((select result_published_at from public.matches where id = 'e4000000-0000-0000-0000-000000000001'), null, 'the result has a publication timestamp');
select is((select away_team_id from public.matches where id = 'e4000000-0000-0000-0000-000000000003'), null, 'the other final slot remains unresolved');
select is((select status from public.tournament_overview where id = 'e1000000-0000-0000-0000-000000000001'), 'UPCOMING', 'the tournament is not finished before the final result');

alter table public.matches disable trigger validate_match_start_before_write;
update public.matches set starts_at = now() - interval '1 hour' where id in ('e4000000-0000-0000-0000-000000000002', 'e4000000-0000-0000-0000-000000000003');
alter table public.matches enable trigger validate_match_start_before_write;
set local role authenticated;
set local request.jwt.claims = '{"sub":"e0000000-0000-0000-0000-000000000001","role":"authenticated"}';
select lives_ok($$select public.publish_match_result('e4000000-0000-0000-0000-000000000002', 2, 0, null)$$, 'the other semifinal result is published');
reset role;
select is((select away_team_id from public.matches where id = 'e4000000-0000-0000-0000-000000000003'), 'e2000000-0000-0000-0000-000000000003'::uuid, 'the second winner completes the final');
set local role authenticated;
select lives_ok($$select public.publish_match_result('e4000000-0000-0000-0000-000000000003', 3, 1, null)$$, 'the final result is published');
reset role;
select is((select status from public.tournament_overview where id = 'e1000000-0000-0000-0000-000000000001'), 'FINISHED', 'the final result finishes the tournament');
select is((select champion_team_id from public.tournament_overview where id = 'e1000000-0000-0000-0000-000000000001'), 'e2000000-0000-0000-0000-000000000001'::uuid, 'the final winner is the tournament champion');

select * from finish();
rollback;
