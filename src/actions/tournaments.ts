"use server";

import { revalidatePath } from "next/cache";

import { requireAdmin } from "@/lib/auth/admin";
import { createClient } from "@/lib/supabase/server";

export type TournamentState = { message?: string; success?: boolean };

function parseTournament(formData: FormData) {
  const name = String(formData.get("name") ?? "").trim();
  const description = String(formData.get("description") ?? "").trim() || null;
  const teamCount = Number(formData.get("teamCount"));
  const startsAt = new Date(String(formData.get("startsAt") ?? ""));
  if (name.length < 3 || name.length > 100)
    return { error: "El nombre debe tener entre 3 y 100 caracteres." };
  if (![4, 8, 16, 32].includes(teamCount)) return { error: "Elegí una capacidad válida." };
  if (Number.isNaN(startsAt.valueOf()) || startsAt <= new Date()) {
    return { error: "La fecha de inicio debe ser futura." };
  }
  return {
    data: {
      description,
      ends_at: null,
      name,
      starts_at: startsAt.toISOString(),
      team_count: teamCount,
    },
  };
}

export async function createTournament(
  _state: TournamentState,
  formData: FormData,
): Promise<TournamentState> {
  await requireAdmin();
  const parsed = parseTournament(formData);
  if (parsed.error || !parsed.data) return { message: parsed.error };
  const supabase = await createClient();
  const { error } = await supabase.from("tournaments").insert(parsed.data);
  if (error) return { message: "No se pudo crear el torneo." };
  revalidatePath("/admin/torneos");
  return { message: "Torneo creado.", success: true };
}

export async function updateTournament(
  _state: TournamentState,
  formData: FormData,
): Promise<TournamentState> {
  await requireAdmin();
  const id = String(formData.get("id") ?? "");
  const parsed = parseTournament(formData);
  if (parsed.error || !parsed.data) return { message: parsed.error };
  const supabase = await createClient();
  const { error } = await supabase.from("tournaments").update(parsed.data).eq("id", id);
  if (error) return { message: "Solo pueden editarse torneos que todavía no comenzaron." };
  revalidatePath("/admin/torneos");
  return { message: "Torneo actualizado.", success: true };
}

export async function deleteTournament(formData: FormData) {
  await requireAdmin();
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  await supabase
    .from("tournaments")
    .delete()
    .eq("id", id)
    .gt("starts_at", new Date().toISOString());
  revalidatePath("/admin/torneos");
}
