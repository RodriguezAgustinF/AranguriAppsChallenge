import { redirect } from "next/navigation";
import Link from "next/link";

import { LoginForm } from "@/components/auth/login-form";
import { getAdminSession } from "@/lib/auth/admin";

export default async function LoginPage() {
  const session = await getAdminSession();

  if (session) {
    redirect("/admin");
  }

  return (
    <main className="centered-page">
      <section className="panel auth-panel">
        <Link className="back-link login-back-link" href="/">
          ← Volver al inicio
        </Link>
        <p className="eyebrow">Administración</p>
        <h1>Ingresar al torneo</h1>
        <p className="muted-text">Utilizá una cuenta administradora aprovisionada en Supabase.</p>
        <LoginForm />
      </section>
    </main>
  );
}
