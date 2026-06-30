import { redirect } from "next/navigation";

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
        <p className="eyebrow">Administración</p>
        <h1>Ingresar al torneo</h1>
        <p className="muted-text">Utilizá una cuenta administradora aprovisionada en Supabase.</p>
        <LoginForm />
      </section>
    </main>
  );
}
