import { deleteTeam } from "@/actions/teams";
import { CreateTeamForm } from "@/components/teams/create-team-form";
import { EditTeamForm } from "@/components/teams/edit-team-form";
import { createClient } from "@/lib/supabase/server";

export default async function TeamsPage() {
  const supabase = await createClient();
  const { data: teams } = await supabase.from("teams").select("*").order("name");

  return (
    <main className="content-page">
      <p className="eyebrow">Catálogo</p>
      <h1>Equipos</h1>
      <div className="management-grid">
        <section className="panel compact-panel">
          <h2>Nuevo equipo</h2>
          <CreateTeamForm />
        </section>
        <section>
          <h2>Equipos creados</h2>
          <div className="entity-list">
            {teams?.map((team) => {
              const logoUrl = supabase.storage.from("team-logos").getPublicUrl(team.logo_path)
                .data.publicUrl;
              return (
                <article className="entity-card" key={team.id}>
                  <div className="entity-row team-entity-row">
                    <div
                      className="team-logo"
                      aria-label={`Imagen de ${team.name}`}
                      role="img"
                      style={{ backgroundImage: `url(${logoUrl})` }}
                    />
                    <div>
                      <strong>{team.name}</strong>
                      <span>{team.abbreviation}</span>
                    </div>
                    <form action={deleteTeam}>
                      <input name="id" type="hidden" value={team.id} />
                      <button className="danger-button" type="submit">
                        Eliminar
                      </button>
                    </form>
                  </div>
                  <EditTeamForm team={team} />
                </article>
              );
            })}
            {!teams?.length ? <p className="muted-text">Todavía no hay equipos.</p> : null}
          </div>
        </section>
      </div>
    </main>
  );
}
