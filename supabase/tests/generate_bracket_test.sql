begin;

select plan(15);

insert into auth.users (id, instance_id, aud, role, email, raw_user_meta_data, created_at, updated_at)
values
  ('fa000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'bracket-admin@example.com', '{"name":"Bracket Admin"}', now(), now()),
  ('fa000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'bracket-user@example.com', '{"name":"Bracket User"}', now(), now());

update public.profiles set role = 'ADMIN' where id = 'fa000000-0000-0000-0000-000000000001';

create temporary table seeded_teams (position integer primary key, id uuid not null);
insert into seeded_teams
select position, extensions.gen_random_uuid() from generate_series(1, 32) as position;
insert into public.teams (id, name, abbreviation, logo_path)
select id, 'Bracket Team ' || position, 'B' || position, 'bracket/' || position || '.webp' from seeded_teams;

insert into public.tournaments (id, name, team_count, starts_at, ends_at)
values
  ('fb000000-0000-0000-0000-000000000004', 'Bracket 4', 4, now() + interval '1 day', now() + interval '10 days'),
  ('fb000000-0000-0000-0000-000000000008', 'Bracket 8', 8, now() + interval '1 day', now() + interval '10 days'),
  ('fb000000-0000-0000-0000-000000000016', 'Bracket 16', 16, now() + interval '1 day', now() + interval '10 days'),
  ('fb000000-0000-0000-0000-000000000032', 'Bracket 32', 32, now() + interval '1 day', now() + interval '10 days'),
  ('fb000000-0000-0000-0000-000000000099', 'Incomplete', 4, now() + interval '1 day', now() + interval '10 days');

insert into public.tournament_teams (tournament_id, team_id)
select tournament.id, team.id
from (values
  ('fb000000-0000-0000-0000-000000000004'::uuid, 4),
  ('fb000000-0000-0000-0000-000000000008'::uuid, 8),
  ('fb000000-0000-0000-0000-000000000016'::uuid, 16),
  ('fb000000-0000-0000-0000-000000000032'::uuid, 32)
) as tournament(id, capacity)
join seeded_teams as team on team.position <= tournament.capacity;

set local role authenticated;
set local request.jwt.claims = '{"sub":"fa000000-0000-0000-0000-000000000001","role":"authenticated"}';

select lives_ok($$ select public.generate_bracket('fb000000-0000-0000-0000-000000000004') $$, 'generates a four-team bracket');
select lives_ok($$ select public.generate_bracket('fb000000-0000-0000-0000-000000000008') $$, 'generates an eight-team bracket');
select lives_ok($$ select public.generate_bracket('fb000000-0000-0000-0000-000000000016') $$, 'generates a sixteen-team bracket');
select lives_ok($$ select public.generate_bracket('fb000000-0000-0000-0000-000000000032') $$, 'generates a thirty-two-team bracket');

select is((select count(*) from public.matches where tournament_id = 'fb000000-0000-0000-0000-000000000004'), 3::bigint, 'four teams create three matches');
select is((select count(*) from public.matches where tournament_id = 'fb000000-0000-0000-0000-000000000008'), 7::bigint, 'eight teams create seven matches');
select is((select count(*) from public.matches where tournament_id = 'fb000000-0000-0000-0000-000000000016'), 15::bigint, 'sixteen teams create fifteen matches');
select is((select count(*) from public.matches where tournament_id = 'fb000000-0000-0000-0000-000000000032'), 31::bigint, 'thirty-two teams create thirty-one matches');

select is((select count(*) from public.stages where tournament_id = 'fb000000-0000-0000-0000-000000000004'), 2::bigint, 'four teams create two stages');
select is((select count(*) from public.stages where tournament_id = 'fb000000-0000-0000-0000-000000000008'), 3::bigint, 'eight teams create three stages');
select is((select count(*) from public.stages where tournament_id = 'fb000000-0000-0000-0000-000000000016'), 4::bigint, 'sixteen teams create four stages');
select is((select count(*) from public.stages where tournament_id = 'fb000000-0000-0000-0000-000000000032'), 5::bigint, 'thirty-two teams create five stages');

select is((select count(distinct draw_position) from public.tournament_teams where tournament_id = 'fb000000-0000-0000-0000-000000000032'), 32::bigint, 'draw positions are complete and unique');
select throws_ok($$ select public.generate_bracket('fb000000-0000-0000-0000-000000000004') $$, '55000', 'bracket was already generated', 'a bracket cannot be generated twice');
select throws_ok($$ select public.generate_bracket('fb000000-0000-0000-0000-000000000099') $$, '23514', 'tournament must have exactly its configured team capacity', 'an incomplete tournament cannot be drawn');

reset role;
select * from finish();
rollback;
