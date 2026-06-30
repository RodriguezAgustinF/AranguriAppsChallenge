begin;

alter table public.profiles enable row level security;
alter table public.tournaments enable row level security;
alter table public.teams enable row level security;
alter table public.tournament_teams enable row level security;
alter table public.stages enable row level security;
alter table public.matches enable row level security;
alter table public.predictions enable row level security;
alter table public.tournament_scores enable row level security;

commit;
