# Registro de decisiones — 11. Partidos

[Volver al índice de registros](../registro-de-decisiones.md)

## 2026-06-30 — Programación administrativa

- La pantalla del torneo agrupa los encuentros por fase y permite programar también rondas cuyos participantes todavía dependen de ganadores anteriores.
- Cada partido conserva únicamente su fecha y hora de inicio; no se estima una duración ni una finalización.
- La Server Action valida sesión `ADMIN`, identificadores y fecha futura antes de actualizar un único encuentro.
- PostgreSQL exige que el horario sea futuro, no anterior al inicio del torneo y que un partido iniciado no pueda reprogramarse.
- El permiso SQL se limita a `matches.starts_at`: ni siquiera una sesión `ADMIN` puede usar esta operación directa para escribir marcadores o participantes.
