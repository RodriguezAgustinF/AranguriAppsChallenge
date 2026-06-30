# Registro de decisiones — 04. Base de datos

[Volver al índice de registros](../registro-de-decisiones.md)

## 2026-06-29 — Enum de roles de usuario

### Tarea

Crear el enum de roles `ADMIN` y `USER`.

### Estado

Completada el 29 de junio de 2026.

### Decisiones

- El tipo PostgreSQL se llama `public.user_role`, en singular y `snake_case`, siguiendo las convenciones de nombres del proyecto.
- Sus únicos valores son `ADMIN` y `USER`, en mayúsculas, para mantener correspondencia directa con los roles definidos en el dominio.
- El enum pertenece al esquema `public` porque será utilizado por la tabla pública de perfiles y debe formar parte de los tipos generados para Supabase.
- La migración fue creada mediante el CLI y se llama `20260630000356_create_user_role_enum.sql`. El timestamp está expresado en UTC; por eso corresponde al 30 de junio aunque localmente la tarea se realizó durante la noche del 29 de junio en Buenos Aires.
- La migración usa una transacción explícita para evitar dejar cambios parciales si falla una instrucción.
- No se definió un valor predeterminado en el enum: los valores predeterminados pertenecen a las columnas que lo utilicen. La tabla de perfiles asignará `USER` de manera segura en la siguiente tarea.
- Se agregó el enum al tipo inicial `Database` para que el código TypeScript refleje inmediatamente la migración. Este archivo será reemplazado por la salida oficial del CLI cuando la migración pueda aplicarse a una base local o remota.
- El comentario SQL deja explícito que las cuentas `ADMIN` se aprovisionan manualmente, pero la restricción efectiva se implementará mediante la tabla, sus funciones y RLS en tareas posteriores.

### Alternativas descartadas

- **Guardar el rol como `text`:** permitiría valores inválidos y duplicaría validaciones en cada escritura.
- **Usar booleanos como `is_admin`:** expresa solo el caso actual y modela peor el concepto de rol.
- **Usar valores en minúsculas:** sería válido técnicamente, pero rompería la correspondencia ya acordada con `ADMIN` y `USER` en el dominio.

### Verificación

- Se comprobó que el archivo respeta el formato de migraciones definido por el proyecto.
- Se ejecutaron lint, comprobación de tipos, formato y build de producción.

## 2026-06-29 — Tablas centrales del dominio

### Tarea

Crear las tablas de torneos, equipos, equipos por torneo, fases, partidos, pronósticos y puntajes por torneo.

### Estado

Completada el 29 de junio de 2026.

### Decisiones

- Se crearon `tournaments`, `teams`, `tournament_teams`, `stages`, `matches`, `predictions` y `tournament_scores`, usando nombres en inglés, plural y `snake_case`.
- Todas las entidades usan UUID como clave primaria con `gen_random_uuid()`. Los perfiles son la excepción ya establecida porque reutilizan el UUID de `auth.users`.
- `stage_type` es un enum con `ROUND_OF_32`, `ROUND_OF_16`, `QUARTER_FINAL`, `SEMI_FINAL` y `FINAL`. No se agregó una fase de grupos porque está fuera del alcance.
- Los estados de torneos y partidos no se almacenan: continuarán derivándose de fechas y resultados para evitar una segunda fuente de verdad.
- El resultado oficial permanece dentro de `matches` mediante marcadores, ganador por penales y fecha de publicación; no se creó una tabla independiente.
- `matches` conserva referencias opcionales a equipos y a partidos de origen porque los participantes de rondas posteriores aún no se conocen al generar la llave.
- `tournament_scores` representa simultáneamente la participación de un usuario en un torneo y su puntaje materializado; no existe una tabla de inscripciones de usuarios.
- Las referencias a perfiles usan eliminación en cascada para retirar datos de un usuario eliminado. Los equipos usan eliminación restringida cuando ya están referenciados. Los componentes internos de un torneo usan cascada, aunque las reglas posteriores impedirán eliminar torneos con actividad.
- Esta migración incorpora estructura, claves primarias y relaciones fundamentales. Las restricciones de capacidad, unicidad, llave, fechas, resultados y penales se implementarán en las tareas específicas que siguen, para poder probar cada invariante por separado.

