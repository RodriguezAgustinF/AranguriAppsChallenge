begin;
select plan(6);

insert into public.tournaments (id, name, team_count, starts_at, ends_at)
values
  ('d0000000-0000-0000-0000-000000000001', 'Upcoming', 4, now() + interval '2 days', now() + interval '3 days'),
  ('d0000000-0000-0000-0000-000000000002', 'In progress', 4, now() + interval '2 days', now() + interval '3 days'),
  ('d0000000-0000-0000-0000-000000000003', 'Overdue', 4, now() + interval '2 days', now() + interval '3 days'),
  ('d0000000-0000-0000-0000-000000000004', 'Finished', 4, now() + interval '2 days', now() + interval '3 days'),
  ('d0000000-0000-0000-0000-000000000005', 'Started without bracket', 4, now() + interval '2 days', now() + interval '3 days');

insert into public.teams (id, name, abbreviation, logo_path)
values
  ('d1000000-0000-0000-0000-000000000001', 'Champion', 'CHA', 'teams/champion.png'),
  ('d1000000-0000-0000-0000-000000000002', 'Runner up', 'RUN', 'teams/runner-up.png');

insert into public.tournament_teams (tournament_id, team_id)
values
  ('d0000000-0000-0000-0000-000000000004', 'd1000000-0000-0000-0000-000000000001'),
  ('d0000000-0000-0000-0000-000000000004', 'd1000000-0000-0000-0000-000000000002');

insert into public.stages (id, tournament_id, type, stage_order)
values ('d2000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000004', 'FINAL', 1);

insert into public.matches (id, tournament_id, stage_id, bracket_position, home_team_id, away_team_id)
values ('d3000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000004', 'd2000000-0000-0000-0000-000000000001', 1, 'd1000000-0000-0000-0000-000000000001', 'd1000000-0000-0000-0000-000000000002');

update public.matches
set home_score = 2,
    away_score = 1,
    result_published_at = now()
where id = 'd3000000-0000-0000-0000-000000000001';

alter table public.tournaments disable trigger validate_tournament_dates_before_write;
update public.tournaments
set starts_at = case id
      when 'd0000000-0000-0000-0000-000000000002' then now() - interval '1 hour'
      else now() - interval '2 days'
    end,
    ends_at = case id
      when 'd0000000-0000-0000-0000-000000000002' then now() + interval '1 day'
      else now() - interval '1 day'
    end
where id in (
  'd0000000-0000-0000-0000-000000000002',
  'd0000000-0000-0000-0000-000000000003',
  'd0000000-0000-0000-0000-000000000004',
  'd0000000-0000-0000-0000-000000000005'
);
alter table public.tournaments enable trigger validate_tournament_dates_before_write;

update public.tournaments
set bracket_generated_at = now()
where id in (
  'd0000000-0000-0000-0000-000000000002',
  'd0000000-0000-0000-0000-000000000003'
);

select is((select status from public.tournament_overview where id = 'd0000000-0000-0000-0000-000000000001'), 'UPCOMING', 'future tournament is upcoming');
select is((select status from public.tournament_overview where id = 'd0000000-0000-0000-0000-000000000002'), 'IN_PROGRESS', 'started tournament is in progress');
select is((select status from public.tournament_overview where id = 'd0000000-0000-0000-0000-000000000003'), 'IN_PROGRESS', 'overdue tournament remains in progress');
select is((select status from public.tournament_overview where id = 'd0000000-0000-0000-0000-000000000004'), 'FINISHED', 'final result finishes the tournament');
select is((select status from public.tournament_overview where id = 'd0000000-0000-0000-0000-000000000005'), 'UPCOMING', 'started tournament without a bracket remains upcoming');
select is((select champion_team_id from public.tournament_overview where id = 'd0000000-0000-0000-0000-000000000004'), 'd1000000-0000-0000-0000-000000000001'::uuid, 'final result derives the champion');

select * from finish();
rollback;
