begin;

grant update (starts_at) on public.matches to authenticated;

create policy "Admins schedule matches"
on public.matches
for update
to authenticated
using ((select public.is_admin()))
with check ((select public.is_admin()));

commit;
