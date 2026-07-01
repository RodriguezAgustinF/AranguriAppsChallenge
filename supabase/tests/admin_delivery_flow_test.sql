begin;
select plan(10);

insert into auth.users (id, instance_id, aud, role, email, raw_user_meta_data, created_at, updated_at)
values ('ac000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'acceptance-admin@example.com', '{}'::jsonb, now(), now());
update public.profiles set role = 'ADMIN' where id = 'ac000000-0000-0000-0000-000000000001';

insert into public.tournaments (id, name, team_count, starts_at)
values ('ac100000-0000-0000-0000-000000000001', 'Acceptance Cup', 4, now() + interval '1 day');
insert into public.teams (id, name, abbreviation, logo_path)
values
  ('ac200000-0000-0000-0000-000000000001', 'Acceptance A', 'ACA', 'acceptance/a.webp'),
  ('ac200000-0000-0000-0000-000000000002', 'Acceptance B', 'ACB', 'acceptance/b.webp'),
  ('ac200000-0000-0000-0000-000000000003', 'Acceptance C', 'ACC', 'acceptance/c.webp'),
  ('ac200000-0000-0000-0000-000000000004', 'Acceptance D', 'ACD', 'acceptance/d.webp');
insert into public.tournament_teams (tournament_id, team_id)
select 'ac100000-0000-0000-0000-000000000001', id
from public.teams where id::text like 'ac200000-0000-0000-0000-%';

set local role authenticated;
set local request.jwt.claims = '{"sub":"ac000000-0000-0000-0000-000000000001","role":"authenticated"}';
select lives_ok($$select public.generate_bracket('ac100000-0000-0000-0000-000000000001')$$, 'the administrator generates the bracket');
select is((select count(*) from public.stages where tournament_id = 'ac100000-0000-0000-0000-000000000001'), 2::bigint, 'a four-team bracket has two stages');
select is((select count(*) from public.matches where tournament_id = 'ac100000-0000-0000-0000-000000000001'), 3::bigint, 'a four-team bracket has three matches');
select lives_ok($$update public.matches set starts_at = now() + interval '2 days' where tournament_id = 'ac100000-0000-0000-0000-000000000001'$$, 'the administrator schedules every generated match');
select is((select count(*) from public.matches where tournament_id = 'ac100000-0000-0000-0000-000000000001' and starts_at is not null), 3::bigint, 'all matches remain scheduled');

reset role;
alter table public.matches disable trigger validate_match_start_before_write;
update public.matches set starts_at = now() - interval '1 minute' where tournament_id = 'ac100000-0000-0000-0000-000000000001';
alter table public.matches enable trigger validate_match_start_before_write;
set local role authenticated;
set local request.jwt.claims = '{"sub":"ac000000-0000-0000-0000-000000000001","role":"authenticated"}';
select lives_ok($$select public.publish_match_result((select match.id from public.matches as match join public.stages as stage on stage.id = match.stage_id where match.tournament_id = 'ac100000-0000-0000-0000-000000000001' and stage.type = 'SEMI_FINAL' and match.bracket_position = 1), 2, 1, null)$$, 'the first semifinal advances its winner');
select lives_ok($$select public.publish_match_result((select match.id from public.matches as match join public.stages as stage on stage.id = match.stage_id where match.tournament_id = 'ac100000-0000-0000-0000-000000000001' and stage.type = 'SEMI_FINAL' and match.bracket_position = 2), 0, 0, (select match.away_team_id from public.matches as match join public.stages as stage on stage.id = match.stage_id where match.tournament_id = 'ac100000-0000-0000-0000-000000000001' and stage.type = 'SEMI_FINAL' and match.bracket_position = 2))$$, 'the second semifinal resolves penalties and advances its winner');
select lives_ok($$select public.publish_match_result((select match.id from public.matches as match join public.stages as stage on stage.id = match.stage_id where match.tournament_id = 'ac100000-0000-0000-0000-000000000001' and stage.type = 'FINAL'), 3, 1, null)$$, 'the administrator publishes the final');

reset role;
set local role anon;
select is((select status from public.tournament_overview where id = 'ac100000-0000-0000-0000-000000000001'), 'FINISHED', 'the public view shows the tournament as finished');
select isnt((select champion_team_id from public.tournament_overview where id = 'ac100000-0000-0000-0000-000000000001'), null, 'the public view exposes the champion');

reset role;
select * from finish();
rollback;
