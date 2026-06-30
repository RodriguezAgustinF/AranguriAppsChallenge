begin;

alter table public.matches
  add constraint matches_official_scores_complete
  check ((home_score is null) = (away_score is null)),
  add constraint matches_result_publication_coherent
  check ((home_score is null) = (result_published_at is null));

commit;
