import { notFound } from "next/navigation";
import { enrollTeam, removeEnrollment } from "@/actions/enrollments";
import { createClient } from "@/lib/supabase/server";

export default async function TournamentDetail({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const supabase = await createClient();
  const [{ data: tournament }, { data: teams }, { data: enrollments }] = await Promise.all([
    supabase.from("tournaments").select("*").eq("id", id).maybeSingle(),
    supabase.from("teams").select("id,name,abbreviation").order("name"),
    supabase.from("tournament_teams").select("id,team_id").eq("tournament_id", id),
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
  return (
    <main className="content-page">
      <p className="eyebrow">Inscripciones</p>
      <h1>{tournament.name}</h1>
      <p className="muted-text">
        {enrolled.length} de {tournament.team_count} equipos · {remaining} lugares disponibles
      </p>
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
    </main>
  );
}
