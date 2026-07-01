"use server";
import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth/admin";
import { createClient } from "@/lib/supabase/server";

export async function enrollTeam(formData: FormData) {
  await requireAdmin();
  const tournamentId = String(formData.get("tournamentId") ?? "");
  const teamId = String(formData.get("teamId") ?? "");
  const supabase = await createClient();
  await supabase.from("tournament_teams").insert({ tournament_id: tournamentId, team_id: teamId });
  revalidatePath(`/admin/torneos/${tournamentId}`);
}

export async function removeEnrollment(formData: FormData) {
  await requireAdmin();
  const tournamentId = String(formData.get("tournamentId") ?? "");
  const enrollmentId = String(formData.get("enrollmentId") ?? "");
  const supabase = await createClient();
  await supabase
    .from("tournament_teams")
    .delete()
    .eq("id", enrollmentId)
    .eq("tournament_id", tournamentId);
  revalidatePath(`/admin/torneos/${tournamentId}`);
}
