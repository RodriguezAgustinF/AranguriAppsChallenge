import { notFound } from "next/navigation";
import { enrollTeam, generateBracket, removeEnrollment } from "@/actions/enrollments";
import { MatchScheduleForm } from "@/components/matches/match-schedule-form";
import { MatchResultForm } from "@/components/matches/match-result-form";
import { createClient } from "@/lib/supabase/server";

const stageNames = {
  ROUND_OF_32: "Dieciseisavos de final",
  ROUND_OF_16: "Octavos de final",
  QUARTER_FINAL: "Cuartos de final",
  SEMI_FINAL: "Semifinales",
  FINAL: "Final",
} as const;

export default async function TournamentDetail({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const supabase = await createClient();
  const [
    { data: tournament },
    { data: teams },
    { data: enrollments },
    { data: stages },
    { data: matches },
  ] = await Promise.all([
    supabase.from("tournaments").select("*").eq("id", id).maybeSingle(),
    supabase.from("teams").select("id,name,abbreviation").order("name"),
    supabase.from("tournament_teams").select("id,team_id").eq("tournament_id", id),
    supabase
      .from("stages")
      .select("id,type,stage_order")
      .eq("tournament_id", id)
      .order("stage_order"),
    supabase.from("matches").select("*").eq("tournament_id", id).order("bracket_position"),
  ]);
  if (!tournament) notFound();
  const enrolledIds = new Set(enrollments?.map((item) => item.team_id));
  const available = teams?.filter((team) => !enrolledIds.has(team.id)) ?? [];
  const enrolled =
    enrollments?.map((item) => ({
      ...item,
      team: teams?.find((team) => team.id === item.team_id),
    })) ?? [];
  const remaining = tournament.team_count - enrolled.length;
  const teamNames = new Map(teams?.map((team) => [team.id, team.name]));
  const stageById = new Map(stages?.map((stage) => [stage.id, stage]));
  const matchById = new Map(matches?.map((match) => [match.id, match]));
  const participantName = (teamId: string | null, sourceId: string | null) => {
    if (teamId) return teamNames.get(teamId) ?? "Equipo";
    const source = sourceId ? matchById.get(sourceId) : null;
    const sourceStage = source ? stageById.get(source.stage_id) : null;
    return source && sourceStage
      ? `Ganador: ${stageNames[sourceStage.type]} ${source.bracket_position}`
      : "Por definir";
  };
  return (
    <main className="content-page">
      <header className="admin-page-heading tournament-admin-heading">
        <p className="eyebrow">Gestión del torneo</p>
        <h1>{tournament.name}</h1>
        <p className="muted-text">
          {enrolled.length} de {tournament.team_count} equipos · {remaining} lugares disponibles
        </p>
      </header>
      <div className="management-grid">
        <section className="panel compact-panel">
          <h2>Inscribir equipo</h2>
          <form action={enrollTeam} className="entity-form">
            <input type="hidden" name="tournamentId" value={id} />
            <div className="field-group">
              <label>Equipo</label>
              <select name="teamId" disabled={!remaining}>
                {available.map((team) => (
                  <option value={team.id} key={team.id}>
                    {team.name} ({team.abbreviation})
                  </option>
                ))}
              </select>
            </div>
            <button className="primary-button" disabled={!remaining || !available.length}>
              Inscribir
            </button>
          </form>
        </section>
        <section>
          <h2>Participantes</h2>
          <div className="entity-list">
            {enrolled.map((item) => (
              <article className="entity-row" key={item.id}>
                <div>
                  <strong>{item.team?.name}</strong>
                  <span>{item.team?.abbreviation}</span>
                </div>
                <form action={removeEnrollment}>
                  <input type="hidden" name="tournamentId" value={id} />
                  <input type="hidden" name="enrollmentId" value={item.id} />
                  <button className="danger-button">Quitar</button>
                </form>
              </article>
            ))}
            {!enrolled.length ? (
              <p className="muted-text">Todavía no hay equipos inscriptos.</p>
            ) : null}
          </div>
        </section>
      </div>
      <section className="panel bracket-action">
        <h2>Generar llave</h2>
        <p className="muted-text">El sorteo es aleatorio, único y definitivo.</p>
        <form action={generateBracket}>
          <input type="hidden" name="tournamentId" value={id} />
          <button
            className="primary-button"
            disabled={remaining !== 0 || Boolean(tournament.bracket_generated_at)}
          >
            {tournament.bracket_generated_at ? "Llave generada" : "Sortear equipos y generar llave"}
          </button>
        </form>
      </section>
      {tournament.bracket_generated_at ? (
        <section className="match-schedule-section">
          <h2>Programación de partidos</h2>
          <p className="muted-text">
            Podés definir todos los horarios desde el inicio del torneo y reprogramarlos mientras no
            hayan comenzado.
          </p>
          <div className="stage-list">
            {stages?.map((stage) => (
              <section className="panel stage-panel" key={stage.id}>
                <h3>{stageNames[stage.type]}</h3>
                <div className="match-list">
                  {matches
                    ?.filter((match) => match.stage_id === stage.id)
                    .map((match) => {
                      const homeTeam = match.home_team_id
                        ? teams?.find((team) => team.id === match.home_team_id)
                        : undefined;
                      const awayTeam = match.away_team_id
                        ? teams?.find((team) => team.id === match.away_team_id)
                        : undefined;
                      const hasStarted = Boolean(
                        match.starts_at && new Date(match.starts_at) <= new Date(),
                      );
                      return (
                        <article className="match-schedule-card" key={match.id}>
                          <strong>Partido {match.bracket_position}</strong>
                          <span className="match-participants">
                            {participantName(match.home_team_id, match.home_source_match_id)} vs.{" "}
                            {participantName(match.away_team_id, match.away_source_match_id)}
                          </span>
                          {match.result_published_at ? (
                            <div className="published-result">
                              <strong>
                                {match.home_score} - {match.away_score}
                              </strong>
                              {match.penalty_winner_team_id ? (
                                <span>
                                  Ganó por penales: {teamNames.get(match.penalty_winner_team_id)}
                                </span>
                              ) : null}
                              <span>Resultado oficial definitivo</span>
                            </div>
                          ) : hasStarted && homeTeam && awayTeam ? (
                            <MatchResultForm
                              awayTeam={awayTeam}
                              homeTeam={homeTeam}
                              matchId={match.id}
                              tournamentId={id}
                            />
                          ) : hasStarted ? (
                            <span className="muted-text">
                              Esperando que se resuelvan ambos participantes.
                            </span>
                          ) : (
                            <MatchScheduleForm
                              matchId={match.id}
                              startsAt={match.starts_at}
                              tournamentId={id}
                              tournamentStartsAt={tournament.starts_at}
                            />
                          )}
                        </article>
                      );
                    })}
                </div>
              </section>
            ))}
          </div>
        </section>
      ) : null}
    </main>
  );
}
