begin;

create policy "Team logos are publicly readable"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'team-logos');

create policy "Admins upload team logos"
on storage.objects for insert
to authenticated
with check (bucket_id = 'team-logos' and (select public.is_admin()));

create policy "Admins update team logos"
on storage.objects for update
to authenticated
using (bucket_id = 'team-logos' and (select public.is_admin()))
with check (bucket_id = 'team-logos' and (select public.is_admin()));

create policy "Admins delete team logos"
on storage.objects for delete
to authenticated
using (bucket_id = 'team-logos' and (select public.is_admin()));

commit;
