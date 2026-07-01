# Registro de decisiones — 12. Consulta para usuarios

[Volver al índice de registros](../registro-de-decisiones.md)

## 2026-07-01 — Consulta pública para la entrega

- `/torneos` lista las competencias y comunica su estado derivado, capacidad y fecha de inicio sin exigir autenticación.
- `/torneos/[id]` muestra la llave completa por columnas, con cruces pendientes, horarios, resultados, penales y campeón.
- La vista utiliza exclusivamente las políticas públicas de lectura existentes; no incorpora una clave privilegiada ni operaciones de escritura.
- Los escudos se obtienen del bucket público `team-logos` y se omiten cuando un participante todavía depende de otro partido.
- La llave usa desplazamiento horizontal en pantallas angostas para conservar legibilidad sin alterar la estructura de eliminación directa.
- El detalle dinámico incorpora `loading.tsx` para ofrecer respuesta inmediata durante la navegación.

## 2026-07-01 — Horarios y transición automática de estado

- Los horarios públicos se presentan explícitamente con reloj de 24 horas y la zona `America/Argentina/Buenos_Aires`, evitando depender de la configuración regional del servidor de Vercel.
- Un torneo pasa a `IN_PROGRESS` solamente cuando llegó su fecha de inicio y la llave ya fue generada; alcanzar la fecha sin una llave no representa una competencia iniciada.
- La base de datos conserva la regla como fuente de verdad y una insignia cliente programa la transición visual al llegar la hora, para que una página abierta no necesite recargarse.
