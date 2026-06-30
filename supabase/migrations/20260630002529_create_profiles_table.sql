begin;

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  name text not null,
  role public.user_role not null default 'USER',
  created_at timestamptz not null default now(),
  constraint profiles_name_not_blank check (name = btrim(name) and char_length(name) between 1 and 80)
);

comment on table public.profiles is
  'Public application data associated one-to-one with a Supabase Auth identity.';
comment on column public.profiles.id is
  'Matches auth.users.id; a profile cannot exist without an authentication identity.';
comment on column public.profiles.name is
  'Visible name used in rankings and application screens.';
comment on column public.profiles.role is
  'Application authorization role. Public signups are always created as USER.';

create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  profile_name text;
begin
  profile_name := left(
    coalesce(
      nullif(btrim(new.raw_user_meta_data ->> 'name'), ''),
      nullif(btrim(split_part(coalesce(new.email, ''), '@', 1)), ''),
      'Usuario'
    ),
    80
  );

  insert into public.profiles (id, name, role)
  values (new.id, profile_name, 'USER');

  return new;
end;
$$;

comment on function public.handle_new_user() is
  'Creates a USER profile after an identity is inserted into auth.users.';

revoke execute on function public.handle_new_user() from public, anon, authenticated;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

commit;
