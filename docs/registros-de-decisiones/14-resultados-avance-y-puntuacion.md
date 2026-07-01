# Registro de decisiones — 14. Resultados, avance y puntuación

[Volver al índice de registros](../registro-de-decisiones.md)

## 2026-07-01 — Resultado oficial y avance atómico

- `publish_match_result` bloquea primero el torneo y luego el partido para serializar publicaciones concurrentes de una misma llave.
- La función exige rol `ADMIN`, participantes resueltos, partido iniciado, goles no negativos y un ganador por penales exclusivamente ante un empate.
- Una sola transacción publica el resultado, asigna 0, 3 o 6 puntos a los pronósticos y ubica al ganador en el lado correspondiente del encuentro siguiente.
- Publicar la final no persiste un campeón duplicado: `tournament_overview` lo deriva del resultado definitivo de ese partido.
- Repetir exactamente la misma publicación es idempotente y no duplica puntos; enviar otro marcador se rechaza por inmutabilidad.
- La Server Action actúa como fachada de dominio: valida el formulario, invoca la RPC, traduce errores y revalida la pantalla administrativa.

## 2026-07-01 — Flujo de aceptación de la entrega

- Se conserva la semilla local sin llave generada para no saltar la operación administrativa que se desea demostrar.
- La guía propone una competencia de cuatro equipos y horarios cercanos para recorrer el flujo completo sin introducir una duración ficticia de los partidos.
- `admin_delivery_flow_test.sql` ejecuta sorteo, programación, semifinal con penales, propagación de ganadores, final y consulta pública del campeón.
- La prueba altera el reloj efectivo de sus fixtures únicamente después de comprobar la programación futura; así evita esperas reales sin relajar las reglas de producción.
