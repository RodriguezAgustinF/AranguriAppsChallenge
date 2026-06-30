begin;

alter table public.teams
  add column logo_path text not null,
  add constraint teams_logo_path_valid
  check (
    logo_path = btrim(logo_path)
    and char_length(logo_path) between 1 and 512
    and logo_path !~ '(^|/)\.\.(/|$)'
  );

comment on column public.teams.logo_path is
  'Object path inside the public team-logos Supabase Storage bucket.';

insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'team-logos',
  'team-logos',
  true,
  1048576,
  array['image/png', 'image/jpeg', 'image/webp']
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

commit;
