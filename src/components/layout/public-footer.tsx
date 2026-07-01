import Link from "next/link";

export function PublicFooter() {
  return (
    <footer className="public-footer">
      <div className="site-footer-inner">
        <div>
          <strong>Gestor de Torneos</strong>
          <p>Organización de competencias de eliminación directa, cruces y resultados.</p>
        </div>
        <nav aria-label="Navegación del pie">
          <Link href="/torneos">Ver torneos</Link>
          <Link href="/login">Administración</Link>
        </nav>
      </div>
    </footer>
  );
}
