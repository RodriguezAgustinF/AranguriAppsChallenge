"use server";

import { revalidatePath } from "next/cache";

import { requireAdmin } from "@/lib/auth/admin";
import { createClient } from "@/lib/supabase/server";

export type MatchScheduleState = { message?: string; success?: boolean };

export async function scheduleMatch(
  _state: MatchScheduleState,
  formData: FormData,
): Promise<MatchScheduleState> {
  await requireAdmin();
  const matchId = String(formData.get("matchId") ?? "");
  const tournamentId = String(formData.get("tournamentId") ?? "");
  const startsAt = new Date(String(formData.get("startsAt") ?? ""));

  if (!matchId || !tournamentId || Number.isNaN(startsAt.valueOf())) {
    return { message: "Ingresá una fecha y hora válidas." };
  }
  if (startsAt <= new Date()) {
    return { message: "El partido debe programarse en el futuro." };
  }

  const supabase = await createClient();
  const { data, error } = await supabase
    .from("matches")
    .update({ starts_at: startsAt.toISOString() })
    .eq("id", matchId)
    .eq("tournament_id", tournamentId)
    .select("id")
    .maybeSingle();

  if (error || !data) {
    return { message: "No se pudo programar el partido. Revisá la fecha ingresada." };
  }

  revalidatePath(`/admin/torneos/${tournamentId}`);
  return { message: "Horario guardado.", success: true };
}
