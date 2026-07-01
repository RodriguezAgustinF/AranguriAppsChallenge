"use client";

import { useActionState, useState } from "react";

import { publishMatchResult, type MatchResultState } from "@/actions/matches";

export function MatchResultForm({
  awayTeam,
  homeTeam,
  matchId,
  tournamentId,
}: {
  awayTeam: { id: string; name: string };
  homeTeam: { id: string; name: string };
  matchId: string;
  tournamentId: string;
}) {
  const [state, formAction, pending] = useActionState(publishMatchResult, {} as MatchResultState);
  const [homeScore, setHomeScore] = useState("");
  const [awayScore, setAwayScore] = useState("");
  const isDraw = homeScore !== "" && awayScore !== "" && Number(homeScore) === Number(awayScore);

  return (
    <form
      action={formAction}
      className="result-form"
      onSubmit={(event) => {
        if (!window.confirm("¿Publicar este resultado? Después no podrá modificarse.")) {
          event.preventDefault();
        }
      }}
    >
      <input name="matchId" type="hidden" value={matchId} />
      <input name="tournamentId" type="hidden" value={tournamentId} />
      <label>
        <span>{homeTeam.name}</span>
        <input
          aria-label={`Goles de ${homeTeam.name}`}
          min="0"
          name="homeScore"
          onChange={(event) => setHomeScore(event.target.value)}
          required
          type="number"
          value={homeScore}
        />
      </label>
      <label>
        <span>{awayTeam.name}</span>
        <input
          aria-label={`Goles de ${awayTeam.name}`}
          min="0"
          name="awayScore"
          onChange={(event) => setAwayScore(event.target.value)}
          required
          type="number"
          value={awayScore}
        />
      </label>
      {isDraw ? (
        <label className="penalty-field">
          <span>Ganador por penales</span>
          <select name="penaltyWinnerId" required defaultValue="">
            <option value="" disabled>
              Elegir equipo
            </option>
            <option value={homeTeam.id}>{homeTeam.name}</option>
            <option value={awayTeam.id}>{awayTeam.name}</option>
          </select>
        </label>
      ) : null}
      <button className="primary-button" disabled={pending}>
        {pending ? "Publicando…" : "Publicar resultado definitivo"}
      </button>
      {state.message ? (
        <span className={state.success ? "form-success" : "form-error"} aria-live="polite">
          {state.message}
        </span>
      ) : null}
    </form>
  );
}
