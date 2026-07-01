begin;

create function public.generate_bracket(target_tournament_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  tournament_capacity integer;
  generated_at timestamptz;
  enrollment_count integer;
  stage_names public.stage_type[];
  stage_name public.stage_type;
  stage_id uuid;
  stage_index integer := 0;
  matches_in_stage integer;
  previous_matches uuid[] := array[]::uuid[];
  current_matches uuid[];
  home_team uuid;
  away_team uuid;
  new_match_id uuid;
begin
  if not public.is_admin() then
    raise exception using errcode = '42501', message = 'only administrators can generate brackets';
  end if;

  select team_count, bracket_generated_at
  into tournament_capacity, generated_at
  from public.tournaments
  where id = target_tournament_id
  for update;

  if tournament_capacity is null then
    raise exception using errcode = 'P0002', message = 'tournament not found';
  end if;
  if generated_at is not null then
    raise exception using errcode = '55000', message = 'bracket was already generated';
  end if;

  select count(*) into enrollment_count
  from public.tournament_teams
  where tournament_id = target_tournament_id;
  if enrollment_count <> tournament_capacity then
    raise exception using errcode = '23514', message = 'tournament must have exactly its configured team capacity';
  end if;

  with shuffled as (
    select id, row_number() over (order by extensions.gen_random_uuid())::integer as position
    from public.tournament_teams
    where tournament_id = target_tournament_id
  )
  update public.tournament_teams as enrollment
  set draw_position = shuffled.position
  from shuffled
  where enrollment.id = shuffled.id;

  stage_names := case tournament_capacity
    when 4 then array['SEMI_FINAL', 'FINAL']::public.stage_type[]
    when 8 then array['QUARTER_FINAL', 'SEMI_FINAL', 'FINAL']::public.stage_type[]
    when 16 then array['ROUND_OF_16', 'QUARTER_FINAL', 'SEMI_FINAL', 'FINAL']::public.stage_type[]
    when 32 then array['ROUND_OF_32', 'ROUND_OF_16', 'QUARTER_FINAL', 'SEMI_FINAL', 'FINAL']::public.stage_type[]
  end;

  foreach stage_name in array stage_names loop
    stage_index := stage_index + 1;
    insert into public.stages (tournament_id, type, stage_order)
    values (target_tournament_id, stage_name, stage_index)
    returning id into stage_id;
    matches_in_stage := tournament_capacity / (2 ^ stage_index);
    current_matches := array[]::uuid[];

    for match_index in 1..matches_in_stage loop
      new_match_id := extensions.gen_random_uuid();
      if stage_index = 1 then
        select team_id into home_team from public.tournament_teams
        where tournament_id = target_tournament_id and draw_position = match_index * 2 - 1;
        select team_id into away_team from public.tournament_teams
        where tournament_id = target_tournament_id and draw_position = match_index * 2;
        insert into public.matches (id, tournament_id, stage_id, bracket_position, home_team_id, away_team_id)
        values (new_match_id, target_tournament_id, stage_id, match_index, home_team, away_team);
      else
        insert into public.matches (id, tournament_id, stage_id, bracket_position, home_source_match_id, away_source_match_id)
        values (new_match_id, target_tournament_id, stage_id, match_index, previous_matches[match_index * 2 - 1], previous_matches[match_index * 2]);
      end if;
      current_matches := array_append(current_matches, new_match_id);
    end loop;
    previous_matches := current_matches;
  end loop;

  update public.tournaments set bracket_generated_at = clock_timestamp()
  where id = target_tournament_id;
end;
$$;

revoke execute on function public.generate_bracket(uuid) from public, anon;
grant execute on function public.generate_bracket(uuid) to authenticated;

commit;
