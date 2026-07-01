"use client";

import { useEffect, useState } from "react";

const statusNames = {
  FINISHED: "Finalizado",
  IN_PROGRESS: "En juego",
  UPCOMING: "Próximamente",
} as const;

type TournamentStatus = keyof typeof statusNames;

export function TournamentStatusBadge({
  bracketGeneratedAt,
  initialStatus,
  startsAt,
}: {
  bracketGeneratedAt: string | null;
  initialStatus: string | null;
  startsAt: string | null;
}) {
  const normalizedInitialStatus: TournamentStatus =
    initialStatus === "FINISHED" || initialStatus === "IN_PROGRESS" ? initialStatus : "UPCOMING";
  const [status, setStatus] = useState<TournamentStatus>(normalizedInitialStatus);

  useEffect(() => {
    if (normalizedInitialStatus === "FINISHED" || !bracketGeneratedAt || !startsAt) return;

    const startsAtTimestamp = new Date(startsAt).getTime();
    let timer: number | undefined;
    const updateAtStart = () => {
      const remaining = startsAtTimestamp - Date.now();
      if (remaining <= 0) {
        setStatus("IN_PROGRESS");
        return;
      }
      timer = window.setTimeout(updateAtStart, Math.min(remaining, 2_147_483_647));
    };

    updateAtStart();
    return () => {
      if (timer !== undefined) window.clearTimeout(timer);
    };
  }, [bracketGeneratedAt, normalizedInitialStatus, startsAt]);

  return (
    <span className={`status-badge status-${status.toLowerCase()}`}>{statusNames[status]}</span>
  );
}
