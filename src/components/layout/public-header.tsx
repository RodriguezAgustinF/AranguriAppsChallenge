import Link from "next/link";

export function PublicHeader() {
  return (
    <header className="public-header">
      <div className="site-header-inner">
        <Link className="brand site-brand" href="/">
          <span className="brand-mark" aria-hidden="true" />
          Gestor de Torneos
        </Link>
        <nav className="public-nav" aria-label="Navegación pública">
          <Link href="/">Inicio</Link>
          <Link href="/torneos">Torneos</Link>
          <Link className="header-admin-link" href="/login">
            Administración
          </Link>
        </nav>
      </div>
    </header>
  );
}
