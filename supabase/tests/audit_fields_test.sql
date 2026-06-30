begin;

select plan(10);

select has_column('public', 'profiles', 'updated_at', 'profiles has updated_at');
select has_column('public', 'tournaments', 'updated_at', 'tournaments has updated_at');
select has_column('public', 'teams', 'updated_at', 'teams has updated_at');
select has_column('public', 'tournament_teams', 'updated_at', 'tournament_teams has updated_at');
select has_column('public', 'stages', 'updated_at', 'stages has updated_at');
select has_column('public', 'matches', 'updated_at', 'matches has updated_at');
select has_column('public', 'predictions', 'updated_at', 'predictions has updated_at');
select has_column('public', 'tournament_scores', 'created_at', 'tournament_scores has created_at');
select has_column('public', 'tournament_scores', 'updated_at', 'tournament_scores has updated_at');

insert into public.teams (id, name, abbreviation, logo_path, updated_at)
values (
  'f0000000-0000-0000-0000-000000000001',
  'Audit Team',
  'AUD',
  'audit-team.webp',
  '2000-01-01 00:00:00+00'
);

update public.teams
set name = 'Updated Audit Team'
where id = 'f0000000-0000-0000-0000-000000000001';

select ok(
  updated_at > '2000-01-01 00:00:00+00'::timestamptz,
  'updated_at is refreshed automatically when a row changes'
)
from public.teams
where id = 'f0000000-0000-0000-0000-000000000001';

select * from finish();

rollback;
