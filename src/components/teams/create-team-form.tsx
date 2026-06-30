"use client";

import { useActionState } from "react";

import { createTeam, type TeamActionState } from "@/actions/teams";

const initialState: TeamActionState = {};

export function CreateTeamForm() {
  const [state, action, pending] = useActionState(createTeam, initialState);
  return (
    <form action={action} className="entity-form">
      <div className="field-group">
        <label htmlFor="team-name">Nombre</label>
        <input id="team-name" name="name" required maxLength={80} />
      </div>
      <div className="field-group">
        <label htmlFor="team-abbreviation">Abreviatura</label>
        <input id="team-abbreviation" name="abbreviation" required maxLength={5} />
      </div>
      <div className="field-group">
        <label htmlFor="team-image">Escudo o bandera</label>
        <input
          id="team-image"
          name="image"
          required
          type="file"
          accept="image/png,image/jpeg,image/webp"
        />
      </div>
      {state.message ? (
        <p className={state.success ? "form-success" : "form-error"}>{state.message}</p>
      ) : null}
      <button className="primary-button" disabled={pending} type="submit">
        {pending ? "Guardando…" : "Crear equipo"}
      </button>
    </form>
  );
}
