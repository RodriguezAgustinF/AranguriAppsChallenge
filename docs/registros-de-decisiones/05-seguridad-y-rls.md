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

## 2026-06-30 — Lectura de pronósticos propios

### Tarea

Permitir que cada usuario consulte sus pronósticos.

### Estado

Completada el 30 de junio de 2026.

### Decisiones

- Solo `authenticated` recibe el privilegio `SELECT` sobre `predictions`; los visitantes anónimos no pueden consultar pronósticos.
- La política compara `predictions.user_id` con `auth.uid()`, una identidad obtenida del JWT validado por Supabase y no de un parámetro enviado por el cliente.
- `auth.uid()` se envuelve en una subconsulta escalar, siguiendo el patrón recomendado para que PostgreSQL pueda evaluarla una vez por consulta en lugar de repetirla para cada fila.
- La lectura no se limita por fecha: el propietario puede consultar sus pronósticos antes y después del partido. Las restricciones temporales corresponden exclusivamente a crear o editar.
- Esta migración no concede `INSERT`, `UPDATE` ni `DELETE`; las escrituras se habilitarán con condiciones adicionales en la tarea siguiente.

### Verificación

- Se crearon pronósticos para dos identidades y se simuló el JWT de una de ellas.
- El usuario autenticado obtuvo su propia fila y no pudo observar la del otro usuario, ni siquiera consultando directamente su UUID.
- El rol anónimo continuó sin privilegios de lectura sobre `predictions`.

## 2026-06-30 — Escritura de pronósticos antes del partido

### Tarea

Permitir crear o editar pronósticos propios solo antes del partido.

### Estado

Completada el 30 de junio de 2026.

### Decisiones

- `authenticated` recibe `INSERT` y `UPDATE` sobre `predictions`, pero no `DELETE`. El alcance permite corregir un pronóstico antes del partido, no retirar la participación eliminando la fila.
- Tanto la inserción como la actualización exigen que `auth.uid()` coincida con `user_id`.
- El partido debe tener local, visitante y `starts_at` resueltos. Los encuentros aún no programados o con participantes pendientes no aceptan pronósticos.
- PostgreSQL compara `clock_timestamp()` con `matches.starts_at`. La escritura se permite solo con una desigualdad estricta; exactamente al inicio queda bloqueada sin segundos de gracia.
- También se exige que el partido no tenga un resultado oficial. Aunque un resultado anterior al inicio sería inválido en el flujo normal, esta condición conserva el cierre incluso ante datos administrativos anómalos.
- La política de `UPDATE` aplica la misma regla en `USING` y `WITH CHECK`. Esto protege tanto la fila existente como cualquier intento de cambiar su propietario o trasladarla a otro partido.
- En esta fase se protege el acceso directo del cliente mediante RLS. Los validadores y servicios de dominio repetirán mensajes y reglas de negocio durante la implementación de pronósticos.

### Verificación

- Un usuario autenticado creó y modificó su pronóstico para un partido futuro.
- PostgreSQL rechazó crear una fila a nombre de otro usuario y una predicción para un partido sin horario.
- Una prueba con un inicio cercano guardó el pronóstico mientras el partido era futuro y confirmó que la actualización dejó de afectar filas después del inicio.

## 2026-06-30 — Priorización de la entrega administrativa

### Contexto

La entrega es el 1 de julio de 2026 y no resulta realista completar con calidad todos los flujos de pronósticos, puntuación y ranking antes de esa fecha.

### Decisiones

- Se creó `plan-de-entrega.md` con un camino crítico administrativo: acceso `ADMIN`, equipos, torneos, inscripciones, llave, programación, resultados, avance y vista pública.
- El backlog final no se elimina ni se redefine. Pronósticos, puntuación, ranking y registro público quedan pospuestos para continuar el proyecto después de la entrega.
- El trabajo de RLS de pronósticos ya implementado se conserva, pero deja de consumir tiempo del camino crítico inmediato.

## 2026-06-30 — Autorización administrativa centralizada

### Tarea

Restringir la administración al rol `ADMIN`.

### Estado

Completada el 30 de junio de 2026 para equipos, torneos e inscripciones.

### Decisiones

- `is_admin()` consulta el perfil correspondiente a `auth.uid()` y devuelve un booleano. Es `SECURITY DEFINER` para poder leer `profiles` sin crear una política recursiva ni exponer todos los perfiles.
- La función fija un `search_path` vacío, usa referencias calificadas y solo puede ser ejecutada por `authenticated`.
- Los usuarios autenticados reciben privilegios de escritura sobre `teams`, `tournaments` y `tournament_teams`, pero las políticas RLS los hacen efectivos exclusivamente cuando `is_admin()` es verdadero.
- No se habilitan escrituras directas sobre fases o partidos. La generación de la llave y la publicación de resultados tendrán fronteras transaccionales específicas para impedir que el cliente elija cruces o ganadores.
- El rol del JWT no decide la autorización de aplicación: tanto `ADMIN` como `USER` se autentican con el rol PostgreSQL `authenticated`; la diferencia confiable vive en `public.profiles.role`.

### Verificación

- Se simularon dos sesiones autenticadas con perfiles `ADMIN` y `USER`.
- El administrador pudo crear un equipo, un torneo y una inscripción.
- El usuario común no pudo crear equipos ni modificar el torneo existente.
