"use server";

import { redirect } from "next/navigation";

import { createClient } from "@/lib/supabase/server";

export type LoginState = {
  message?: string;
};

export async function loginAdmin(
  _previousState: LoginState,
  formData: FormData,
): Promise<LoginState> {
  const emailValue = formData.get("email");
  const passwordValue = formData.get("password");
  const email = typeof emailValue === "string" ? emailValue.trim() : "";
  const password = typeof passwordValue === "string" ? passwordValue : "";

  if (!email || !email.includes("@") || !password) {
    return { message: "Ingresá un email y una contraseña válidos." };
  }

  const supabase = await createClient();
  const { error: signInError } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (signInError) {
    return { message: "Las credenciales no son válidas." };
  }

  const { data: isAdmin, error: roleError } = await supabase.rpc("is_admin");

  if (roleError || !isAdmin) {
    await supabase.auth.signOut();
    return { message: "La cuenta no posee permisos de administrador." };
  }

  redirect("/admin");
}

export async function logoutAdmin(): Promise<never> {
  const supabase = await createClient();
  await supabase.auth.signOut();
  redirect("/login");
}
