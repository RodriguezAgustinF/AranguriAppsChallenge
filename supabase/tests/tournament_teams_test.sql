begin;
select plan(4);

insert into public.tournaments (id, name, team_count, starts_at, ends_at)
values
  ('10000000-0000-0000-0000-000000000001', 'Tournament one', 4, now() + interval '1 day', now() + interval '2 days'),
  ('10000000-0000-0000-0000-000000000002', 'Tournament two', 4, now() + interval '1 day', now() + interval '2 days');

insert into public.teams (id, name, abbreviation, logo_path)
values
  ('20000000-0000-0000-0000-000000000001', 'Team one', 'ONE', 'teams/one.png'),
  ('20000000-0000-0000-0000-000000000002', 'Team two', 'TWO', 'teams/two.png'),
  ('20000000-0000-0000-0000-000000000003', 'Team three', 'THR', 'teams/three.png');

select lives_ok(
  $$
    insert into public.tournament_teams (tournament_id, team_id)
    values
      ('10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001'),
      ('10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001')
  $$,
  'the same team can participate in different tournaments'
);

select lives_ok(
  $$
    insert into public.tournament_teams (tournament_id, team_id)
    values
      ('10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002'),
      ('10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003')
  $$,
  'multiple pending draw positions are allowed before the draw'
);

select throws_ok(
  $$
    insert into public.tournament_teams (tournament_id, team_id)
    values ('10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001')
  $$,
  '23505',
  'duplicate key value violates unique constraint "tournament_teams_tournament_team_unique"',
  'a team cannot be enrolled twice in one tournament'
);

update public.tournament_teams
set draw_position = case team_id
  when '20000000-0000-0000-0000-000000000001' then 1
  when '20000000-0000-0000-0000-000000000002' then 2
end
where tournament_id = '10000000-0000-0000-0000-000000000001'
  and team_id in (
    '20000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000002'
  );

select throws_ok(
  $$
    update public.tournament_teams
    set draw_position = 1
    where tournament_id = '10000000-0000-0000-0000-000000000001'
      and team_id = '20000000-0000-0000-0000-000000000003'
  $$,
  '23505',
  'duplicate key value violates unique constraint "tournament_teams_tournament_draw_position_unique"',
  'a draw position cannot be repeated within one tournament'
);

select * from finish();
rollback;
