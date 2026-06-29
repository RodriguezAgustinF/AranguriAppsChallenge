# Registro de decisiones — 01. Definiciones iniciales

[Volver al índice de registros](../registro-de-decisiones.md)

Este documento registra las decisiones tomadas durante la ejecución del backlog. Cada entrada explica el contexto, la decisión, sus motivos, las alternativas descartadas y los cambios realizados.

## 2026-06-27 — Versiones iniciales del proyecto

### Tarea

Confirmar las versiones de Node.js, Next.js y las dependencias principales.

### Contexto

El repositorio contenía únicamente la documentación funcional, arquitectónica y el backlog. No existía todavía un `package.json` ni una aplicación inicializada.

El entorno local tenía Node.js `22.19.0` y npm `10.9.3`. Aunque Node.js 22 todavía recibe mantenimiento, Node.js 24 es la línea LTS vigente. Next.js requiere como mínimo Node.js `20.9.0`.

### Decisiones

| Componente | Versión fijada | Motivo |
| --- | ---: | --- |
| Node.js | `24.18.0` | Es la versión LTS estable vigente. Se evita Node.js 26 porque todavía está en el canal Current. |
| npm | `11.16.0` | Es la versión incluida con Node.js 24.18.0 y será el gestor de paquetes único para evitar múltiples archivos de bloqueo e instalaciones globales adicionales. |
| Next.js | `16.2.9` | Es la versión estable actual. No se utilizará Next.js 16.3 mientras permanezca como Preview. |
| React | `19.2.7` | Versión estable actual y compatible con los peer dependencies de Next.js 16.2.9. |
| React DOM | `19.2.7` | Se mantiene alineada con la versión de React. |
| TypeScript | `6.0.3` | Versión estable actual; el proyecto utilizará modo estricto. |
| Tailwind CSS | `4.3.2` | Versión estable al inicializar el proyecto y coherente con la arquitectura definida. |
| ESLint | `9.39.4` | Última versión estable de la línea 9 y compatible en ejecución con los plugins incluidos por `eslint-config-next` 16.2.9. ESLint 10 fue descartado después de una verificación real del scaffold. |
| eslint-config-next | `16.2.9` | Se alinea exactamente con Next.js para evitar reglas incompatibles. |
| @supabase/supabase-js | `2.108.2` | Versión estable actual del SDK principal de Supabase. |
| @supabase/ssr | `0.12.0` | Versión estable actual y compatible con `@supabase/supabase-js` 2.108.x. |

Las versiones directas se instalarán de forma exacta y el archivo `package-lock.json` será la fuente reproducible para las dependencias transitivas. Las actualizaciones posteriores se harán deliberadamente en tareas separadas, acompañadas por pruebas.

### Alternativas descartadas

- **Conservar Node.js 22:** es compatible, pero ofrece un horizonte de mantenimiento menor que Node.js 24 para un proyecto nuevo.
- **Usar Node.js 26:** es más reciente, pero todavía no es LTS y aumenta el riesgo de incompatibilidades tempranas.
- **Usar etiquetas `latest` o rangos amplios como fuente de verdad:** harían que instalaciones realizadas en fechas distintas pudieran resolver versiones diferentes.
- **Usar Next.js 16.3 Preview:** se prioriza estabilidad para el MVP sobre funcionalidades preliminares.
- **Usar varios gestores de paquetes:** podría producir lockfiles y resoluciones de dependencias contradictorias.

### Consecuencias y próximos pasos

- Se agregó `.nvmrc` con Node.js `24.18.0` para declarar la versión esperada del runtime.
- La máquina local deberá actualizarse desde Node.js `22.19.0` antes de inicializar la aplicación.
- La siguiente tarea deberá crear el proyecto y reflejar estas decisiones en `package.json` y `package-lock.json`.
- La compatibilidad real se verificará ejecutando instalación, lint, type-check y build durante la inicialización.

### Fuentes consultadas

