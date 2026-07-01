"use client";

import { useActionState } from "react";

import { scheduleMatch, type MatchScheduleState } from "@/actions/matches";

function toLocalInput(value?: string | null) {
  if (!value) return "";
  const date = new Date(value);
  return new Date(date.getTime() - date.getTimezoneOffset() * 60_000).toISOString().slice(0, 16);
}

export function MatchScheduleForm({
  matchId,
  startsAt,
  tournamentId,
  tournamentStartsAt,
}: {
  matchId: string;
  startsAt: string | null;
  tournamentId: string;
  tournamentStartsAt: string;
}) {
  const [state, formAction, pending] = useActionState(scheduleMatch, {} as MatchScheduleState);
  const minimum =
    new Date(tournamentStartsAt) > new Date() ? tournamentStartsAt : new Date().toISOString();

  return (
    <form action={formAction} className="schedule-form">
      <input name="matchId" type="hidden" value={matchId} />
      <input name="tournamentId" type="hidden" value={tournamentId} />
      <input
        aria-label="Fecha y hora del partido"
        defaultValue={toLocalInput(startsAt)}
        min={toLocalInput(minimum)}
        name="startsAt"
        required
        type="datetime-local"
      />
      <button className="primary-button" disabled={pending}>
        {pending ? "Guardando…" : startsAt ? "Reprogramar" : "Programar"}
      </button>
      {state.message ? (
        <span className={state.success ? "form-success" : "form-error"} aria-live="polite">
          {state.message}
        </span>
      ) : null}
    </form>
  );
}