### Verificación

- Se recreó la base local desde cero y se aplicaron todas las migraciones en orden.
- Se comprobó la existencia de las siete tablas y de todas sus claves primarias mediante pruebas pgTAP.
- Se ejecutó `db lint`, se regeneraron los tipos TypeScript y se ejecutaron las verificaciones completas de la aplicación.

## 2026-06-29 — Capacidades permitidas de torneos

### Tarea

Restringir `team_count` a 4, 8, 16 o 32.

### Estado

Completada el 29 de junio de 2026.

### Decisiones

- Se agregó `tournaments_team_count_allowed` como restricción `CHECK` sobre `tournaments.team_count`.
- Los únicos valores admitidos son 4, 8, 16 y 32, todos potencias de dos compatibles con una llave de eliminación directa sin equipos libres.
- La regla vive en PostgreSQL y no solamente en validadores TypeScript, por lo que también protege escrituras realizadas mediante SQL, Dashboard o clientes alternativos.
- Se utilizó una restricción `CHECK` en lugar de un enum porque el dato es numérico y se usa en cálculos como `team_count - 1` y cantidad de rondas.

### Verificación

- Una prueba pgTAP confirmó que existe una restricción sobre la columna.
- Se insertaron correctamente torneos de 4, 8, 16 y 32 equipos dentro de una transacción de prueba.
- PostgreSQL rechazó un torneo de 6 equipos.
- Se recreó la base desde cero, se ejecutó `db lint` y se corrieron todas las pruebas de base de datos.

## 2026-06-29 — Escudos y banderas de equipos

### Motivo del cambio

El alcance excluía expresamente los escudos, pero el propietario confirmó que los equipos deben mostrarse con una imagen representativa, ya sea una bandera o un escudo.

### Decisiones

- La imagen pasa a ser obligatoria para todo equipo nuevo mediante `teams.logo_path` no nulo.
- `logo_path` almacena solo la ruta dentro del bucket y no una URL completa, evitando acoplar los registros al proyecto Supabase de desarrollo o producción.
- Se creó el bucket público `team-logos` mediante una migración versionada, que funciona en los entornos local, de desarrollo y de producción.
- Se permiten PNG, JPEG y WebP con un máximo de 1 MiB. No se admite SVG para reducir riesgos derivados de contenido activo.
- Las imágenes son públicas porque se mostrarán junto a equipos en vistas públicas. La carga, reemplazo y eliminación se limitarán a administradores mediante políticas de Storage en la fase 5.
- La migración restringe rutas vacías, con espacios exteriores o segmentos `..`.
- El servicio de equipos deberá compensar fallos entre Storage y PostgreSQL eliminando archivos huérfanos cuando corresponda, ya que ambos sistemas no comparten transacción.
- Se actualizaron alcance funcional, persistencia, ADR y backlog para incorporar la carga y visualización de imágenes.
- No se duplicó la definición en `config.toml`: hacerlo provocaba una solicitud de sobrescritura después de que la migración creaba el bucket durante cada `db reset`.

### Verificación

- Se recreó la base desde cero y se confirmó la columna obligatoria `teams.logo_path`.
- Se comprobó la configuración pública del bucket, su límite y sus tipos MIME permitidos.
- Se regeneraron los tipos TypeScript y se ejecutaron las pruebas de base de datos y de la aplicación.

## 2026-06-29 — Unicidad de inscripciones y posiciones de sorteo

### Tarea

Garantizar inscripciones y posiciones de sorteo únicas por torneo.

### Estado

Completada el 29 de junio de 2026.

### Decisiones

- `tournament_teams_tournament_team_unique` impide repetir la combinación `tournament_id`–`team_id`.
- El mismo equipo sí puede participar en torneos diferentes porque el catálogo es global y los torneos son independientes.
- `tournament_teams_tournament_draw_position_unique` impide repetir una posición de sorteo dentro del mismo torneo.
- `draw_position` continúa siendo nullable antes del sorteo. La semántica estándar de `UNIQUE` en PostgreSQL permite múltiples valores nulos, que representan inscripciones aún no sorteadas.
- La obligatoriedad, rango y bloqueo posterior de `draw_position` no se mezclan en esta migración: se implementarán junto con la generación y la inmutabilidad de la llave.
- Las restricciones únicas crean los índices necesarios para estas dos búsquedas; no se agregarán índices redundantes sobre las mismas combinaciones.

