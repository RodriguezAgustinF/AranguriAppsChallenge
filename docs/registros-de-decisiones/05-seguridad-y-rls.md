# Registro de decisiones — 05. Seguridad y RLS

[Volver al índice de registros](../registro-de-decisiones.md)

## 2026-06-30 — RLS habilitado por defecto

### Tarea

Habilitar RLS en todas las tablas expuestas.

### Estado

Completada el 30 de junio de 2026.

### Decisiones

- Se habilitó Row Level Security en las ocho tablas del esquema `public`: `profiles`, `tournaments`, `teams`, `tournament_teams`, `stages`, `matches`, `predictions` y `tournament_scores`.
- La migración no crea políticas. PostgreSQL aplica así una postura inicial de denegación total para `anon` y `authenticated`; cada permiso se abrirá deliberadamente en las tareas siguientes.
- No se utilizó `FORCE ROW LEVEL SECURITY`. Los clientes de Supabase no son propietarios de las tablas y quedan sujetos a RLS; conservar el comportamiento normal del propietario permite ejecutar migraciones, semillas y mantenimiento local.
- `tournament_overview` es una vista `security_invoker`, por lo que las consultas se evalúan con los permisos y políticas del rol que la invoca. Las vistas no reciben `ENABLE ROW LEVEL SECURITY` directamente.
- `storage.objects` pertenece al esquema administrado por Supabase y ya utiliza RLS. Sus políticas para el bucket `team-logos` se definirán en la tarea específica de Storage.
- La clave `service_role` conserva su capacidad administrativa de omitir RLS, pero no se expondrá ni se utilizará desde la aplicación. Las operaciones del MVP usarán sesiones autenticadas y políticas explícitas.

### Verificación

- pgTAP comprueba `relrowsecurity = true` para cada tabla pública.
- Antes de conceder privilegios y crear políticas, el rol `anon` no puede leer los equipos ni los torneos sembrados.
- PostgreSQL rechaza también una inserción anónima en `tournaments`; los privilegios se concederán junto con cada política para no abrir operaciones innecesarias.

## 2026-06-30 — Lectura pública de la competición

### Tarea

Permitir consultar torneos, equipos y partidos disponibles.

### Estado

Completada el 30 de junio de 2026.

### Decisiones

- Los roles `anon` y `authenticated` reciben exclusivamente `SELECT` sobre `tournaments`, `teams`, `tournament_teams`, `stages`, `matches` y la vista `tournament_overview`.
- Además de las tres entidades mencionadas por la tarea, se permite leer inscripciones y fases. Ambas son necesarias para reconstruir los participantes y la estructura de una llave sin consultas privilegiadas.
- Las cinco tablas tienen políticas RLS de lectura con `using (true)`. En el MVP no existe el concepto de borrador privado o torneo oculto; por lo tanto, todo torneo almacenado forma parte del catálogo disponible.
- La vista `tournament_overview` no tiene una política propia porque es `security_invoker`: aplica las políticas de `tournaments`, `stages` y `matches` con el rol del cliente.
- No se concedieron privilegios `INSERT`, `UPDATE` ni `DELETE`. Las políticas de lectura no amplían accidentalmente las capacidades de escritura.
- Los perfiles y datos de participación continúan cerrados; se abrirán solamente en las tareas de pronósticos y ranking.

### Verificación

- Un visitante anónimo pudo consultar un torneo, sus equipos, inscripciones, fase, partido y estado derivado.
- Un usuario autenticado pudo consultar el mismo catálogo.
- PostgreSQL continuó rechazando la eliminación de un partido por el rol anónimo.
