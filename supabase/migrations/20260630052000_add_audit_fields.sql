begin;

alter table public.profiles
  add column updated_at timestamptz not null default now();

alter table public.tournaments
  add column updated_at timestamptz not null default now();

alter table public.tournament_teams
  add column updated_at timestamptz not null default now();

alter table public.stages
  add column updated_at timestamptz not null default now();

alter table public.matches
  add column updated_at timestamptz not null default now();

alter table public.predictions
  add column updated_at timestamptz not null default now();

alter table public.tournament_scores
  add column created_at timestamptz not null default now(),
  add column updated_at timestamptz not null default now();

create function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

comment on function public.set_updated_at() is
  'Keeps the updated_at audit timestamp synchronized on every row update.';

revoke execute on function public.set_updated_at() from public, anon, authenticated;

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

create trigger tournaments_set_updated_at
  before update on public.tournaments
  for each row execute function public.set_updated_at();

create trigger teams_set_updated_at
  before update on public.teams
  for each row execute function public.set_updated_at();

create trigger tournament_teams_set_updated_at
  before update on public.tournament_teams
  for each row execute function public.set_updated_at();

create trigger stages_set_updated_at
  before update on public.stages
  for each row execute function public.set_updated_at();

create trigger matches_set_updated_at
  before update on public.matches
  for each row execute function public.set_updated_at();

create trigger predictions_set_updated_at
  before update on public.predictions
  for each row execute function public.set_updated_at();

create trigger tournament_scores_set_updated_at
  before update on public.tournament_scores
  for each row execute function public.set_updated_at();

commit;
