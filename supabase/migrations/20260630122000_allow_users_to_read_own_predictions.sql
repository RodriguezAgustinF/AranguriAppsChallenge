begin;

grant select on table public.predictions to authenticated;

create policy "Users can read their own predictions"
on public.predictions
for select
to authenticated
using ((select auth.uid()) = user_id);

commit;