### Verificación

- Se probó que un equipo puede inscribirse en dos torneos diferentes.
- Se probó que varias inscripciones de un torneo pueden mantener posición nula antes del sorteo.
- PostgreSQL rechazó una inscripción duplicada dentro del mismo torneo.
- PostgreSQL rechazó dos posiciones iguales dentro del mismo torneo.
- Se recreó la base desde cero y se ejecutaron todas las pruebas pgTAP y `db lint`.

## 2026-06-30 — Estado derivado, atraso y campeón

### Tarea

Derivar `FINISHED` del resultado de la final y detectar torneos atrasados después de `ends_at`.

### Estado

Completada el 30 de junio de 2026.

### Decisiones

- `tournament_overview` es una vista `security_invoker` que añade `status`, `is_overdue` y `champion_team_id` sin persistir valores redundantes.
- `UPCOMING` significa que la hora de PostgreSQL todavía es anterior a `starts_at`.
- `IN_PROGRESS` comienza al alcanzar `starts_at` y continúa mientras la final no tenga resultado, incluso después de `ends_at`.
- `FINISHED` depende exclusivamente de `result_published_at` en el partido de la fase `FINAL`.
- `is_overdue` es verdadero cuando se alcanzó `ends_at` y la final sigue sin resultado.
- El campeón se deriva del marcador de la final y, en caso de empate, de `penalty_winner_team_id`.
- La vista no usa tareas programadas ni una columna de estado que pueda quedar desactualizada.

### Verificación

- Se probaron torneos próximos, en curso, atrasados y finalizados.
- Se comprobó que un torneo atrasado continúa `IN_PROGRESS`.
- Se comprobó que el resultado de la final produce `FINISHED` y el campeón correcto.
- Se recreó la base desde cero, se regeneraron los tipos TypeScript y se ejecutaron todas las pruebas, `db lint` y el build.

## 2026-06-30 — Coherencia temporal

### Tarea

Validar la coherencia de fechas de torneos y partidos.

### Estado

Completada el 30 de junio de 2026.

### Decisiones

- Todo torneo cumple `starts_at < ends_at` y debe comenzar en el futuro al crearse o reprogramarse.
- Las fechas de un torneo que ya comenzó no pueden modificarse.
- Un partido programado cumple `tournament.starts_at <= match.starts_at < tournament.ends_at`; el final del torneo es un límite exclusivo.
- Toda nueva programación debe quedar estrictamente en el futuro según `clock_timestamp()` de PostgreSQL.
- Un partido que ya comenzó no puede reprogramarse.
- Modificar el intervalo del torneo no puede dejar fuera a partidos que ya estaban programados.
- Las reglas temporales usan la hora del servidor de base de datos, no una fecha enviada por el navegador.

### Verificación

- Se rechazaron intervalos invertidos y torneos o partidos iniciados en el pasado.
- Se rechazaron partidos antes del torneo y exactamente en su límite final.
- Se aceptó un partido dentro del intervalo.
- Se rechazó acortar un torneo dejando fuera un partido programado.
- Se recreó la base desde cero y se ejecutaron todas las pruebas pgTAP y `db lint`.

## 2026-06-30 — Inmutabilidad de la llave generada

### Tarea

Impedir cambios en inscripciones, fases y cruces después de generar la llave.

### Estado

Completada el 30 de junio de 2026.

### Decisiones

