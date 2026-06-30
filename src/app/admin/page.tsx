import Link from "next/link";

export default function AdminPage() {
  return (
    <main className="content-page">
      <div>
        <p className="eyebrow">Panel de control</p>
        <h1>Administración del torneo</h1>
        <p className="muted-text">
          Elegí por dónde comenzar. Los módulos se habilitarán siguiendo el flujo de la entrega.
        </p>
      </div>

      <div className="card-grid">
        <Link className="navigation-card" href="/admin/equipos">
          <strong>Equipos</strong>
          <span>Crear y mantener el catálogo con sus imágenes.</span>
        </Link>
        <Link className="navigation-card" href="/admin/torneos">
          <strong>Torneos</strong>
          <span>Crear torneos, inscribir equipos y gestionar la llave.</span>
        </Link>
      </div>
    </main>
  );
}
