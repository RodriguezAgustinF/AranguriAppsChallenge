-- Deterministic relational data for local development.
-- Binary logo objects are intentionally not inserted through SQL; the paths are
-- stable references that can be populated through Supabase Storage when needed.

begin;

insert into public.teams (id, name, abbreviation, logo_path)
values
  ('d0000000-0000-0000-0000-000000000001', 'Argentina', 'ARG', 'seed/argentina.webp'),
  ('d0000000-0000-0000-0000-000000000002', 'Brasil', 'BRA', 'seed/brasil.webp'),
  ('d0000000-0000-0000-0000-000000000003', 'Francia', 'FRA', 'seed/francia.webp'),
  ('d0000000-0000-0000-0000-000000000004', 'España', 'ESP', 'seed/espana.webp')
on conflict (id) do update
set
  name = excluded.name,
  abbreviation = excluded.abbreviation,
  logo_path = excluded.logo_path;

insert into public.tournaments (
  id,
  name,
  description,
  team_count,
  starts_at,
  ends_at
)
values (
  'd1000000-0000-0000-0000-000000000001',
  'Copa de desarrollo',
  'Torneo local de cuatro equipos para desarrollar y probar los flujos iniciales.',
  4,
  now() + interval '30 days',
  now() + interval '37 days'
)
on conflict (id) do nothing;

insert into public.tournament_teams (id, tournament_id, team_id)
values
  (
    'd2000000-0000-0000-0000-000000000001',
    'd1000000-0000-0000-0000-000000000001',
    'd0000000-0000-0000-0000-000000000001'
  ),
  (
    'd2000000-0000-0000-0000-000000000002',
    'd1000000-0000-0000-0000-000000000001',
    'd0000000-0000-0000-0000-000000000002'
  ),
  (
    'd2000000-0000-0000-0000-000000000003',
    'd1000000-0000-0000-0000-000000000001',
    'd0000000-0000-0000-0000-000000000003'
  ),
  (
    'd2000000-0000-0000-0000-000000000004',
    'd1000000-0000-0000-0000-000000000001',
    'd0000000-0000-0000-0000-000000000004'
  )
on conflict (id) do nothing;

commit;
