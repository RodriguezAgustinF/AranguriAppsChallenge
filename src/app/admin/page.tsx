import Link from "next/link";

export default function AdminPage() {
  return (
    <main className="content-page">
      <header className="admin-page-heading">
        <p className="eyebrow">Panel de control</p>
        <h1>Administración</h1>
        <p className="muted-text">
          Gestioná los equipos, las competencias y cada instancia de la llave.
        </p>
      </header>

      <div className="card-grid">
        <Link className="navigation-card" href="/admin/equipos">
          <span className="navigation-number">01</span>
          <strong>Equipos</strong>
          <span>Crear y mantener el catálogo con sus imágenes.</span>
        </Link>
        <Link className="navigation-card" href="/admin/torneos">
          <span className="navigation-number">02</span>
          <strong>Torneos</strong>
          <span>Crear torneos, inscribir equipos y gestionar la llave.</span>
        </Link>
      </div>
    </main>
  );
}
