begin;

grant select on table
  public.tournaments,
  public.teams,
  public.tournament_teams,
  public.stages,
  public.matches,
  public.tournament_overview
to anon, authenticated;

create policy "Competition tournaments are publicly readable"
on public.tournaments
for select
to anon, authenticated
using (true);

create policy "Competition teams are publicly readable"
on public.teams
for select
to anon, authenticated
using (true);

create policy "Competition enrollments are publicly readable"
on public.tournament_teams
for select
to anon, authenticated
using (true);

create policy "Competition stages are publicly readable"
on public.stages
for select
to anon, authenticated
using (true);

create policy "Competition matches are publicly readable"
on public.matches
for select
to anon, authenticated
using (true);

commit;
