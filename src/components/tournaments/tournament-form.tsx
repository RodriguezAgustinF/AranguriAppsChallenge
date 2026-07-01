"use client";

import { useActionState } from "react";
import { createTournament, updateTournament, type TournamentState } from "@/actions/tournaments";

type Tournament = {
  description: string | null;
  ends_at: string;
  id: string;
  name: string;
  starts_at: string;
  team_count: number;
};
const localDate = (value?: string) => (value ? new Date(value).toISOString().slice(0, 16) : "");

export function TournamentForm({ tournament }: { tournament?: Tournament }) {
  const action = tournament ? updateTournament : createTournament;
  const [state, formAction, pending] = useActionState(action, {} as TournamentState);
  return (
    <form action={formAction} className="entity-form">
      {tournament ? <input name="id" type="hidden" value={tournament.id} /> : null}
      <div className="field-group">
        <label>Nombre</label>
        <input name="name" defaultValue={tournament?.name} required maxLength={100} />
      </div>
      <div className="field-group">
        <label>Descripción</label>
        <input name="description" defaultValue={tournament?.description ?? ""} />
      </div>
      <div className="field-group">
        <label>Equipos</label>
        <select name="teamCount" defaultValue={tournament?.team_count ?? 4}>
          {[4, 8, 16, 32].map((value) => (
            <option key={value}>{value}</option>
          ))}
        </select>
      </div>
      <div className="field-group">
        <label>Inicio</label>
        <input
          name="startsAt"
          type="datetime-local"
          defaultValue={localDate(tournament?.starts_at)}
          required
        />
      </div>
      <div className="field-group">
        <label>Finalización estimada</label>
        <input
          name="endsAt"
          type="datetime-local"
          defaultValue={localDate(tournament?.ends_at)}
          required
        />
      </div>
      {state.message ? (
        <p className={state.success ? "form-success" : "form-error"}>{state.message}</p>
      ) : null}
      <button className="primary-button" disabled={pending}>
        {pending ? "Guardando…" : tournament ? "Guardar cambios" : "Crear torneo"}
      </button>
    </form>
  );
}
