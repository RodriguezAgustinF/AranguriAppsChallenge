begin;

create type public.stage_type as enum (
  'ROUND_OF_32',
  'ROUND_OF_16',
  'QUARTER_FINAL',
  'SEMI_FINAL',
  'FINAL'
);

create table public.tournaments (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  team_count integer not null,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  bracket_generated_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.teams (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  abbreviation text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.tournament_teams (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.tournaments (id) on delete cascade,
  team_id uuid not null references public.teams (id) on delete restrict,
  draw_position integer,
  created_at timestamptz not null default now()
);

create table public.stages (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.tournaments (id) on delete cascade,
  type public.stage_type not null,
  stage_order integer not null,
  created_at timestamptz not null default now()
);

create table public.matches (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.tournaments (id) on delete cascade,
  stage_id uuid not null references public.stages (id) on delete cascade,
  bracket_position integer not null,
  home_team_id uuid references public.teams (id) on delete restrict,
  away_team_id uuid references public.teams (id) on delete restrict,
  home_source_match_id uuid references public.matches (id) on delete restrict,
  away_source_match_id uuid references public.matches (id) on delete restrict,
  starts_at timestamptz,
  home_score integer,
  away_score integer,
  penalty_winner_team_id uuid references public.teams (id) on delete restrict,
  result_published_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.predictions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  match_id uuid not null references public.matches (id) on delete restrict,
  home_score integer not null,
  away_score integer not null,
  penalty_winner_team_id uuid references public.teams (id) on delete restrict,
  created_at timestamptz not null default now()
);

create table public.tournament_scores (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  tournament_id uuid not null references public.tournaments (id) on delete cascade,
  points integer not null default 0
);

comment on table public.tournaments is 'Single-elimination football tournaments.';
comment on table public.teams is 'Global catalog of football teams.';
comment on table public.tournament_teams is 'Teams enrolled in a tournament and their persisted draw position.';
comment on table public.stages is 'Rounds generated for a tournament bracket.';
comment on table public.matches is 'Bracket slots, including official results and dependencies on previous matches.';
comment on table public.predictions is 'Score predictions submitted by users for resolved matches.';
comment on table public.tournament_scores is 'Materialized total points and participation per user and tournament.';

commit;