- `bracket_generated_at` continúa siendo el indicador persistido de que la estructura quedó cerrada.
- Después de ese instante se bloquean altas, modificaciones y bajas de `tournament_teams` y `stages`.
- También se bloquean altas y bajas de partidos, además de cambios de torneo, fase, posición o fuentes.
- La capacidad y `bracket_generated_at` no pueden cambiar una vez generada la llave.
- `starts_at` y los campos del resultado permanecen editables por las operaciones autorizadas correspondientes.
- Los participantes solo pueden completarse si la transacción establece localmente `app.allow_bracket_progression = true`. La futura función `publish_match_result` será la única operación pública del proyecto que habilite esa marca mientras avanza un ganador.
- Las funciones protectoras son triggers con `search_path` vacío, sin `security definer` y sin permiso de ejecución directa para roles públicos.

### Verificación

- Se probaron bloqueos sobre capacidad, inscripciones, fases, partidos, posiciones y participantes.
- Se comprobó que programar un partido continúa permitido.
- Se comprobó que una transacción interna marcada puede completar un participante de una ronda posterior.
- Se recreó la base desde cero y se ejecutaron todas las pruebas pgTAP y `db lint`.

## 2026-06-30 — Coherencia del ganador por penales

### Tarea

Validar la coherencia condicional de `penalty_winner_team_id` en resultados y pronósticos.

### Estado

Completada el 30 de junio de 2026.

### Decisiones

- Un resultado o pronóstico empatado exige `penalty_winner_team_id`.
- Un marcador no empatado exige que `penalty_winner_team_id` sea nulo porque el ganador ya se deriva de los goles.
- En resultados oficiales, un `CHECK` confirma además que el ganador por penales sea local o visitante.
- En pronósticos, la condición empate/no empate se expresa con un `CHECK`; un trigger consulta el partido para asegurar que el equipo elegido sea uno de sus participantes.
- El trigger de pronósticos no usa `security definer`, fija un `search_path` vacío y no es ejecutable directamente por roles públicos.
- No se almacenan goles de la tanda: únicamente el equipo ganador, ya que el detalle de penales no afecta la puntuación.

### Verificación

- Se aceptaron empates oficiales y pronosticados con un participante como ganador por penales.
- Se rechazaron empates sin ganador, marcadores no empatados con ganador y equipos ajenos al partido en ambos contextos.
- Se recreó la base desde cero y se ejecutaron todas las pruebas pgTAP y `db lint`.

## 2026-06-30 — Forma inicial de los partidos de la llave

### Tarea

Validar que, al generar la llave, los partidos iniciales tengan equipos sin fuentes y los posteriores fuentes con equipos aún nulos.

### Estado

Completada el 30 de junio de 2026.

### Decisiones

- `matches_sources_complete` impide conservar solamente uno de los dos partidos de origen.
- El trigger `validate_new_bracket_match_before_insert` valida la forma del partido en el momento de crearlo.
- Un partido inicial debe insertarse con dos equipos resueltos y sin fuentes.
- Un partido dependiente debe insertarse con dos fuentes diferentes y ambos equipos nulos.
- La regla estricta de equipos nulos se aplica solo al `INSERT`: después, la publicación de resultados debe poder completar primero un participante y luego el otro sin borrar las fuentes.
- La función de trigger usa `search_path` vacío, no es `security definer` y no puede invocarse directamente desde los roles públicos.
- La pertenencia y el orden de fase de las fuentes, junto con la unicidad global de cada slot alimentado, se validarán en la siguiente regla específica entre filas.

### Verificación

- Se aceptaron dos partidos iniciales completos y una final pendiente con dos fuentes.
- PostgreSQL rechazó un partido inicial con un solo equipo, un partido posterior con un equipo prematuramente resuelto y un partido con una sola fuente.
- Se recreó la base desde cero y se ejecutaron todas las pruebas pgTAP y `db lint`.

## 2026-06-30 — Completitud del resultado oficial

### Tarea

Exigir que los dos marcadores oficiales sean ambos nulos o ambos no nulos.

### Estado

Completada el 30 de junio de 2026.

### Decisiones

- `matches_official_scores_complete` exige que `home_score` y `away_score` sean simultáneamente nulos o no nulos.
- `matches_result_publication_coherent` vincula la existencia del marcador completo con `result_published_at`: ambos conceptos aparecen y desaparecen juntos.
- Un partido sin resultado conserva los tres campos nulos. Un resultado publicado contiene ambos goles y su instante de publicación.
- La fecha no representa el final deportivo exacto del encuentro, sino el momento irreversible en que el administrador publicó el resultado en el sistema.
- La coherencia se aplica en PostgreSQL para impedir estados parciales incluso fuera de la operación transaccional que se implementará posteriormente.

