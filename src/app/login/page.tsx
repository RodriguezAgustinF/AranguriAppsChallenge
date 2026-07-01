import { redirect } from "next/navigation";
import Link from "next/link";

import { LoginForm } from "@/components/auth/login-form";
import { PublicFooter } from "@/components/layout/public-footer";
import { PublicHeader } from "@/components/layout/public-header";
import { getAdminSession } from "@/lib/auth/admin";

export default async function LoginPage() {
  const session = await getAdminSession();

  if (session) {
    redirect("/admin");
  }

  return (
    <div className="public-shell">
      <PublicHeader />
      <main className="login-page">
        <section className="login-intro">
          <p className="eyebrow">Área privada</p>
          <h1>Administrá la competencia.</h1>
          <p>Equipos, torneos, horarios y resultados desde un mismo lugar.</p>
        </section>
        <section className="panel auth-panel">
          <Link className="back-link login-back-link" href="/">
            ← Volver al inicio
          </Link>
          <p className="eyebrow">Administración</p>
          <h2>Iniciar sesión</h2>
          <p className="muted-text">Utilizá una cuenta administradora aprovisionada en Supabase.</p>
          <LoginForm />
        </section>
      </main>
      <PublicFooter />
    </div>
  );
}
