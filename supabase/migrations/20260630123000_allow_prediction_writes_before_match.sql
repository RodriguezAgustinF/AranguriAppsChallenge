begin;

grant insert, update on table public.predictions to authenticated;

create policy "Users can create own predictions before kickoff"
on public.predictions
for insert
to authenticated
with check (
  (select auth.uid()) = user_id
  and exists (
    select 1
    from public.matches as match
    where match.id = match_id
      and match.home_team_id is not null
      and match.away_team_id is not null
      and match.starts_at is not null
      and clock_timestamp() < match.starts_at
      and match.result_published_at is null
  )
);

create policy "Users can update own predictions before kickoff"
on public.predictions
for update
to authenticated
using (
  (select auth.uid()) = user_id
  and exists (
    select 1
    from public.matches as match
    where match.id = match_id
      and match.home_team_id is not null
      and match.away_team_id is not null
      and match.starts_at is not null
      and clock_timestamp() < match.starts_at
      and match.result_published_at is null
  )
)
with check (
  (select auth.uid()) = user_id
  and exists (
    select 1
    from public.matches as match
    where match.id = match_id
      and match.home_team_id is not null
      and match.away_team_id is not null
      and match.starts_at is not null
      and clock_timestamp() < match.starts_at
      and match.result_published_at is null
  )
);

commit;