### Verificación

- Se aceptaron correctamente un partido sin resultado y uno con resultado completo.
- PostgreSQL rechazó un único marcador, marcadores sin fecha de publicación y una fecha sin marcadores.
- Las pruebas de goles negativos se ajustaron para mantener completo el resto del resultado y aislar la restricción esperada.
- Se recreó la base desde cero y se ejecutaron todas las pruebas pgTAP y `db lint`.

## 2026-06-30 — Participantes distintos y goles no negativos

### Tarea

Impedir equipos iguales en un partido y valores de goles negativos.

### Estado

Completada el 30 de junio de 2026.

### Decisiones

- `matches_teams_distinct` exige equipos diferentes cuando ambos participantes están resueltos; permite valores nulos para los partidos de rondas posteriores que aún esperan ganadores.
- Los marcadores oficiales usan restricciones independientes para `home_score` y `away_score`, permitiendo nulos mientras no existe resultado pero rechazando cualquier valor negativo.
- Los marcadores pronosticados son obligatorios desde la creación y también deben ser mayores o iguales a cero.
- El valor cero es válido porque representa que un equipo no convierte goles.
- Las restricciones viven en PostgreSQL además de los validadores futuros de formularios, protegiendo todas las vías de escritura.

### Verificación

- PostgreSQL rechazó un partido con el mismo equipo en ambos lados.
- PostgreSQL rechazó goles negativos en ambos lados de resultados oficiales y pronósticos.
- Se comprobó que cero goles continúa siendo un valor válido; al completar la regla de penales, un pronóstico `0–0` también debe elegir al equipo ganador.
- Se recreó la base desde cero y se ejecutaron todas las pruebas pgTAP y `db lint`.

## 2026-06-30 — Unicidad de puntajes por torneo

### Tarea

Garantizar un único puntaje por usuario y torneo.

### Estado

Completada el 30 de junio de 2026.

### Decisiones

- `tournament_scores_user_tournament_unique` impide repetir la combinación `(user_id, tournament_id)`.
- Cada registro es el único acumulador de puntos del usuario en ese torneo y también representa su participación.
- Un usuario puede tener registros en torneos diferentes y un torneo puede contener registros de muchos usuarios.
- Las actualizaciones de resultados deberán modificar el acumulador existente, mientras que el primer pronóstico utilizará una inserción idempotente para crearlo con cero puntos.
- La restricción protege la idempotencia y la concurrencia incluso si dos primeros pronósticos del mismo torneo se guardan simultáneamente.
- El índice único cubre consultas que comienzan por `user_id`; se conserva `tournament_scores_tournament_id_idx` para rankings consultados por torneo.

### Verificación

- Se probó que un usuario puede participar en dos torneos.
- Se probó que dos usuarios pueden participar en el mismo torneo.
- PostgreSQL rechazó un segundo acumulador para el mismo usuario y torneo.
- Se recreó la base desde cero y se ejecutaron todas las pruebas pgTAP y `db lint`.

## 2026-06-29 — Relaciones reforzadas e índices

### Tarea

Agregar claves, relaciones e índices.

### Estado

Completada el 29 de junio de 2026.

### Decisiones

- La relación de `matches` con `stages` pasó a ser compuesta por `(stage_id, tournament_id)`, impidiendo asociar un partido con una fase de otro torneo.
- Los participantes y el ganador por penales de un resultado oficial referencian `(tournament_id, team_id)` de `tournament_teams`, no solamente el catálogo global. Así un partido no puede usar un equipo que no esté inscripto en su torneo.
- Las relaciones directas redundantes de esos campos hacia `teams.id` se reemplazaron por las relaciones compuestas; `tournament_teams.team_id` ya garantiza la existencia del equipo global.
- Se mantuvieron para una tarea posterior las reglas temporales y de fase de los partidos de origen, porque requieren validación entre filas más específica.
- Se agregaron índices para inicio de torneos, consultas de calendario por torneo, equipos locales y visitantes, partidos de origen, pronósticos por partido, puntajes por torneo e inscripciones inversas por equipo.
- No se duplicaron índices cuyo prefijo ya está cubierto por claves primarias o restricciones únicas.

