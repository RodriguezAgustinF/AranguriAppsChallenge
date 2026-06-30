begin;

alter table public.predictions
  add constraint predictions_user_match_unique
  unique (user_id, match_id);

commit;
