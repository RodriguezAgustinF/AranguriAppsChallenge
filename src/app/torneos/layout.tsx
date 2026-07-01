import Link from "next/link";

export default function PublicTournamentsLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="public-shell">
      <header className="public-header">
        <Link className="brand" href="/">
          Prode de Fútbol
        </Link>
        <nav className="public-nav" aria-label="Navegación pública">
          <Link href="/torneos">Torneos</Link>
          <Link href="/login">Administración</Link>
        </nav>
      </header>
      {children}
    </div>
  );
}
