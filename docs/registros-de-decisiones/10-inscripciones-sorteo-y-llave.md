# Registro de decisiones — 10. Inscripciones, sorteo y llave

[Volver al índice de registros](../registro-de-decisiones.md)

## 2026-06-30 — Inscripciones administrativas

- El detalle muestra capacidad, participantes y lugares disponibles.
- El selector excluye equipos inscriptos y PostgreSQL conserva la unicidad.
- Las Server Actions exigen `ADMIN`; RLS y los triggers bloquean cambios después del sorteo.
- El sorteo se agregará mediante la función transaccional `generate_bracket`.
