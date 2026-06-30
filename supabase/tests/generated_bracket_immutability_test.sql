begin;
select plan(10);

insert into public.tournaments (id, name, team_count, starts_at, ends_at)
values ('b0000000-0000-0000-0000-000000000001', 'Locked bracket', 4, now() + interval '1 day', now() + interval '2 days');

insert into public.teams (id, name, abbreviation, logo_path)
values
  ('b1000000-0000-0000-0000-000000000001', 'Lock one', 'LOO', 'teams/lock-one.png'),
  ('b1000000-0000-0000-0000-000000000002', 'Lock two', 'LOT', 'teams/lock-two.png'),
  ('b1000000-0000-0000-0000-000000000003', 'Lock three', 'LOR', 'teams/lock-three.png'),
  ('b1000000-0000-0000-0000-000000000004', 'Lock four', 'LOF', 'teams/lock-four.png');

insert into public.tournament_teams (tournament_id, team_id, draw_position)
select 'b0000000-0000-0000-0000-000000000001', id, row_number() over (order by id)
from public.teams
where id::text like 'b1000000-0000-0000-0000-%';

insert into public.stages (id, tournament_id, type, stage_order)
values
  ('b2000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 'SEMI_FINAL', 1),
  ('b2000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001', 'FINAL', 2);

insert into public.matches (id, tournament_id, stage_id, bracket_position, home_team_id, away_team_id)
values
  ('b3000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 'b2000000-0000-0000-0000-000000000001', 1, 'b1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000002'),
  ('b3000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001', 'b2000000-0000-0000-0000-000000000001', 2, 'b1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000004');

insert into public.matches (id, tournament_id, stage_id, bracket_position, home_source_match_id, away_source_match_id)
values ('b3000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000001', 'b2000000-0000-0000-0000-000000000002', 1, 'b3000000-0000-0000-0000-000000000001', 'b3000000-0000-0000-0000-000000000002');

update public.tournaments
set bracket_generated_at = now()
where id = 'b0000000-0000-0000-0000-000000000001';

select throws_ok($$update public.tournaments set team_count = 8 where id = 'b0000000-0000-0000-0000-000000000001'$$, '55000', 'tournament capacity and bracket generation timestamp are immutable after bracket generation', 'capacity is locked');
select throws_ok($$delete from public.tournament_teams where tournament_id = 'b0000000-0000-0000-0000-000000000001' and team_id = 'b1000000-0000-0000-0000-000000000001'$$, '55000', 'tournament enrollments are immutable after bracket generation', 'enrollments cannot be deleted');
select throws_ok($$update public.tournament_teams set draw_position = 4 where tournament_id = 'b0000000-0000-0000-0000-000000000001' and team_id = 'b1000000-0000-0000-0000-000000000001'$$, '55000', 'tournament enrollments are immutable after bracket generation', 'draw positions are locked');
select throws_ok($$delete from public.stages where id = 'b2000000-0000-0000-0000-000000000001'$$, '55000', 'tournament stages are immutable after bracket generation', 'stages cannot be deleted');
select throws_ok($$update public.stages set stage_order = 3 where id = 'b2000000-0000-0000-0000-000000000002'$$, '55000', 'tournament stages are immutable after bracket generation', 'stages cannot be changed');
select throws_ok($$delete from public.matches where id = 'b3000000-0000-0000-0000-000000000001'$$, '55000', 'bracket matches cannot be inserted or deleted after bracket generation', 'matches cannot be deleted');
select throws_ok($$update public.matches set bracket_position = 2 where id = 'b3000000-0000-0000-0000-000000000003'$$, '55000', 'bracket positions and sources are immutable after bracket generation', 'bracket positions are locked');
select throws_ok($$update public.matches set home_team_id = 'b1000000-0000-0000-0000-000000000001' where id = 'b3000000-0000-0000-0000-000000000003'$$, '55000', 'bracket participants can only advance through the result publication operation', 'participants cannot be changed directly');
select lives_ok($$update public.matches set starts_at = now() + interval '1 day' where id = 'b3000000-0000-0000-0000-000000000003'$$, 'matches can still be scheduled');
select lives_ok($$select set_config('app.allow_bracket_progression', 'true', true); update public.matches set home_team_id = 'b1000000-0000-0000-0000-000000000001' where id = 'b3000000-0000-0000-0000-000000000003'$$, 'an internal result operation can advance a participant');

select * from finish();
rollback;
