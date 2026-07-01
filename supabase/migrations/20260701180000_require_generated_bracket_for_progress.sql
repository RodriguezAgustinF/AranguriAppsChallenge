begin;

create or replace view public.tournament_overview with (security_invoker = true) as
select
  tournament.*,
  case
    when final_match.result_published_at is not null then 'FINISHED'
    when tournament.bracket_generated_at is not null
      and clock_timestamp() >= tournament.starts_at then 'IN_PROGRESS'
    else 'UPCOMING'
  end as status,
  case
    when final_match.result_published_at is null then null
    when final_match.home_score > final_match.away_score then final_match.home_team_id
    when final_match.away_score > final_match.home_score then final_match.away_team_id
    else final_match.penalty_winner_team_id
  end as champion_team_id
from public.tournaments as tournament
left join public.stages as final_stage
  on final_stage.tournament_id = tournament.id
  and final_stage.type = 'FINAL'
left join public.matches as final_match on final_match.stage_id = final_stage.id;

grant select on public.tournament_overview to anon, authenticated;

commit;
