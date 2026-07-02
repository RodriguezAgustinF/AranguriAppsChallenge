import Link from "next/link";

import { TournamentStatusBadge } from "@/components/tournaments/tournament-status-badge";
import { formatDateTime24Hour } from "@/lib/date-time";
import { createClient } from "@/lib/supabase/server";

export default async function PublicTournamentsPage() {
  const supabase = await createClient();
  const { data: tournaments } = await supabase
    .from("tournament_overview")
    .select("*")
    .order("starts_at", { ascending: false });

  return (
    <main className="content-page public-content">
      <header className="page-masthead">
        <p className="eyebrow">Competencias</p>
        <h1>Torneos</h1>
        <p>Consultá los cruces, horarios y resultados de cada llave.</p>
      </header>
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
                <TournamentStatusBadge
                  bracketGeneratedAt={tournament.bracket_generated_at}
                  initialStatus={status}
                  startsAt={tournament.starts_at}
                />
                <span>{tournament.team_count} equipos</span>
              </div>
              <h2>{tournament.name}</h2>
              {tournament.description ? <p>{tournament.description}</p> : null}
              {tournament.starts_at ? (
                <time dateTime={tournament.starts_at}>
                  Comienza: {formatDateTime24Hour(tournament.starts_at)}
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
