import Link from "next/link";

import { createClient } from "@/lib/supabase/server";

const statusNames: Record<string, string> = {
  FINISHED: "Finalizado",
  IN_PROGRESS: "En juego",
  UPCOMING: "Próximamente",
};

export default async function PublicTournamentsPage() {
  const supabase = await createClient();
  const { data: tournaments } = await supabase
    .from("tournament_overview")
    .select("*")
    .order("starts_at", { ascending: false });

  return (
    <main className="content-page public-content">
      <p className="eyebrow">Competencias</p>
      <h1>Torneos</h1>
      <p className="muted-text">Consultá los cruces, horarios y resultados de cada llave.</p>
      <div className="public-tournament-grid">
        {tournaments?.map((tournament) => {
          const status = tournament.status ?? "UPCOMING";
          return (
            <Link
              className="public-tournament-card"
              href={`/torneos/${tournament.id}`}
              key={tournament.id}
            >
              <div className="card-heading">
                <span className={`status-badge status-${status.toLowerCase()}`}>
                  {statusNames[status] ?? status}
                </span>
                <span>{tournament.team_count} equipos</span>
              </div>
              <h2>{tournament.name}</h2>
              {tournament.description ? <p>{tournament.description}</p> : null}
              {tournament.starts_at ? (
                <time dateTime={tournament.starts_at}>
                  Comienza: {new Date(tournament.starts_at).toLocaleString("es-AR")}
                </time>
              ) : null}
              <strong className="card-link">Ver torneo →</strong>
            </Link>
          );
        })}
        {!tournaments?.length ? (
          <section className="panel empty-public-state">
            <h2>Todavía no hay torneos</h2>
            <p className="muted-text">Cuando se cree una competencia aparecerá en esta pantalla.</p>
          </section>
        ) : null}
      </div>
    </main>
  );
}
