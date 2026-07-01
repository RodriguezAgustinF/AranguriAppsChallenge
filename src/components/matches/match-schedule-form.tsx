"use client";

import { useActionState, useState } from "react";

import { scheduleMatch, type MatchScheduleState } from "@/actions/matches";
import { localDateTimeToIso, toLocalDateTimeInput } from "@/lib/date-time";

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
  const [scheduledAt, setScheduledAt] = useState(startsAt ?? "");
  const minimum =
    new Date(tournamentStartsAt) > new Date() ? tournamentStartsAt : new Date().toISOString();

  return (
    <form action={formAction} className="schedule-form">
      <input name="matchId" type="hidden" value={matchId} />
      <input name="tournamentId" type="hidden" value={tournamentId} />
      <input name="startsAt" readOnly type="hidden" value={scheduledAt} />
      <input
        aria-label="Fecha y hora del partido"
        defaultValue={toLocalDateTimeInput(startsAt)}
        min={toLocalDateTimeInput(minimum)}
        onChange={(event) => setScheduledAt(localDateTimeToIso(event.target.value))}
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
