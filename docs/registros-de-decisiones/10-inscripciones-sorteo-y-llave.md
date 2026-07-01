# Registro de decisiones — 10. Inscripciones, sorteo y llave

[Volver al índice de registros](../registro-de-decisiones.md)

## 2026-06-30 — Inscripciones administrativas

- El detalle muestra capacidad, participantes y lugares disponibles.
- El selector excluye equipos inscriptos y PostgreSQL conserva la unicidad.
- Las Server Actions exigen `ADMIN`; RLS y los triggers bloquean cambios después del sorteo.
- El sorteo se agregará mediante la función transaccional `generate_bracket`.

## 2026-06-30 — Generación transaccional de la llave

- `generate_bracket` bloquea el torneo, verifica rol `ADMIN`, cupo completo y ausencia de un sorteo previo.
- Las posiciones se asignan aleatoriamente con `gen_random_uuid()` dentro de PostgreSQL.
- La función crea las fases correspondientes a 4, 8, 16 o 32 equipos y exactamente `team_count - 1` partidos.
- Los partidos iniciales reciben equipos por posición; los posteriores reciben referencias a los dos encuentros de la ronda anterior.
- `bracket_generated_at` se establece al final. Cualquier error revierte posiciones, fases, partidos y marca de generación en conjunto.
- pgTAP verificó llaves de 4, 8, 16 y 32 equipos, sus 2, 3, 4 y 5 fases, y sus 3, 7, 15 y 31 partidos respectivamente.
- También se rechazaron un segundo sorteo y un torneo con cupo incompleto.

## 2026-06-30 — Programación de partidos

- La pantalla del torneo agrupa los encuentros por fase y permite programar también rondas cuyos participantes todavía dependen de ganadores anteriores.
- Cada partido conserva únicamente su fecha y hora de inicio; no se estima una duración ni una finalización.
- La Server Action valida sesión `ADMIN`, identificadores y fecha futura antes de actualizar un único encuentro.
- PostgreSQL exige que el horario sea futuro, no anterior al inicio del torneo y que un partido iniciado no pueda reprogramarse.
- El permiso SQL se limita a `matches.starts_at`: ni siquiera una sesión `ADMIN` puede usar esta operación directa para escribir marcadores o participantes.