- [Versiones y ciclo LTS de Node.js](https://nodejs.org/en/about/previous-releases)
- [Descarga oficial de Node.js 24.18.0 LTS](https://nodejs.org/en/download)
- [Notas de Node.js 24.18.0 LTS](https://nodejs.org/en/blog/release/v24.18.0)
- [Requisitos de instalación de Next.js](https://nextjs.org/docs/app/getting-started/installation)
- [Publicaciones oficiales de Next.js](https://nextjs.org/blog)
- Metadatos y peer dependencies publicados en el registro de npm para cada paquete.

### Rectificación posterior

El mismo 27 de junio se volvió a consultar la página oficial de Node.js y se confirmó que `24.18.0`, publicada el 23 de junio de 2026, había reemplazado a `24.17.0` como último parche LTS. La primera consulta devolvió información desactualizada. Se corrigieron esta decisión y `.nvmrc` antes de inicializar el proyecto, por lo que no fue necesaria ninguna migración de código ni dependencias.

## 2026-06-27 — Convenciones de nombres e idioma

### Tarea

Adoptar nombres en inglés para código, tablas, columnas y migraciones.

### Contexto

La arquitectura ya indicaba que el código debía escribirse en inglés, pero dejaba alternativas abiertas para carpetas y no especificaba reglas para archivos, URLs, claves foráneas, estados ni migraciones. Mantener varias opciones habría permitido estilos distintos dentro del mismo proyecto.

### Decisiones

- El código y el modelo de datos utilizarán nombres en inglés.
- Variables, funciones y métodos usarán `camelCase`.
- Los booleanos usarán prefijos que expresen intención: `is`, `has`, `can` o `should`.
- Componentes, clases, tipos, interfaces y enums de TypeScript usarán `PascalCase`.
- Los hooks comenzarán con `use` y usarán `camelCase`.
- Las constantes globales y variables de entorno usarán `UPPER_SNAKE_CASE`.
- Los archivos de componentes React usarán `PascalCase.tsx` para coincidir con el nombre exportado.
- Los demás archivos y carpetas propias usarán `kebab-case`.
- Los archivos reservados por Next.js conservarán los nombres exigidos por el framework, como `page.tsx`, `layout.tsx` y `route.ts`.
- Las rutas usarán segmentos ingleses en `kebab-case`.
- PostgreSQL usará `snake_case`, tablas en plural, `id` como clave primaria y `<entity>_id` como clave foránea.
- Los roles y estados persistidos usarán valores `UPPER_SNAKE_CASE`, coherentes con `ADMIN` y `USER` ya definidos.
- Las migraciones usarán `<timestamp>_<description_in_snake_case>.sql`, lo que mantiene orden cronológico y una descripción legible.
- Las Server Actions usarán verbo y objeto en `camelCase`, por ejemplo `createTournament` o `publishMatchResult`.
- La interfaz y la documentación funcional podrán estar en español porque su audiencia es hispanohablante. Los comentarios técnicos se escribirán en inglés y solo explicarán decisiones no evidentes.

### Vocabulario base del dominio

| Español | Nombre adoptado |
| --- | --- |
| Usuario / perfil | `user` / `profile` |
| Torneo | `tournament` |
| Equipo | `team` |
| Partido | `match` |
| Pronóstico | `prediction` |
| Puntaje por torneo | `tournamentScore` / `tournament_scores` |
| Resultado oficial | `officialResult` |
| Tabla de posiciones | `ranking` |

Se distingue `user` de `profile`: Supabase Authentication administra la identidad autenticable y la tabla `profiles` conserva los datos de dominio y el rol de la aplicación.

### Alternativas descartadas

- **Mezclar español e inglés en el código:** genera traducciones inconsistentes y dificulta integrarse con APIs y documentación técnica.
- **Permitir indistintamente carpetas en minúsculas o `kebab-case`:** deja una decisión repetida para cada módulo y favorece inconsistencias.
- **Usar `camelCase` también en PostgreSQL:** obliga a citar identificadores o a aceptar conversiones poco naturales en SQL.
- **Usar nombres singulares para tablas:** se eligieron plurales porque las tablas representan colecciones y este criterio será uniforme en todo el esquema.
- **Escribir todos los textos en inglés:** no aporta valor al usuario objetivo y empeora la claridad de la interfaz y documentación funcional.

### Consecuencias y próximos pasos

- Se amplió la sección de convenciones de `arquitectura.md` para convertir la decisión en una regla del proyecto.
- Los nombres concretos del esquema deberán respetar estas convenciones cuando se creen las migraciones.
- ESLint y el formateador cubrirán el estilo automatizable; las convenciones semánticas se revisarán durante el desarrollo.
- Si un framework exige un nombre reservado, su convención tendrá prioridad y deberá documentarse cualquier excepción adicional.

### Aclaración sobre `officialResult`

`officialResult` representa un concepto de dominio y la entrada usada al publicar un resultado; no representa una entidad ni una tabla. El resultado se almacenará en `matches` mediante los goles oficiales y `result_published_at`. Una entidad separada solo sería necesaria si se incorporaran historial de correcciones, múltiples publicaciones o auditoría detallada, funcionalidades fuera del MVP.

## 2026-06-27 — Estados de torneos y partidos

### Tarea

Definir los estados válidos de torneos y partidos y sus transiciones.

### Contexto

La arquitectura incluía un campo genérico de estado para ambas entidades, pero no definía sus valores ni quién podía cambiarlos. Persistir y actualizar manualmente estados que dependen del tiempo podría producir contradicciones, por ejemplo un torneo marcado como próximo después de su fecha de inicio.

El partido solo posee una hora de inicio. El MVP no almacena una hora real de finalización ni consume una API deportiva externa, por lo que el sistema puede determinar cuándo comenzó, pero no comprobar autónomamente cuándo terminó en el mundo real.

### Decisiones

#### Torneos

- `UPCOMING`: `serverNow < startsAt`.
- `IN_PROGRESS`: `serverNow >= startsAt` y la final todavía no posee resultado oficial.
- `FINISHED`: la final posee resultado oficial y existe un campeón.
- La transición es `UPCOMING` → `IN_PROGRESS` → `FINISHED`; la primera ocurre por el tiempo y la segunda por el resultado oficial de la final.
- Solo un torneo `UPCOMING` puede editarse o eliminarse.

#### Partidos

- `UNSCHEDULED`: `startsAt` es nulo.
- `SCHEDULED`: `serverNow < startsAt` y no existe un resultado oficial.
- `STARTED`: `serverNow >= startsAt` y no existe un resultado oficial.
- `FINISHED`: existen los dos goles oficiales y `resultPublishedAt`.
- La transición válida es `UNSCHEDULED` → `SCHEDULED` → `STARTED` → `FINISHED`.
- La programación o reprogramación se bloquea al salir de `SCHEDULED`; los partidos de la llave no se eliminan individualmente.
- No se puede publicar un resultado antes de `startsAt`.
- Publicar el resultado produce el estado terminal `FINISHED`; después no puede editarse ni eliminarse.

Los nombres anteriores serán uniones o enums del dominio para presentar y validar el estado lógico. No se persistirá un estado temporal que deba actualizarse mediante tareas programadas. La fuente de verdad serán las fechas, los goles oficiales y `resultPublishedAt`.

### Responsabilidad administrativa

La aplicación comprobará que el partido haya comenzado, pero el administrador será responsable de confirmar que realmente terminó antes de publicar el resultado. Esta limitación es explícita: inferir una finalización automática a los 90 minutos sería incorrecto por entretiempo, tiempo agregado, alargue, penales, interrupciones o suspensiones.

### Alternativas descartadas

- **Persistir estados y actualizarlos manualmente:** permite divergencias entre el estado y las fechas.
- **Ejecutar tareas programadas para actualizar estados:** agrega infraestructura sin aportar información que no pueda derivarse al consultar.
- **Finalizar el torneo automáticamente en `endsAt`:** podría declarar terminado un torneo cuya final aún no posee resultado.
- **Inferir que un partido termina después de una duración fija:** no representa de manera fiable un encuentro real.
- **Agregar una acción separada para marcar el partido como terminado:** introduce un paso administrativo adicional sin una necesidad funcional en el MVP.
- **Agregar `DRAFT`, `CANCELLED`, `POSTPONED` o `SUSPENDED`:** el alcance no define sus efectos sobre torneos, partidos ni pronósticos.

### Consecuencias y próximos pasos

- Se agregó la definición formal a `arquitectura.md`.
- Las fechas se nombrarán `starts_at` y `ends_at` en PostgreSQL, y `startsAt` y `endsAt` en TypeScript.
- El modelo de partido usará `starts_at`; `FINISHED` se derivará de sus goles oficiales y `result_published_at`.
- Se retiraron los campos genéricos de estado del modelo conceptual de torneos y partidos para que no exista una segunda fuente de verdad desactualizable.
- Los campos conceptuales del modelo se renombraron en inglés para aplicar la convención aprobada en la tarea anterior.
- Las funciones de dominio que calculen estados deberán recibir explícitamente la hora del servidor para poder probar los límites temporales.
- Si el producto necesita cancelaciones o reprogramaciones después de iniciado el MVP, primero deberán ampliarse el alcance y las transiciones.

## 2026-06-27 — Fechas, límites temporales y zona horaria

### Tarea

Definir las validaciones de fechas y la zona horaria del sistema.

### Contexto

El inicio de torneos y partidos determina cuándo se bloquean operaciones críticas. Sin una convención explícita, el navegador, el servidor y PostgreSQL podrían interpretar una misma fecha con zonas horarias distintas. También era necesario definir qué ocurre exactamente en el instante de inicio y qué fechas son aceptables al crear o reprogramar entidades.

### Decisiones

- Todos los instantes se persistirán como `timestamptz` y se normalizarán a UTC.
- La interfaz mostrará fechas usando `America/Argentina/Buenos_Aires`, zona IANA correspondiente al público inicial del MVP.
- Los formularios enviarán instantes inequívocos con offset; no enviarán fechas locales sin zona para que el servidor las interprete implícitamente.
- Las reglas usarán la hora del servidor o de PostgreSQL. El reloj del navegador solo podrá usarse para actualizar la interfaz de forma orientativa.
- `startsAt` y `endsAt` representarán instantes, no fechas de calendario sin hora.
- No habrá segundos de gracia: al llegar exactamente a `startsAt`, las modificaciones y los pronósticos quedan bloqueados.

#### Torneos

- Debe cumplirse `startsAt < endsAt`.
- Un torneo nuevo debe tener `startsAt > serverNow`.
- Puede editarse o eliminarse solo cuando `serverNow < startsAt`.
- Si se cambian sus fechas, todos sus partidos existentes deben continuar dentro del intervalo nuevo.

#### Partidos

- Debe cumplirse `tournament.startsAt <= match.startsAt < tournament.endsAt`.
- Un partido nuevo o reprogramado debe tener `startsAt > serverNow`.
- Puede editarse o eliminarse solo cuando `serverNow < startsAt`.
- Un resultado puede publicarse cuando `serverNow >= startsAt`, siempre que no exista uno previo.

#### Pronósticos

- Pueden crearse o modificarse solo cuando `serverNow < match.startsAt`.
- La comparación se repetirá en el servidor inmediatamente antes de persistir.

### Alternativas descartadas

- **Guardar horas locales sin zona:** genera instantes ambiguos y dificulta despliegues en servidores con otra configuración regional.
- **Guardar un offset fijo `UTC-03:00`:** una zona IANA conserva el significado regional y permite absorber cambios normativos futuros.
- **Confiar en el reloj del navegador:** el usuario puede modificarlo y distintos dispositivos pueden estar desincronizados.
- **Permitir una tolerancia después del inicio:** debilita una regla funcional clara y crea resultados distintos según latencia.
- **Permitir partidos exactamente en `tournament.endsAt`:** `endsAt` se trata como límite exclusivo de programación para conservar un intervalo temporal claro.
- **Imponer una duración fija al partido:** no permite determinar de forma fiable su finalización real.

### Consecuencias y próximos pasos

- Se incorporaron las reglas a `arquitectura.md`.
- Las columnas temporales usarán `timestamptz` en las migraciones.
- Los validadores deberán rechazar fechas inválidas, sin offset o fuera de los intervalos permitidos.
- Las funciones temporales recibirán `serverNow` como dependencia para probar exactamente los límites.
- La interfaz deberá indicar que las fechas se muestran en horario de Buenos Aires.
- Si en el futuro cada usuario elige su zona horaria, UTC seguirá siendo la representación persistida y solo cambiará la presentación.

## 2026-06-27 — Empates y orden del ranking

### Tarea

Definir el criterio de desempate del ranking.

### Contexto

El alcance funcional define únicamente puntos por pronóstico y puntaje acumulado por torneo. No establece ventajas adicionales para resultados exactos, cantidad de aciertos ni rapidez al pronosticar. Era necesario decidir cómo mostrar usuarios con el mismo puntaje y garantizar que la consulta siempre produzca un orden estable.

### Decisiones

- El puntaje total será el único criterio competitivo del MVP.
- Los participantes con igual puntaje compartirán la misma posición.
- Se utilizará el ranking de competición estándar: `12, 9, 9, 6` corresponde a posiciones `1, 2, 2, 4`.
- La posición se calculará con una operación equivalente a `RANK() OVER (ORDER BY points DESC)`.
- Dentro de un empate, la presentación se ordenará por nombre visible de forma ascendente e insensible a mayúsculas y minúsculas.
- Si también coincide el nombre, se usará `userId` ascendente para garantizar una salida determinista.
- El nombre y el identificador solo ordenan visualmente; no rompen el empate ni alteran la posición.
- Solo aparecerán quienes participen en el torneo mediante al menos un pronóstico guardado, incluidos aquellos con cero puntos.

### Alternativas descartadas

- **Desempatar por resultados exactos:** agregaría una regla competitiva que el alcance funcional no define y exigiría calcular o almacenar otra métrica.
- **Desempatar por cantidad total de aciertos:** presenta el mismo problema y puede beneficiar a quienes pronosticaron más partidos.
- **Desempatar por fecha del primer pronóstico:** la rapidez no forma parte de las reglas del juego.
- **Usar el nombre como desempate real:** una propiedad de presentación no debe determinar quién ocupa una posición deportiva superior.
- **Asignar posiciones consecutivas con `ROW_NUMBER()`:** mostraría posiciones distintas para puntajes iguales.
- **Usar ranking denso (`1, 2, 2, 3`):** se eligió la convención de competición estándar, más habitual en tablas de posiciones.

### Consecuencias y próximos pasos

- Se documentó el criterio en `arquitectura.md` y en el flujo de consulta del ranking.
- No es necesario agregar columnas de estadísticas a `tournament_scores` para resolver empates.
- La futura consulta del ranking deberá calcular la posición antes de aplicar los criterios visuales secundarios.
- Las pruebas deberán cubrir empates, nombres iguales, diferencias de mayúsculas y participantes con cero puntos.
- Incorporar un desempate competitivo en el futuro requerirá modificar primero el alcance funcional.

## 2026-06-27 — Administración del catálogo de equipos

### Tarea

Definir el mecanismo administrativo para crear y mantener equipos.

### Contexto

El dominio incluía la entidad Equipo y cada partido requiere local y visitante, pero el alcance no explicaba cómo se originaban esos registros. Sin un mecanismo explícito, la implementación podía terminar usando texto libre en cada partido, datos semilla inmutables o creación automática, con riesgo de duplicados y comportamientos diferentes.

### Decisiones

- Existirá un catálogo global de equipos reutilizable por todos los torneos.
- Solo un usuario `ADMIN` podrá crear, editar o eliminar equipos.
- Los usuarios autenticados podrán consultar el catálogo cuando corresponda.
- Un partido deberá seleccionar dos equipos existentes; no se crearán equipos implícitamente desde su formulario.
- La participación de un equipo en un torneo se derivará de sus partidos y no tendrá una tabla intermedia.
- Cada equipo tendrá `id`, `name`, `abbreviation`, `createdAt` y `updatedAt`.
- `name` será obligatorio y único después de remover espacios exteriores y comparar sin distinguir mayúsculas y minúsculas.
- `abbreviation` será obligatoria, alfanumérica, tendrá entre 2 y 5 caracteres, se normalizará a mayúsculas y será única.
- Un equipo podrá editarse únicamente si no participa en ningún partido que ya haya comenzado.
- Un equipo podrá eliminarse únicamente si no está referenciado por ningún partido, incluso si todos esos partidos son futuros.
- La carga de escudos queda fuera del MVP, de acuerdo con la decisión de no utilizar Supabase Storage en esta versión.

### Integridad histórica

La edición se bloquea cuando existe un partido iniciado porque cambiar el nombre o la abreviatura modificaría retroactivamente cómo se muestran encuentros históricos. La eliminación aplica una regla aún más estricta: cualquier referencia desde `matches` la impide mediante las claves foráneas, evitando eliminaciones en cascada accidentales.

### Alternativas descartadas

- **Equipos escritos como texto dentro de cada partido:** duplica datos y permite variantes ortográficas del mismo equipo.
- **Un catálogo separado por torneo:** repite equipos y dificulta reutilizarlos en distintas competencias.
- **Crear equipos automáticamente desde el formulario de partido:** hace difícil detectar errores y duplicados antes de guardar.
- **Mantener equipos solo mediante datos semilla o SQL manual:** vuelve una operación habitual dependiente de acceso técnico a la base.
- **Permitir eliminar equipos usados en partidos futuros mediante cascada:** podría borrar partidos y pronósticos indirectamente.
- **Permitir editar equipos usados en encuentros históricos:** altera la representación de información ya disputada sin auditoría.

### Consecuencias y próximos pasos

- Se agregó Gestión de equipos al alcance funcional del administrador.
- Se documentaron las operaciones, validaciones y relaciones en `arquitectura.md`.
- La futura base de datos necesitará restricciones únicas normalizadas e integridad referencial con eliminación restringida.
- La Server Action de edición deberá comprobar referencias a partidos con `startsAt <= serverNow`.
- La interfaz administrativa tendrá un listado y formularios separados del alta de partidos.
- Si se necesitan fusiones, cambios históricos de nombre o escudos, deberán diseñarse como funcionalidades posteriores.

## 2026-06-27 — Eliminación directa, sorteo y penales

### Motivo del cambio

Durante la definición inicial se evaluó soportar grupos o fases dependientes de resultados. Se confirmó que no era necesario construir un motor genérico de competiciones. El requisito real se redujo a torneos de eliminación directa con 4, 8, 16 o 32 equipos, todos ellos tamaños potencia de dos.

Esta decisión amplía el alcance original, que trataba los partidos como registros creados manualmente, pero se toma antes de diseñar la base de datos y por lo tanto evita una migración posterior costosa.

### Formato del torneo

- `teamCount` solo podrá ser `4`, `8`, `16` o `32`.
- Todos los encuentros serán de eliminación directa y a un solo partido.
- No habrá fase de grupos, equipos libres, ida y vuelta ni partido por el tercer puesto.
- El torneo tendrá exactamente `teamCount - 1` partidos.
- Las fases posibles serán `ROUND_OF_32`, `ROUND_OF_16`, `QUARTER_FINAL`, `SEMI_FINAL` y `FINAL`, incluyendo únicamente las necesarias para el tamaño elegido.
- La capacidad podrá modificarse antes del sorteo solo cuando todavía no existan equipos inscriptos.

### Inscripciones

- Se agregará `tournament_teams` para separar el catálogo global de la inscripción concreta en un torneo.
- Un equipo no podrá inscribirse dos veces en el mismo torneo.
- Las inscripciones podrán agregarse o retirarse antes del sorteo.
- El sorteo requerirá exactamente la cantidad configurada de equipos.
- Después del sorteo, capacidad e inscripciones quedarán bloqueadas.
- Un equipo global inscripto en cualquier torneo no podrá eliminarse del catálogo.

### Sorteo inicial

- Los cruces iniciales no serán elegidos por el administrador.
- Una Server Action autorizada coordinará un único sorteo ejecutado íntegramente en el servidor.
- `generate_bracket` asignará una clave aleatoria mediante `pg_catalog.gen_random_uuid()` a cada inscripción y ordenará por ella para obtener la permutación dentro de PostgreSQL.
- La operación bloqueará el torneo y volverá a validar capacidad, inscripciones y ausencia de una llave para evitar dos sorteos concurrentes.
- La permutación resultante se persistirá como `drawPosition` única dentro del torneo.
- Equipos en posiciones consecutivas formarán los cruces de la primera fase.
- No se guardará una semilla ni se permitirá volver a sortear. El orden persistido será la fuente de verdad auditable.
- Si el torneo fue configurado incorrectamente, podrá eliminarse completo antes de empezar y antes de recibir pronósticos; no habrá una operación de “deshacer sorteo”.

### Fases, partidos y avance

- Se agregará una entidad `stages` generada por el sistema.
- Cada partido pertenecerá a una fase y tendrá una posición única dentro de ella.
- Los partidos de la primera fase recibirán equipos concretos del sorteo.
- Los partidos posteriores almacenarán referencias a sus dos partidos de origen y comenzarán con participantes nulos.
- Al publicar un resultado, el ganador se copiará al lado correspondiente del partido siguiente.
- El ganador de la final será el campeón; no se agregará inicialmente una columna redundante de campeón al torneo, porque puede consultarse desde el resultado final.
- Los partidos se generarán sin horario. El administrador podrá programarlos y reprogramarlos antes de su inicio, pero no crear, eliminar ni sustituir participantes manualmente.
- Se incorpora el estado lógico `UNSCHEDULED` para partidos con `startsAt` nulo.
- Un partido solo podrá recibir pronósticos cuando tenga ambos equipos resueltos y una fecha asignada.

### Resultados empatados y penales

- `homeScore` y `awayScore` representarán el marcador final previo a la tanda de penales. El MVP no distinguirá tiempo reglamentario de alargue.
- Si ambos marcadores son iguales, `penaltyWinnerTeamId` será obligatorio y deberá referenciar a uno de los dos participantes.
- Si los marcadores son diferentes, `penaltyWinnerTeamId` deberá ser nulo y el ganador se derivará del marcador.
- Los goles individuales de la tanda no se almacenarán porque no influyen en la puntuación del Prode ni en el equipo que avanza.
- La misma validación condicional se aplicará a los pronósticos: al predecir empate será obligatorio elegir el ganador por penales.

### Puntuación actualizada

- 0 puntos si no se acierta el equipo que avanza.
- 3 puntos si se acierta el equipo que avanza, pero no el marcador exacto previo a penales.
- 6 puntos si se acierta el marcador exacto y, cuando hay empate, también el ganador por penales.

Ejemplo: pronosticar `1-1` y que avance el equipo local otorga 3 puntos si el resultado es `2-2` y avanza el local, y 6 puntos si el resultado es `1-1` y avanza el local.

### Atomicidad requerida

La publicación de un resultado deberá tratar como una única unidad:

1. validar y persistir el resultado inmutable;
2. determinar al ganador;
3. puntuar todos los pronósticos;
4. actualizar los puntajes por torneo;
5. propagar al ganador o resolver al campeón.

La estrategia técnica concreta se define en la entrada siguiente sobre fronteras transaccionales. Ningún paso podrá quedar aplicado aisladamente.

### Alternativas descartadas

- **Fase de grupos configurable:** agrega tablas deportivas, criterios de clasificación y muchas variantes que no son requisito real.
- **Administrador elige los cruces iniciales:** permite sesgo y hace que el resultado dependa de una decisión manual evitable.
- **`Math.random`:** obligaría a generar el orden fuera de la transacción PostgreSQL y usa una fuente más débil que la disponible en la base de datos.
- **Permitir regenerar la llave:** facilita repetir sorteos hasta obtener cruces convenientes.
- **Guardar una semilla reproducible:** no es necesaria para operar el torneo; la permutación persistida ya registra el resultado efectivo.
- **Guardar los goles de la tanda:** añade datos que no cambian avance ni puntuación.
- **Crear partidos posteriores recién al conocer ganadores:** dificulta visualizar la llave completa y programar fechas futuras.
- **Permitir tamaños arbitrarios:** obligaría a definir equipos libres y distribución desigual de rondas.

### Documentos y backlog afectados

- Se amplió `alcance-funcional.md` con inscripciones, sorteo, fases, avance y penales.
- Se amplió `arquitectura.md` con el nuevo modelo, invariantes, flujos y ADR-006.
- Se reestructuró `lista-de-tareas.md` para implementar la llave antes de partidos, pronósticos y resultados.
- Las decisiones anteriores sobre equipos, estados, fechas e inmutabilidad siguen vigentes con las aclaraciones documentadas en esta entrada.

## 2026-06-29 — Fronteras transaccionales en PostgreSQL

### Tarea

Definir la estrategia transaccional para publicar resultados, actualizar puntajes y avanzar ganadores atómicamente.

### Contexto

Una Server Action que ejecutara escrituras independientes mediante Supabase podría guardar el resultado y fallar antes de actualizar puntajes o la llave. El nuevo formato eliminatorio amplía la unidad de consistencia: publicar un resultado afecta `matches`, `tournament_scores` y posiblemente el partido siguiente.

Supabase expone funciones PostgreSQL mediante RPC. Una invocación puede ejecutar toda la operación dentro de la transacción de PostgreSQL, conservando el cliente oficial y evitando incorporar una conexión directa o un backend adicional.

### Decisión principal

- Se creará `public.publish_match_result(...)` en PL/pgSQL.
- Una Server Action autenticada validará la forma básica del input e invocará la función mediante `supabase.rpc()`.
- La función será la frontera transaccional y la fuente de verdad de las validaciones críticas.
- Cualquier excepción abortará la llamada y revertirá resultado, puntos y avance.
- `generate_bracket` utilizará el mismo patrón para crear posiciones, fases, partidos y dependencias atómicamente.

### Seguridad

- Las funciones se definirán como `SECURITY INVOKER`, opción recomendada por defecto por Supabase.
- Usarán `SET search_path = ''` y nombres de esquema explícitos para todas las relaciones y funciones.
- Se revocará `EXECUTE` a `PUBLIC` y `anon`; se concederá únicamente a `authenticated`.
- `publish_match_result` y `generate_bracket` comprobarán dentro de PostgreSQL que `auth.uid()` pertenezca a un perfil `ADMIN`.
- Las políticas RLS seguirán activas y contemplarán las escrituras administrativas necesarias.
- No se utilizará `service_role`, porque el JWT del administrador y RLS son suficientes y ofrecen menor privilegio.
- Las validaciones de la Server Action mejoran la respuesta al usuario, pero no reemplazan las comprobaciones de la función.

### Concurrencia y orden de bloqueos

`publish_match_result` seguirá siempre este orden:

1. bloquear el torneo con `SELECT ... FOR UPDATE`;
2. bloquear el partido actual;
3. validar que posea equipos, haya comenzado y no tenga un resultado diferente;
4. validar goles y penales;
5. persistir el resultado;
6. calcular y sumar puntos mediante una actualización basada en conjuntos;
7. bloquear el partido siguiente, cuando exista, y completar su slot;
8. devolver un resumen de la operación.

Bloquear el torneo serializa las publicaciones pertenecientes a una misma llave, una limitación aceptable para el volumen del MVP. Torneos diferentes podrán actualizarse en paralelo. El orden fijo torneo → partido actual → partido siguiente reduce la posibilidad de deadlocks.

Las actualizaciones de puntaje no iterarán realizando una llamada por usuario desde Next.js. PostgreSQL calculará todos los puntos en una sola operación basada en conjuntos.

### Idempotencia e inmutabilidad

- Si un resultado ya existe y el nuevo payload es idéntico, la función devolverá el resultado aplicado sin volver a sumar puntos ni avanzar al ganador.
- Si existe y el payload difiere, la función rechazará la operación.
- Esta regla permite reintentar después de dobles clics, timeouts o respuestas de red ambiguas sin debilitar la inmutabilidad.
- `generate_bracket` nunca volverá a sortear. Una repetición devolverá el estado ya generado o un error estable, pero conservará la misma llave.

### Cálculo de puntos

- Se creará `calculate_prediction_points` como función SQL `IMMUTABLE` sin efectos secundarios.
- Recibirá los marcadores y ganadores por penales pronosticados y oficiales.
- Devolverá exclusivamente 0, 3 o 6 según las reglas aprobadas.
- Será la fuente de verdad de la puntuación persistida.
- Si se crea una versión TypeScript para previsualización, no realizará escrituras y deberá ejecutar los mismos casos de prueba que la función SQL.

### Manejo de errores

- La función devolverá un resultado tipado para operaciones exitosas.
- Las violaciones de negocio producirán errores identificables y seguros, sin incluir SQL interno ni datos sensibles.
- La Server Action traducirá esos errores a mensajes de dominio para la interfaz.
- No se reintentará automáticamente una operación con payload diferente.

### Alternativas descartadas

- **Varias escrituras secuenciales con `supabase-js`:** no forman una transacción única y permiten estados parciales.
- **Compensar manualmente los pasos aplicados:** es más frágil que un rollback real y falla ante interrupciones.
- **Conexión directa con un cliente PostgreSQL desde Next.js:** agrega credenciales, pooling y otra vía de acceso innecesaria para el MVP.
- **`SECURITY DEFINER`:** podría omitir RLS; `SECURITY INVOKER` satisface el caso con menor privilegio.
- **Clave `service_role` en la Server Action:** evita RLS y amplía el impacto de una filtración o error.
- **Bloquear solamente el partido:** no serializa actualizaciones concurrentes de puntajes y slots dentro del mismo torneo.
- **Calcular puntos en TypeScript y enviar los valores a PostgreSQL:** permitiría que la frontera transaccional reciba datos derivados manipulables y dividiría la fuente de verdad.

### Consecuencias y próximos pasos

- Se agregó la estrategia transaccional a `arquitectura.md` y el ADR-007.
- Las migraciones deberán crear funciones, permisos y políticas RLS en el orden correcto.
- Se necesitarán pruebas SQL de rollback, idempotencia, autorización y concurrencia.
- Las pruebas de puntuación deberán cubrir victorias, empates con penales, marcadores exactos y ganadores incorrectos.
- Las Server Actions de resultado y sorteo quedarán reducidas a autenticación, validación de entrada, invocación RPC, traducción de errores y revalidación de caché.

### Fuentes consultadas

- [Funciones de base de datos en Supabase](https://supabase.com/docs/guides/database/functions)
- [Invocación RPC con el cliente JavaScript](https://supabase.com/docs/reference/javascript/rpc)
- [Seguridad y Row Level Security en Supabase](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [Bloqueos explícitos en PostgreSQL](https://www.postgresql.org/docs/current/explicit-locking.html)

### Rectificación sobre la ubicación del sorteo

Después de definir `generate_bracket` como frontera transaccional se detectó una incompatibilidad en la documentación: el sorteo todavía estaba descrito con Fisher–Yates y `crypto.getRandomValues` del runtime de Next.js. Una función PostgreSQL no puede ejecutar esa API de JavaScript y trasladar una permutación calculada afuera dividiría innecesariamente la operación.

Se decidió que el sorteo también ocurra dentro de `generate_bracket`:

- cada inscripción recibirá una clave temporal producida por `pg_catalog.gen_random_uuid()`;
- las inscripciones se ordenarán por esa clave y, solo ante una colisión extremadamente improbable, por `team_id`;
- `row_number()` sobre ese orden producirá `draw_position`;
- la función persistirá las posiciones y creará la llave sin abandonar la transacción ni aceptar un orden enviado por el cliente.

Ordenar elementos por claves aleatorias independientes produce una permutación aleatoria y evita duplicar el algoritmo entre TypeScript y SQL. La Server Action y `tournamentService` seguirán formando la fachada de dominio: validarán el request, llamarán a `generate_bracket`, traducirán errores y revalidarán la interfaz, pero no generarán ni enviarán los cruces.

También se aclaró que un servicio de dominio describe una responsabilidad del negocio y no exige que toda su implementación resida en TypeScript. En este caso, la fachada vive en TypeScript y la parte que necesita atomicidad, bloqueos y escritura multi-tabla vive deliberadamente en PostgreSQL.

Fuentes adicionales:

- [Funciones UUID nativas de PostgreSQL](https://www.postgresql.org/docs/current/functions-uuid.html)
- [UUID y `gen_random_uuid()` en Supabase](https://supabase.com/docs/guides/database/extensions/uuid-ossp)

## 2026-06-29 — Auditoría de consistencia previa a la implementación

### Objetivo

Revisar de forma cruzada `alcance-funcional.md`, `arquitectura.md`, `lista-de-tareas.md` y este registro antes de inicializar la aplicación.

### Inconsistencias encontradas y correcciones

#### Finalización del torneo

El estado `FINISHED` estaba derivado de `endsAt`. Eso podía marcar un torneo como terminado aunque la final aún no tuviera resultado, o mantenerlo en progreso después de haber definido un campeón.

Se corrigió la regla:

- `UPCOMING` depende de que todavía no se haya alcanzado `startsAt`.
- `IN_PROGRESS` comienza en `startsAt` y continúa mientras la final no tenga resultado.
- `FINISHED` se deriva exclusivamente del resultado oficial de la final.
- `endsAt` queda como límite exclusivo para programar el inicio de partidos.
- Si pasa `endsAt` sin campeón, el torneo sigue `IN_PROGRESS` y se muestra como atrasado en administración.

#### Transición de partidos

La arquitectura permitía devolver un partido `SCHEDULED` a `UNSCHEDULED`, pero el alcance solo definía programación y reprogramación. Se eliminó esa transición inversa: reprogramar cambia `startsAt` sin abandonar `SCHEDULED`.

#### Eliminación de torneos con actividad de usuarios

Eliminar un torneo antes del inicio podía borrar pronósticos ya guardados. Se agregó una protección: un torneo solo puede eliminarse antes de `startsAt` y mientras no exista ningún pronóstico asociado. Esta regla también limita el mecanismo de recuperación ante un sorteo mal configurado.

#### Restricciones del modelo de partidos

Se hicieron explícitas estas invariantes:

- los marcadores oficiales son ambos nulos o ambos no nulos;
- `resultPublishedAt` existe si y solo si existe un resultado completo;
- los partidos iniciales se generan con equipos y sin fuentes;
- los partidos posteriores se generan con dos fuentes y equipos nulos hasta que avancen los ganadores;
- las fuentes son distintas, pertenecen al mismo torneo y a la fase anterior;
- cada partido de origen alimenta un único slot de la fase siguiente.

#### Orden aleatorio

Se agregó `teamId` únicamente como orden secundario ante una colisión extremadamente improbable entre claves de `gen_random_uuid()`. No actúa como criterio normal del sorteo.

### Resultado

Después de estas correcciones no se detectaron contradicciones pendientes entre alcance, arquitectura y backlog. Las decisiones iniciales están suficientemente definidas para comenzar la inicialización del proyecto. Las reglas que aún deben implementarse permanecen como tareas abiertas y no como decisiones sin resolver.

## 2026-06-29 — División de la documentación arquitectónica

### Contexto

`arquitectura.md` había superado una extensión práctica para consulta cotidiana porque reunía visión general, reglas del dominio, modelo de datos, seguridad, buenas prácticas y ADR. Mantener todo en un único archivo dificultaba encontrar información y aumentaba el riesgo de editar una sección equivocada.

### Decisión

La documentación se separó por responsabilidad, conservando `arquitectura.md` como punto de entrada:

- `arquitectura.md`: objetivos, tecnologías, visión general, frontend y alcance técnico.
- `dominio-y-flujos.md`: llave, estados, fechas, puntuación, ranking y flujos de aplicación.
- `datos-y-seguridad.md`: backend, servicios, transacciones, entidades, relaciones, autenticación y RLS.
- `decisiones-arquitectonicas.md`: escalabilidad, buenas prácticas y ADR-001 a ADR-007.
- `registro-de-decisiones.md`: historial cronológico; no sustituye los ADR ni la especificación vigente.

El archivo principal contiene enlaces relativos a todos los documentos. Los archivos extraídos enlazan de regreso a `arquitectura.md`.

### Criterios aplicados

- Cada tema tiene una sola ubicación vigente; no se duplicaron secciones para evitar divergencias.
- Se conservó el contenido técnico existente y solo se añadieron encabezados, enlaces e introducciones necesarios para la navegación.
- Se retiró la numeración global de secciones porque dejaba de ser significativa al repartirlas entre varios archivos.
- Los nombres de archivo usan `kebab-case`, de acuerdo con las convenciones aprobadas.
- Los enlaces son relativos para funcionar en GitHub, VS Code y otros visores Markdown.

### Alternativas descartadas

- **Mantener un único archivo:** conserva una navegación lineal, pero ya resultaba demasiado extenso.
- **Crear un archivo por cada sección:** fragmentaría en exceso la documentación y dificultaría recorrerla.
- **Duplicar resúmenes técnicos en varios archivos:** facilitaría lecturas aisladas, pero crearía múltiples fuentes de verdad.
- **Mover los ADR al registro cronológico:** mezclaría decisiones arquitectónicas estables con el diario de trabajo.

### Consecuencias

- Las futuras modificaciones deben realizarse en el documento propietario del tema y no repetirse en `arquitectura.md`.
- Los cambios de dominio se registrarán en `dominio-y-flujos.md`; los de persistencia o seguridad, en `datos-y-seguridad.md`; y los ADR, en `decisiones-arquitectonicas.md`.
- `arquitectura.md` seguirá siendo el documento recomendado para comenzar a leer el proyecto.

## 2026-06-29 — Organización del registro por fases

### Decisión

El registro cronológico único se dividió según las 19 secciones generales del backlog. Todo el historial existente corresponde a Definiciones iniciales y se trasladó a este archivo.

`registro-de-decisiones.md` pasó a ser un índice de fases. Los registros siguientes se crearán cuando comience su sección, evitando documentos vacíos y manteniendo alineados backlog e historial.

### Motivos

- Un registro por fase mantiene juntas decisiones relacionadas.
- Evita un archivo único que crezca durante todo el proyecto.
- Es menos fragmentado que crear un documento por checkbox.
- Permite identificar rápidamente qué fases están completas, activas o pendientes.
- Conserva separados los ADR arquitectónicos, que permanecen en `decisiones-arquitectonicas.md`.

### Consecuencias

- Al comenzar una fase se creará su archivo y se actualizará el índice.
- Las decisiones se registrarán en el archivo de la fase donde se toman, aunque afecten tareas posteriores.
- Si una decisión modifica un ADR, también se actualizará `decisiones-arquitectonicas.md`.
