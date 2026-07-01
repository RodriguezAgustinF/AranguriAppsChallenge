"use client";

import { useActionState, useState } from "react";
import { createTournament, updateTournament, type TournamentState } from "@/actions/tournaments";
import { localDateTimeToIso, toLocalDateTimeInput } from "@/lib/date-time";

type Tournament = {
  description: string | null;
  id: string;
  name: string;
  starts_at: string;
  team_count: number;
};
export function TournamentForm({ tournament }: { tournament?: Tournament }) {
  const action = tournament ? updateTournament : createTournament;
  const [state, formAction, pending] = useActionState(action, {} as TournamentState);
  const [startsAt, setStartsAt] = useState(tournament?.starts_at ?? "");
  return (
    <form action={formAction} className="entity-form">
      {tournament ? <input name="id" type="hidden" value={tournament.id} /> : null}
      <input name="startsAt" readOnly type="hidden" value={startsAt} />
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
          type="datetime-local"
          defaultValue={toLocalDateTimeInput(tournament?.starts_at)}
          onChange={(event) => setStartsAt(localDateTimeToIso(event.target.value))}
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
