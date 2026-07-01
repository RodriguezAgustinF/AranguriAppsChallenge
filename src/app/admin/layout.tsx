import Link from "next/link";

import { logoutAdmin } from "@/actions/auth";
import { requireAdmin } from "@/lib/auth/admin";

export default async function AdminLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  const admin = await requireAdmin();

  return (
    <div className="admin-shell">
      <header className="admin-header">
        <div className="site-header-inner admin-header-inner">
          <Link className="brand site-brand" href="/admin">
            <span className="brand-mark" aria-hidden="true" />
            Gestor de Torneos
          </Link>
          <nav aria-label="Administración" className="admin-nav">
            <Link href="/admin/equipos">Equipos</Link>
            <Link href="/admin/torneos">Torneos</Link>
            <Link href="/torneos">Ver sitio público</Link>
          </nav>
          <div className="admin-session">
            <span>{admin.email}</span>
            <form action={logoutAdmin}>
              <button className="text-button" type="submit">
                Salir
              </button>
            </form>
          </div>
        </div>
      </header>
      {children}
    </div>
  );
}