### Verificación

- pgTAP confirmó la existencia de los nueve índices agregados.
- Se probó una combinación válida de torneo, fase y equipo inscripto.
- PostgreSQL rechazó una fase perteneciente a otro torneo.
- PostgreSQL rechazó un equipo no inscripto en el torneo del partido.
- Se recreó la base desde cero, se regeneraron los tipos TypeScript y se ejecutaron todas las pruebas y `db lint`.

## 2026-06-30 — Unicidad de pronósticos

### Tarea

Garantizar un único pronóstico por usuario y partido.

### Estado

Completada el 30 de junio de 2026.

### Decisiones

- `predictions_user_match_unique` impide repetir la combinación `(user_id, match_id)`.
- La restricción permite que un usuario pronostique partidos diferentes y que múltiples usuarios pronostiquen el mismo partido.
- Las ediciones posteriores deberán actualizar el registro existente en lugar de insertar otro, preservando un único identificador y fecha de creación.
- La regla se implementa en PostgreSQL para proteger también escrituras concurrentes: dos solicitudes simultáneas no pueden crear duplicados aunque ambas validen previamente que no existe un pronóstico.
- El índice único compuesto también cubre consultas que comienzan por `user_id`; se conserva `predictions_match_id_idx` porque la consulta inversa por partido no queda cubierta por ese orden de columnas.

### Verificación

- Se probó que un usuario puede pronosticar dos partidos diferentes.
- Se probó que dos usuarios pueden pronosticar el mismo partido.
- PostgreSQL rechazó un segundo pronóstico del mismo usuario para el mismo partido.
- Se recreó la base desde cero y se ejecutaron todas las pruebas pgTAP y `db lint`.

## 2026-06-29 — Estructura y dependencias de la llave

### Tarea

Modelar dependencias entre partidos y posiciones únicas dentro de cada fase.

### Estado

Completada el 29 de junio de 2026.

### Decisiones

- Cada fase conserva un `stage_order` positivo y único dentro del torneo.
- Cada `stage_type` aparece como máximo una vez por torneo. Esto evita, por ejemplo, dos semifinales modeladas como fases distintas en lugar de dos partidos dentro de una única fase.
- Cada partido mantiene un `bracket_position` positivo y único dentro de su fase.
- `home_source_match_id` y `away_source_match_id` continúan como claves foráneas autorreferenciales opcionales hacia `matches`. Así una posición de una ronda posterior representa que recibirá al ganador de un partido anterior.
- Un partido no puede usar el mismo encuentro como fuente de ambos lados.
- La validación de que las fuentes pertenezcan al mismo torneo, provengan de la fase inmediatamente anterior y alimenten un único slot se implementará en la tarea específica posterior; requiere lógica entre filas y no puede expresarse por completo con un `CHECK` local.
- Las restricciones únicas generan índices útiles para localizar fases y posiciones sin duplicar índices manuales.

### Verificación

- Se comprobaron las claves foráneas autorreferenciales con pgTAP.
- PostgreSQL rechazó órdenes y posiciones no positivas.
- PostgreSQL rechazó órdenes de fase, tipos de fase y posiciones de llave duplicados dentro de su contexto.
- PostgreSQL rechazó un partido que utilizaba la misma fuente para ambos lados.
- Se recreó la base desde cero y se ejecutaron todas las pruebas pgTAP y `db lint`.
- Se inició Supabase local con PostgreSQL 17 mediante Docker Desktop y se ejecutó `db reset`, recreando la base desde cero y aplicando la migración correctamente.
- `db lint` no encontró errores en los esquemas `extensions` y `public`.
- Una consulta directa al catálogo de PostgreSQL confirmó que `public.user_role` contiene exactamente `ADMIN` y `USER` en ese orden.
- Durante la verificación se corrigió el generador de tipos para invocar el CLI mediante Node.js de forma portable. Ejecutar el wrapper `.cmd` directamente con `execFileSync` producía `EINVAL` en Windows.
- `supabase/.temp` se excluyó de Prettier porque contiene catálogos efímeros generados por el CLI que no pertenecen al código fuente.

