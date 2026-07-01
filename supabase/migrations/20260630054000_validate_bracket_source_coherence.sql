begin;

create function public.validate_bracket_sources()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  target_stage_order integer;
  source_id uuid;
  source_tournament_id uuid;
  source_stage_order integer;
begin
  if new.home_source_match_id is null and new.away_source_match_id is null then
    return new;
  end if;

  -- Serializes direct writes as well as the future bracket generation operation,
  -- preventing two concurrent slots from consuming the same source match.
  perform 1
  from public.tournaments
  where id = new.tournament_id
  for update;

  select stage_order
  into target_stage_order
  from public.stages
  where id = new.stage_id
    and tournament_id = new.tournament_id;

  foreach source_id in array array[new.home_source_match_id, new.away_source_match_id]
  loop
    select source_match.tournament_id, source_stage.stage_order
    into source_tournament_id, source_stage_order
    from public.matches as source_match
    join public.stages as source_stage
      on source_stage.id = source_match.stage_id
      and source_stage.tournament_id = source_match.tournament_id
    where source_match.id = source_id;

    if source_tournament_id is distinct from new.tournament_id then
      raise exception using
        errcode = '23514',
        message = 'source matches must belong to the same tournament',
        constraint = 'matches_source_tournament_coherent';
    end if;

    if source_stage_order is distinct from target_stage_order - 1 then
      raise exception using
        errcode = '23514',
        message = 'source matches must belong to the immediately previous stage',
        constraint = 'matches_source_stage_coherent';
    end if;

    if exists (
      select 1
      from public.matches as target_match
      where target_match.id <> new.id
        and source_id in (
          target_match.home_source_match_id,
          target_match.away_source_match_id
        )
    ) then
      raise exception using
        errcode = '23505',
        message = 'a source match can feed only one bracket slot',
        constraint = 'matches_source_slot_unique';
    end if;
  end loop;

  return new;
end;
$$;

comment on function public.validate_bracket_sources() is
  'Ensures source matches come from the preceding stage of the same tournament and feed one slot.';

revoke execute on function public.validate_bracket_sources() from public, anon, authenticated;

create trigger validate_source_coherence_after_shape
  before insert or update of tournament_id, stage_id, home_source_match_id, away_source_match_id
  on public.matches
  for each row execute function public.validate_bracket_sources();

commit;
