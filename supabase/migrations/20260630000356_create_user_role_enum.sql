begin;

create type public.user_role as enum ('ADMIN', 'USER');

comment on type public.user_role is
  'Application role assigned to a user profile. ADMIN accounts are provisioned manually.';

commit;