## 2026-06-29 — Perfiles vinculados con Supabase Authentication

### Tarea

Crear la tabla de perfiles vinculada con Supabase Authentication.

### Estado

Completada el 29 de junio de 2026.

### Decisiones

- La tabla se llama `public.profiles`. Se eligió este nombre porque `auth.users` ya representa las identidades y credenciales; la tabla pública extiende cada identidad con datos propios de la aplicación.
- `profiles.id` es simultáneamente clave primaria y clave foránea hacia `auth.users.id`, lo que garantiza una relación uno a uno e impide perfiles sin identidad.
- La relación usa `on delete cascade`: al eliminar definitivamente una identidad también se elimina su perfil, evitando datos de aplicación huérfanos.
- El perfil contiene `name`, `role` y `created_at`. El nombre es visible y se utilizará para rankings; debe estar recortado, no puede quedar vacío y admite hasta 80 caracteres.
- Los nombres visibles no son únicos. Dos personas pueden compartir nombre y el ranking ya utiliza `user_id` como último criterio técnico estable.
- El email no se duplica en `public.profiles`. Permanece en `auth.users`, evitando inconsistencias al cambiarlo y evitando exponerlo accidentalmente cuando los perfiles se consulten para rankings. Esta decisión corrige la lista conceptual de campos en `datos-y-seguridad.md`.
- `role` es obligatorio y tiene `USER` como valor predeterminado. La restricción efectiva del registro público no depende solamente del valor predeterminado: el trigger inserta explícitamente `USER` e ignora cualquier rol enviado en los metadatos del cliente.
- El trigger `on_auth_user_created` crea el perfil automáticamente después de insertar una identidad en `auth.users`, manteniendo el flujo de registro atómico dentro de PostgreSQL.
- El nombre inicial se toma de `raw_user_meta_data.name`, recortado y limitado a 80 caracteres. Para identidades administrativas creadas manualmente sin ese metadato se usa como respaldo la parte local del email y, como último recurso, `Usuario`.
- `handle_new_user()` es `security definer`, fija un `search_path` vacío y referencia objetos con esquema explícito. Además, se revocó su ejecución directa a `public`, `anon` y `authenticated`; debe ejecutarse únicamente mediante el trigger.
- Una cuenta administrativa se aprovisionará creando manualmente la identidad y cambiando su perfil recién generado a `ADMIN` mediante una operación administrativa de base de datos. No existirá un camino público que elija ese rol.
- RLS se habilitará en la fase 5, junto con las políticas del resto del esquema. Hasta entonces esta migración se concentra en integridad estructural y creación automática.

### Alternativas descartadas

- **Duplicar el email en `profiles`:** obliga a sincronizar cambios y aumenta el riesgo de exposición de información personal.
- **Crear el perfil desde una Server Action:** permite estados parciales si la identidad se crea pero la segunda operación falla.
- **Aceptar el rol desde metadatos de registro:** permitiría que un cliente intentara autoasignarse `ADMIN`.
- **Exigir nombres únicos:** no es un requisito funcional y rechazaría legítimamente a personas con el mismo nombre.

### Verificación

- Se recreó la base local desde cero y se aplicaron todas las migraciones en orden.
- Se ejecutó `db lint` y se regeneraron los tipos TypeScript desde PostgreSQL.
- Se probó que crear una identidad genera exactamente un perfil `USER` con el mismo UUID y el nombre normalizado.
- Se probó que enviar `ADMIN` dentro de los metadatos no modifica el rol asignado por el trigger.
- Se probó que eliminar la identidad elimina su perfil mediante cascada.
- Las verificaciones del perfil se guardaron como una prueba pgTAP versionada y repetible en `supabase/tests/profiles_test.sql`; se agregó `npm run db:test` para ejecutar las pruebas de PostgreSQL.
- Se ejecutaron lint, comprobación de tipos, formato y build de producción.
