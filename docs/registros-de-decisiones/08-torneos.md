# Registro de decisiones — 08. Torneos

[Volver al índice de registros](../registro-de-decisiones.md)

## 2026-06-30 — CRUD administrativo para la entrega

### Estado

Implementada la primera versión funcional de alta, listado, edición y eliminación.

### Decisiones

- Las Server Actions vuelven a validar nombre, capacidad y fechas aunque PostgreSQL mantenga las restricciones definitivas.
- Los formularios usan `datetime-local` para la entrada y convierten los valores a instantes ISO antes de enviarlos a Supabase.
- La edición y eliminación se limitan a torneos futuros; PostgreSQL y RLS continúan siendo la protección autoritativa.
- La comprobación de pronósticos antes de eliminar queda pendiente para el regreso al backlog completo. No se implementa una consulta engañosa porque RLS oculta al administrador los pronósticos ajenos; la entrega administrativa no habilita ese flujo.
- La interfaz mantiene alta y mantenimiento en una sola pantalla para reducir navegación durante la demostración.

### Verificación

- Lint, TypeScript, formato y build de producción finalizaron correctamente.
- Next.js registró `/admin/torneos` como ruta dinámica protegida.
- Probar el flujo con la cuenta `ADMIN` de desarrollo.

## 2026-06-30 — Finalización derivada de la final

- La fecha de finalización se retiró del formulario porque una llave no tiene duración predecible.
- `ends_at` queda nullable para migrar sin destruir datos anteriores, pero los torneos nuevos lo guardan nulo.
- Los partidos pueden programarse desde `starts_at` sin un límite final artificial.
- `FINISHED` se deriva del resultado de la final y se retiró `is_overdue` de la vista.
