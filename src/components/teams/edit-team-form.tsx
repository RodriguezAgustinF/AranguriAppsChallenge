"use client";

import { useActionState } from "react";

import { updateTeam, type TeamActionState } from "@/actions/teams";

export function EditTeamForm({
  team,
}: {
  team: { abbreviation: string; id: string; name: string };
}) {
  const [state, action, pending] = useActionState(updateTeam, {} as TeamActionState);
  return (
    <details className="edit-panel">
      <summary>Editar</summary>
      <form action={action} className="entity-form">
        <input name="id" type="hidden" value={team.id} />
        <div className="field-group">
          <label htmlFor={`name-${team.id}`}>Nombre</label>
          <input id={`name-${team.id}`} name="name" defaultValue={team.name} required />
        </div>
        <div className="field-group">
          <label htmlFor={`abbr-${team.id}`}>Abreviatura</label>
          <input
            id={`abbr-${team.id}`}
            name="abbreviation"
            defaultValue={team.abbreviation}
            maxLength={5}
            required
          />
        </div>
        <div className="field-group">
          <label htmlFor={`image-${team.id}`}>Nueva imagen (opcional)</label>
          <input
            id={`image-${team.id}`}
            name="image"
            type="file"
            accept="image/png,image/jpeg,image/webp"
          />
        </div>
        {state.message ? (
          <p className={state.success ? "form-success" : "form-error"}>{state.message}</p>
        ) : null}
        <button className="primary-button" disabled={pending} type="submit">
          {pending ? "Guardando…" : "Guardar cambios"}
        </button>
      </form>
    </details>
  );
}
