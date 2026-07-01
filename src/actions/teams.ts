"use server";

import { randomUUID } from "node:crypto";

import { revalidatePath } from "next/cache";

import { requireAdmin } from "@/lib/auth/admin";
import { createClient } from "@/lib/supabase/server";

export type TeamActionState = { message?: string; success?: boolean };

const allowedImages = new Map([
  ["image/png", "png"],
  ["image/jpeg", "jpg"],
  ["image/webp", "webp"],
]);

export async function createTeam(
  _state: TeamActionState,
  formData: FormData,
): Promise<TeamActionState> {
  await requireAdmin();
  const name = String(formData.get("name") ?? "").trim();
  const abbreviation = String(formData.get("abbreviation") ?? "")
    .trim()
    .toUpperCase();
  const image = formData.get("image");

  if (name.length < 2 || name.length > 80) {
    return { message: "El nombre debe tener entre 2 y 80 caracteres." };
  }
  if (!/^[A-Z0-9]{2,5}$/.test(abbreviation)) {
    return { message: "La abreviatura debe tener entre 2 y 5 letras o números." };
  }
  if (!(image instanceof File) || image.size === 0) {
    return { message: "Seleccioná una imagen para el equipo." };
  }
  const extension = allowedImages.get(image.type);
  if (!extension || image.size > 1024 * 1024) {
    return { message: "La imagen debe ser PNG, JPEG o WebP y pesar hasta 1 MiB." };
  }

  const supabase = await createClient();
  const logoPath = `teams/${randomUUID()}.${extension}`;
  const { error: uploadError } = await supabase.storage
    .from("team-logos")
    .upload(logoPath, image, { contentType: image.type, upsert: false });

  if (uploadError) return { message: "No se pudo subir la imagen." };

  const { error: insertError } = await supabase.from("teams").insert({
    abbreviation,
    logo_path: logoPath,
    name,
  });

  if (insertError) {
    await supabase.storage.from("team-logos").remove([logoPath]);
    return { message: "No se pudo crear el equipo. Revisá si ya existe." };
  }

  revalidatePath("/admin/equipos");
  return { message: "Equipo creado correctamente.", success: true };
}

export async function deleteTeam(formData: FormData) {
  await requireAdmin();
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  const { data: team } = await supabase
    .from("teams")
    .select("logo_path")
    .eq("id", id)
    .maybeSingle();
  if (!team) return;

  const { error } = await supabase.from("teams").delete().eq("id", id);
  if (!error) {
    await supabase.storage.from("team-logos").remove([team.logo_path]);
    revalidatePath("/admin/equipos");
  }
}

export async function updateTeam(
  _state: TeamActionState,
  formData: FormData,
): Promise<TeamActionState> {
  await requireAdmin();
  const id = String(formData.get("id") ?? "");
  const name = String(formData.get("name") ?? "").trim();
  const abbreviation = String(formData.get("abbreviation") ?? "")
    .trim()
    .toUpperCase();
  const image = formData.get("image");
  if (name.length < 2 || name.length > 80 || !/^[A-Z0-9]{2,5}$/.test(abbreviation)) {
    return { message: "Revisá el nombre y la abreviatura." };
  }

  const supabase = await createClient();
  const { data: team } = await supabase
    .from("teams")
    .select("logo_path")
    .eq("id", id)
    .maybeSingle();
  if (!team) return { message: "El equipo no existe." };

  const now = new Date().toISOString();
  const { data: startedMatch } = await supabase
    .from("matches")
    .select("id")
    .or(`home_team_id.eq.${id},away_team_id.eq.${id}`)
    .lte("starts_at", now)
    .limit(1)
    .maybeSingle();
  if (startedMatch)
    return { message: "No se puede editar un equipo usado en un partido iniciado." };

  let nextLogoPath = team.logo_path;
  let uploadedPath: string | null = null;
  if (image instanceof File && image.size > 0) {
    const extension = allowedImages.get(image.type);
    if (!extension || image.size > 1024 * 1024) {
      return { message: "La imagen debe ser PNG, JPEG o WebP y pesar hasta 1 MiB." };
    }
    uploadedPath = `teams/${randomUUID()}.${extension}`;
    const { error } = await supabase.storage.from("team-logos").upload(uploadedPath, image, {
      contentType: image.type,
      upsert: false,
    });
    if (error) return { message: "No se pudo subir la nueva imagen." };
    nextLogoPath = uploadedPath;
  }

  const { error } = await supabase
    .from("teams")
    .update({ abbreviation, logo_path: nextLogoPath, name })
    .eq("id", id);
  if (error) {
    if (uploadedPath) await supabase.storage.from("team-logos").remove([uploadedPath]);
    return { message: "No se pudo actualizar el equipo." };
  }
  if (uploadedPath) await supabase.storage.from("team-logos").remove([team.logo_path]);
  revalidatePath("/admin/equipos");
  return { message: "Equipo actualizado.", success: true };
}
