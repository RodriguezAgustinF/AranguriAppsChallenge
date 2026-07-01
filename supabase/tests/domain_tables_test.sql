begin;
select plan(23);

select has_table('public', 'tournaments', 'tournaments table exists');
select has_table('public', 'teams', 'teams table exists');
select has_table('public', 'tournament_teams', 'tournament_teams table exists');
select has_table('public', 'stages', 'stages table exists');
select has_table('public', 'matches', 'matches table exists');
select has_table('public', 'predictions', 'predictions table exists');
select has_table('public', 'tournament_scores', 'tournament_scores table exists');

select col_is_pk('public', 'tournaments', 'id', 'tournaments.id is the primary key');
select col_is_pk('public', 'teams', 'id', 'teams.id is the primary key');
select col_is_pk('public', 'tournament_teams', 'id', 'tournament_teams.id is the primary key');
select col_is_pk('public', 'stages', 'id', 'stages.id is the primary key');
select col_is_pk('public', 'matches', 'id', 'matches.id is the primary key');
select col_is_pk('public', 'predictions', 'id', 'predictions.id is the primary key');
select col_is_pk('public', 'tournament_scores', 'id', 'tournament_scores.id is the primary key');

select has_type('public', 'stage_type', 'stage_type enum exists');

select col_has_check(
  'public',
  'tournaments',
  'team_count',
  'tournaments.team_count has a check constraint'
);

select lives_ok(
  $$
    insert into public.tournaments (name, team_count, starts_at, ends_at)
    values
      ('Four teams', 4, now() + interval '1 day', now() + interval '2 days'),
      ('Eight teams', 8, now() + interval '1 day', now() + interval '2 days'),
      ('Sixteen teams', 16, now() + interval '1 day', now() + interval '2 days'),
      ('Thirty-two teams', 32, now() + interval '1 day', now() + interval '2 days')
  $$,
  'all supported tournament capacities are accepted'
);

select throws_ok(
  $$
    insert into public.tournaments (name, team_count, starts_at, ends_at)
    values ('Unsupported size', 6, now() + interval '1 day', now() + interval '2 days')
  $$,
  '23514',
  'new row for relation "tournaments" violates check constraint "tournaments_team_count_allowed"',
  'unsupported tournament capacities are rejected'
);

select col_not_null('public', 'teams', 'logo_path', 'team image path is required');
select col_has_check('public', 'teams', 'logo_path', 'team image path is validated');

select is(
  (select public from storage.buckets where id = 'team-logos'),
  true,
  'team-logos bucket is public'
);

select is(
  (select file_size_limit from storage.buckets where id = 'team-logos'),
  1048576::bigint,
  'team logos are limited to one MiB'
);

select is(
  (select allowed_mime_types from storage.buckets where id = 'team-logos'),
  array['image/png', 'image/jpeg', 'image/webp']::text[],
  'team logo MIME types are restricted'
);

select * from finish();
rollback;
