begin;

create function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles
    where id = (select auth.uid())
      and role = 'ADMIN'
  );
$$;

comment on function public.is_admin() is
  'Returns whether the authenticated identity has an ADMIN application profile.';

revoke execute on function public.is_admin() from public, anon;
grant execute on function public.is_admin() to authenticated;

grant insert, update, delete on table
  public.tournaments,
  public.teams,
  public.tournament_teams
to authenticated;

create policy "Admins manage tournaments"
on public.tournaments
for all
to authenticated
using ((select public.is_admin()))
with check ((select public.is_admin()));

create policy "Admins manage teams"
on public.teams
for all
to authenticated
using ((select public.is_admin()))
with check ((select public.is_admin()));

create policy "Admins manage tournament enrollments"
on public.tournament_teams
for all
to authenticated
using ((select public.is_admin()))
with check ((select public.is_admin()));

commit;
