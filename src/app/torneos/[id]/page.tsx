import Link from "next/link";
import { notFound } from "next/navigation";

import { createClient } from "@/lib/supabase/server";

const stageNames = {
  ROUND_OF_32: "Dieciseisavos",
  ROUND_OF_16: "Octavos",
  QUARTER_FINAL: "Cuartos",
  SEMI_FINAL: "Semifinales",
  FINAL: "Final",
} as const;

export default async function PublicTournamentDetail({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const supabase = await createClient();
  const [{ data: tournament }, { data: stages }, { data: matches }, { data: teams }] =
    await Promise.all([
      supabase.from("tournament_overview").select("*").eq("id", id).maybeSingle(),
      supabase.from("stages").select("*").eq("tournament_id", id).order("stage_order"),
      supabase.from("matches").select("*").eq("tournament_id", id).order("bracket_position"),
      supabase.from("teams").select("id,name,abbreviation,logo_path").order("name"),
    ]);

  if (!tournament) notFound();
  const teamById = new Map(teams?.map((team) => [team.id, team]));
  const matchById = new Map(matches?.map((match) => [match.id, match]));
  const stageById = new Map(stages?.map((stage) => [stage.id, stage]));
  const participant = (teamId: string | null, sourceId: string | null) => {
    if (teamId) return teamById.get(teamId);
    const source = sourceId ? matchById.get(sourceId) : null;
    const sourceStage = source ? stageById.get(source.stage_id) : null;
    return source && sourceStage
      ? {
          abbreviation: "",
          id: "",
          logo_path: "",
          name: `Ganador ${stageNames[sourceStage.type]} ${source.bracket_position}`,
        }
      : { abbreviation: "", id: "", logo_path: "", name: "Por definir" };
  };
  const champion = tournament.champion_team_id ? teamById.get(tournament.champion_team_id) : null;
  const status = tournament.status ?? "UPCOMING";

  return (
    <main className="content-page public-content">
      <Link className="back-link" href="/torneos">
        ← Todos los torneos
      </Link>
      <div className="tournament-title-row">
        <div>
          <p className="eyebrow">Llave de eliminación directa</p>
          <h1>{tournament.name}</h1>
          {tournament.description ? <p className="muted-text">{tournament.description}</p> : null}
        </div>
        <span className={`status-badge status-${status.toLowerCase()}`}>
          {status === "FINISHED"
            ? "Finalizado"
            : status === "IN_PROGRESS"
              ? "En juego"
              : "Próximamente"}
        </span>
      </div>
      {champion ? (
        <section className="champion-banner">
          <span>Campeón</span>
          <strong>{champion.name}</strong>
        </section>
      ) : null}
      {!tournament.bracket_generated_at ? (
        <section className="panel empty-public-state">
          <h2>La llave todavía no fue sorteada</h2>
          <p className="muted-text">Volvé más tarde para consultar los cruces.</p>
        </section>
      ) : (
        <div className="public-bracket" aria-label={`Llave de ${tournament.name}`}>
          {stages?.map((stage) => (
            <section className="bracket-stage" key={stage.id}>
              <h2>{stageNames[stage.type]}</h2>
              <div className="bracket-stage-matches">
                {matches
                  ?.filter((match) => match.stage_id === stage.id)
                  .map((match) => {
                    const home = participant(match.home_team_id, match.home_source_match_id);
                    const away = participant(match.away_team_id, match.away_source_match_id);
                    const penaltyWinner = match.penalty_winner_team_id
                      ? teamById.get(match.penalty_winner_team_id)
                      : null;
                    return (
                      <article className="public-match-card" key={match.id}>
                        <div className="public-team-row">
                          {home?.logo_path ? (
                            <span
                              className="mini-team-logo"
                              style={{
                                backgroundImage: `url(${supabase.storage.from("team-logos").getPublicUrl(home.logo_path).data.publicUrl})`,
                              }}
                            />
                          ) : null}
                          <span>{home?.name}</span>
                          {home?.id ? (
                            <strong>{match.result_published_at ? match.home_score : "-"}</strong>
                          ) : null}
                        </div>
                        <div className="public-team-row">
                          {away?.logo_path ? (
                            <span
                              className="mini-team-logo"
                              style={{
                                backgroundImage: `url(${supabase.storage.from("team-logos").getPublicUrl(away.logo_path).data.publicUrl})`,
                              }}
                            />
                          ) : null}
                          <span>{away?.name}</span>
                          {away?.id ? (
                            <strong>{match.result_published_at ? match.away_score : "-"}</strong>
                          ) : null}
                        </div>
                        <footer>
                          {penaltyWinner
                            ? `Ganó por penales: ${penaltyWinner.name}`
                            : match.starts_at
                              ? new Date(match.starts_at).toLocaleString("es-AR")
                              : "Sin horario"}
                        </footer>
                      </article>
                    );
                  })}
              </div>
            </section>
          ))}
        </div>
      )}
    </main>
  );
}
