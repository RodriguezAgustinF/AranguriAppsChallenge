import Link from "next/link";

import { logoutAdmin } from "@/actions/auth";
import { requireAdmin } from "@/lib/auth/admin";

export default async function AdminLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  const admin = await requireAdmin();

  return (
    <div className="admin-shell">
      <header className="admin-header">
        <Link className="brand" href="/admin">
          Copa Admin
        </Link>
        <nav aria-label="Administración" className="admin-nav">
          <Link href="/admin/equipos">Equipos</Link>
          <Link href="/admin/torneos">Torneos</Link>
        </nav>
        <div className="admin-session">
          <span>{admin.email}</span>
          <form action={logoutAdmin}>
            <button className="text-button" type="submit">
              Salir
            </button>
          </form>
        </div>
      </header>
      {children}
    </div>
  );
}
