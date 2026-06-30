begin;

alter table public.tournament_scores
  add constraint tournament_scores_user_tournament_unique
  unique (user_id, tournament_id);

commit;
