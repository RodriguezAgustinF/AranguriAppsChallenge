begin;

alter table public.stages
  add constraint stages_tournament_order_unique
  unique (tournament_id, stage_order),
  add constraint stages_tournament_type_unique
  unique (tournament_id, type),
  add constraint stages_stage_order_positive
  check (stage_order > 0);

alter table public.matches
  add constraint matches_stage_position_unique
  unique (stage_id, bracket_position),
  add constraint matches_bracket_position_positive
  check (bracket_position > 0),
  add constraint matches_sources_distinct
  check (
    home_source_match_id is null
    or away_source_match_id is null
    or home_source_match_id <> away_source_match_id
  );

commit;
