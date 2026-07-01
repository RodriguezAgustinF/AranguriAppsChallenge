"use server";

import { revalidatePath } from "next/cache";

import { requireAdmin } from "@/lib/auth/admin";
import { createClient } from "@/lib/supabase/server";

export type MatchScheduleState = { message?: string; success?: boolean };
export type MatchResultState = { message?: string; success?: boolean };

export async function scheduleMatch(
  _state: MatchScheduleState,
  formData: FormData,
): Promise<MatchScheduleState> {
  await requireAdmin();
  const matchId = String(formData.get("matchId") ?? "");
  const tournamentId = String(formData.get("tournamentId") ?? "");
  const startsAtValue = String(formData.get("startsAt") ?? "");
  const startsAt = new Date(startsAtValue);

  if (
    !matchId ||
    !tournamentId ||
    !/([zZ]|[+-]\d{2}:\d{2})$/.test(startsAtValue) ||
    Number.isNaN(startsAt.valueOf())
  ) {
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

export async function publishMatchResult(
  _state: MatchResultState,
  formData: FormData,
): Promise<MatchResultState> {
  await requireAdmin();
  const matchId = String(formData.get("matchId") ?? "");
  const tournamentId = String(formData.get("tournamentId") ?? "");
  const homeScoreValue = String(formData.get("homeScore") ?? "");
  const awayScoreValue = String(formData.get("awayScore") ?? "");
  const penaltyWinnerId = String(formData.get("penaltyWinnerId") ?? "") || null;

  if (!matchId || !tournamentId || !/^\d+$/.test(homeScoreValue) || !/^\d+$/.test(awayScoreValue)) {
    return { message: "Ingresá marcadores enteros y no negativos." };
  }

  const homeScore = Number(homeScoreValue);
  const awayScore = Number(awayScoreValue);
  if (homeScore === awayScore && !penaltyWinnerId) {
    return { message: "Elegí quién ganó por penales." };
  }
  if (homeScore !== awayScore && penaltyWinnerId) {
    return { message: "Solo corresponde indicar penales cuando el marcador está empatado." };
  }

  const supabase = await createClient();
  const { error } = await supabase.rpc("publish_match_result", {
    official_away_score: awayScore,
    official_home_score: homeScore,
    official_penalty_winner_team_id: penaltyWinnerId ?? undefined,
    target_match_id: matchId,
  });

  if (error) {
    const messages: Record<string, string> = {
      "a drawn match requires a participating penalty winner":
        "Elegí un participante como ganador por penales.",
      "a match with an official result is immutable":
        "El resultado oficial ya fue publicado y no puede modificarse.",
      "the match must have started before publishing its result": "El partido todavía no comenzó.",
    };
    return { message: messages[error.message] ?? "No se pudo publicar el resultado oficial." };
  }

  revalidatePath(`/admin/torneos/${tournamentId}`);
  return { message: "Resultado oficial publicado.", success: true };
}
