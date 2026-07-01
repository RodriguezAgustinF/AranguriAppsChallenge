import { deleteTournament } from "@/actions/tournaments";
import { TournamentForm } from "@/components/tournaments/tournament-form";
import { createClient } from "@/lib/supabase/server";
import Link from "next/link";

export default async function TournamentsPage() {
  const supabase = await createClient();
  const { data: tournaments } = await supabase.from("tournaments").select("*").order("starts_at");
  return (
    <main className="content-page">
      <header className="admin-page-heading">
        <p className="eyebrow">Competencias</p>
        <h1>Torneos</h1>
        <p className="muted-text">Creá una competencia y continuá su gestión desde la lista.</p>
      </header>
      <div className="management-grid">
        <section className="panel compact-panel">
          <h2>Nuevo torneo</h2>
          <TournamentForm />
        </section>
        <section>
          <h2>Torneos creados</h2>
          <div className="entity-list">
            {tournaments?.map((tournament) => (
              <article className="entity-card" key={tournament.id}>
                <div className="entity-row">
                  <div>
                    <strong>{tournament.name}</strong>
                    <span>
                      {tournament.team_count} equipos ·{" "}
                      {new Date(tournament.starts_at).toLocaleString("es-AR")}
                    </span>
                    <Link className="inline-link" href={`/admin/torneos/${tournament.id}`}>
                      Gestionar equipos
                    </Link>
                  </div>
                  <form action={deleteTournament}>
                    <input name="id" type="hidden" value={tournament.id} />
                    <button className="danger-button">Eliminar</button>
                  </form>
                </div>
                <details className="edit-panel">
                  <summary>Editar</summary>
                  <div className="edit-form-wrap">
                    <TournamentForm tournament={tournament} />
                  </div>
                </details>
              </article>
            ))}
            {!tournaments?.length ? <p className="muted-text">Todavía no hay torneos.</p> : null}
          </div>
        </section>
      </div>
    </main>
  );
}
