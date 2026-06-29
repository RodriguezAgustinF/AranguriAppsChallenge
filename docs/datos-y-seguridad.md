# Datos y seguridad

Arquitectura backend, modelo relacional, seguridad y fronteras transaccionales.

[Volver a Arquitectura](./arquitectura.md)

---

## Arquitectura backend

### Enfoque General

La aplicación no contará con un backend independiente. En su lugar, la lógica del servidor se implementará utilizando las capacidades Full Stack de Next.js, principalmente mediante **Server Actions**, complementadas por **Route Handlers** cuando sea necesario exponer endpoints HTTP.

Este enfoque permite reducir la complejidad del proyecto al eliminar la necesidad de mantener una API REST separada, disminuyendo el esfuerzo de desarrollo y operación sin sacrificar mantenibilidad.

La arquitectura backend se organiza en tres capas principales:

```text
Cliente
        │
        ▼
Server Actions / Route Handlers
        │
        ▼
Servicios del dominio
        │
        ▼
Supabase (PostgreSQL)
```

Cada capa posee responsabilidades bien definidas para mantener una adecuada separación de responsabilidades.

---

### Responsabilidades del Cliente

El cliente únicamente será responsable de:

* capturar la interacción del usuario;
* mostrar información;
* realizar validaciones básicas de formularios;
* invocar Server Actions.

No contendrá reglas de negocio críticas, ya que cualquier validación realizada en el navegador puede ser modificada o eludida por un usuario malintencionado.

---

### Responsabilidades de las Server Actions

Las Server Actions constituyen la principal capa de negocio de la aplicación.

Entre sus responsabilidades se encuentran:

* validar autenticación;
* validar autorización;
* verificar reglas del negocio;
* consultar datos;
* modificar datos;
* ejecutar cálculos;
* devolver resultados al cliente.

Cada operación importante del sistema se implementará mediante una Server Action específica.

#### Autenticación

Responsabilidades:

* registro de usuarios;
* inicio de sesión;
* cierre de sesión.

El registro público creará exclusivamente usuarios con rol `USER`. Las cuentas con rol `ADMIN` serán aprovisionadas manualmente en Supabase Authentication y en la tabla de usuarios.

#### Torneos

Responsabilidades:

* crear torneo;
* actualizar torneo;
* eliminar torneo;
* obtener información del torneo;
* inscribir y retirar equipos antes del sorteo;
* generar una única vez la llave completa.

Antes de modificar un torneo deberán verificarse reglas como:

* que el usuario sea administrador;
* que el torneo aún no haya comenzado;
* para eliminarlo, que todavía no existan pronósticos asociados.

La llave se generará dentro de PostgreSQL cuando exista exactamente la cantidad configurada de equipos. `generate_bracket` asignará a cada inscripción una clave aleatoria con `pg_catalog.gen_random_uuid()` y ordenará por ella para obtener una permutación; `team_id` se usará solo como criterio secundario ante una colisión extremadamente improbable. Se persistirá la posición resultante de cada equipo y no existirá una acción para repetir el sorteo.

---

#### Partidos

Responsabilidades:

* programar partido;
* reprogramar partido antes de su inicio;
* obtener partidos de un torneo.

Antes de modificar un partido se validará:

* rol del usuario;
* fecha de inicio del partido;
* pertenencia a la llave generada.

Los partidos, sus fases, posiciones y dependencias serán creados por el generador de la llave. El administrador no podrá crear, eliminar ni reemplazar manualmente sus participantes.

---

#### Equipos

Los equipos formarán un catálogo global compartido por todos los torneos.

Responsabilidades:

* listar equipos;
* crear equipos;
* editar equipos que no hayan sido utilizados en partidos iniciados;
* eliminar equipos que no estén asociados a ningún partido ni inscriptos en un torneo.

La creación y selección serán operaciones separadas: los equipos existentes se inscribirán en un torneo antes del sorteo. Esto evita duplicados accidentales.

El nombre será obligatorio y único sin distinguir mayúsculas, minúsculas ni espacios exteriores. La abreviatura será obligatoria, tendrá entre 2 y 5 caracteres alfanuméricos, se normalizará a mayúsculas y también será única. El MVP no almacenará escudos ni otros archivos.

---

#### Pronósticos

Responsabilidades:

* registrar pronóstico;
* modificar pronóstico;
* consultar pronósticos del usuario.

La Server Action verificará siempre que el partido posea ambos equipos, tenga fecha asignada y no haya comenzado. Si el marcador pronosticado está empatado exigirá seleccionar uno de esos equipos como ganador por penales; si no está empatado rechazará esa selección.

La decisión nunca dependerá del reloj del navegador.

La comparación se realizará utilizando la fecha almacenada en la base de datos y el horario del servidor.

---

#### Resultados Oficiales

Cuando un administrador publique un resultado oficial se ejecutará una Server Action encargada de:

1. validar permisos;
2. validar el marcador y el ganador por penales cuando corresponda;
3. actualizar los goles del partido y marcarlo como finalizado;
4. recuperar todos los pronósticos correspondientes al partido;
5. calcular el puntaje obtenido por cada participante;
6. actualizar la tabla de posiciones del torneo;
7. ubicar al ganador en el slot correspondiente del partido siguiente o marcarlo como campeón si se trata de la final.

De esta manera se garantiza que el ranking siempre refleje los resultados oficiales.

Antes de registrar el resultado, la Server Action verificará que el partido no posea ya un resultado oficial. Una vez publicado, el resultado será inmutable y no existirá una operación para editarlo o eliminarlo.

El cálculo aplicará las siguientes reglas:

* 0 puntos si no se acierta el equipo que avanza;
* 3 puntos si se acierta el equipo que avanza, pero no el marcador exacto previo a penales;
* 6 puntos si se acierta el marcador exacto previo a penales y, cuando hay empate, también el ganador por penales.

Si los goles oficiales están empatados, `penalty_winner_team_id` será obligatorio y deberá identificar a uno de los dos participantes. Si no están empatados, deberá ser nulo. Los goles de la tanda no se incorporarán a `home_score` ni `away_score`.

---

### Servicios del Dominio

Aunque el proyecto no contará con una arquitectura en capas tradicional, resulta conveniente encapsular determinadas operaciones reutilizables dentro de servicios del dominio.

Ejemplos:

```text
services/

rankingService.ts
tournamentService.ts
predictionService.ts
matchResultService.ts
```

Estos servicios contienen lógica reutilizable, mientras que las Server Actions coordinan el flujo de ejecución. `matchResultService` y `tournamentService` actuarán como fachadas de dominio en TypeScript: expondrán operaciones con nombres del negocio, invocarán la RPC correspondiente y traducirán sus respuestas y errores. Las operaciones que requieren modificar varias tablas de forma atómica se implementarán dentro de PostgreSQL y no como varios writes independientes.

---

### Distribución de la Lógica de Negocio

| Regla                       | Ubicación            |
| --------------------------- | -------------------- |
| Crear torneo                | Server Action        |
| Editar torneo               | Server Action        |
| Eliminar torneo             | Server Action        |
| Crear equipo                | Server Action        |
| Editar equipo               | Server Action        |
| Eliminar equipo             | Server Action        |
| Inscribir equipo en torneo  | Server Action        |
| Generar llave               | Función PostgreSQL invocada por Server Action |
| Programar partido           | Server Action        |
| Reprogramar partido         | Server Action        |
| Registrar pronóstico        | Server Action        |
| Editar pronóstico            | Server Action        |
| Registrar resultado, puntuar y avanzar ganador | Función PostgreSQL invocada por Server Action |
| Calcular puntos oficiales   | Función PostgreSQL inmutable |
| Consultar ranking           | Servicio del dominio |
| Validar permisos            | Server Action        |
| Validar fechas              | Server Action        |

---

### Acceso a la Base de Datos

Toda interacción con PostgreSQL se realizará mediante el cliente oficial de Supabase.

Las consultas ordinarias se mantendrán simples y las reglas se coordinarán desde el servidor. Las operaciones multi-tabla que exigen atomicidad se implementarán como funciones PostgreSQL invocadas con `supabase.rpc()`.

Este enfoque mantiene la mayor parte de la aplicación legible en TypeScript sin sacrificar consistencia transaccional. La lógica SQL compleja quedará limitada a fronteras explícitas, versionada mediante migraciones y cubierta por pruebas de base de datos.

#### Estrategia Transaccional

La publicación de resultados utilizará una función PostgreSQL `publish_match_result` invocada exclusivamente desde una Server Action mediante RPC. Una llamada a la función constituirá una sola transacción: si cualquier validación o escritura falla, PostgreSQL revertirá todos los cambios.

La función se definirá como `SECURITY INVOKER`, con `search_path = ''` y referencias completamente calificadas. Se revocará su ejecución a `PUBLIC` y `anon`, concediéndola únicamente a `authenticated`. La función volverá a comprobar `auth.uid()` y el rol `ADMIN`; las políticas RLS permanecerán activas y deberán permitir las escrituras administrativas necesarias. No se utilizará la clave `service_role` para esta operación.

El orden de ejecución será:

1. bloquear la fila del torneo mediante `SELECT ... FOR UPDATE`, serializando publicaciones dentro del mismo torneo;
2. bloquear la fila del partido y comprobar permisos, horario, participantes e inmutabilidad;
3. validar marcador y ganador por penales;
4. determinar el equipo que avanza;
5. persistir el resultado oficial;
6. calcular los puntos con una función SQL `IMMUTABLE` y actualizar los puntajes mediante una operación basada en conjuntos;
7. bloquear y completar el slot del partido siguiente o resolver al campeón;
8. devolver un resumen del resultado, puntos actualizados y destino del ganador.

El bloqueo del torneo simplifica la concurrencia y evita que dos resultados del mismo cuadro actualicen simultáneamente puntajes o slots relacionados. Torneos diferentes podrán procesarse en paralelo. Todas las operaciones respetarán el orden de bloqueo torneo → partido actual → partido siguiente para reducir el riesgo de deadlocks.

`publish_match_result` será idempotente para reintentos con el mismo payload: si el resultado ya existe y coincide exactamente, devolverá el resultado previamente aplicado sin sumar puntos otra vez. Si el payload difiere, rechazará la operación por inmutabilidad.

La función `calculate_prediction_points` será la fuente de verdad de la puntuación oficial y aplicará exclusivamente las reglas 0/3/6. Cualquier cálculo TypeScript usado para previsualización no autorizará escrituras y deberá comprobarse contra pruebas compartidas con la función SQL.

La generación de la llave seguirá el mismo patrón con una función `generate_bracket`: bloqueará el torneo, validará que no exista un sorteo previo y creará posiciones, fases, partidos y dependencias en una sola transacción. A diferencia de la publicación idempotente, un segundo intento después de generar la llave devolverá el sorteo existente o un estado de “ya generado”, pero nunca realizará un nuevo sorteo.

---

## Modelo de datos

### Principios de Diseño

El modelo de datos sigue un enfoque relacional, aprovechando las capacidades de PostgreSQL para garantizar:

* integridad referencial;
* consistencia;
* normalización;
* facilidad de consulta.

Cada entidad representa un concepto propio del dominio del negocio.

---

### Usuario

#### Propósito

Representa a las personas que utilizan la aplicación.

Un usuario puede participar en múltiples torneos y realizar pronósticos sobre distintos partidos. La participación comienza al guardar su primer pronóstico para un partido del torneo y no requiere una entidad ni un proceso de inscripción independiente.

#### Campos principales

* id
* name
* email
* role
* createdAt

#### Relaciones

* Un usuario puede registrar muchos pronósticos.
* Un usuario posee un puntaje por cada torneo en el que participa.

---

### Torneo

#### Propósito

Agrupa una llave de eliminación directa y mantiene una clasificación independiente de usuarios del Prode.

Cada torneo constituye una competencia aislada.

#### Campos principales

* id
* name
* description
* teamCount
* startsAt
* endsAt
* bracketGeneratedAt (nullable)
* createdAt

#### Relaciones

* Un torneo contiene equipos inscriptos, fases y partidos.
* Un torneo posee muchos puntajes.
* Un torneo posee muchos participantes, derivados de los usuarios que registraron al menos un pronóstico para sus partidos.

`teamCount` solo admitirá `4`, `8`, `16` o `32`. Podrá cambiarse antes del sorteo únicamente si el torneo todavía no tiene equipos inscriptos. `bracketGeneratedAt` se establecerá al generar la llave y no podrá volver a modificarse.

---

### Equipo por Torneo

#### Propósito

Representa la inscripción de un equipo del catálogo global en un torneo.

#### Campos principales

* id
* tournamentId
* teamId
* drawPosition (nullable antes del sorteo)
* createdAt

La combinación `tournamentId`–`teamId` será única. Después del sorteo, `drawPosition` será obligatoria y única dentro del torneo. Las inscripciones no podrán agregarse, editarse ni eliminarse una vez generada la llave.

---

### Fase

#### Propósito

Representa una ronda de la llave de eliminación directa.

#### Campos principales

* id
* tournamentId
* type
* order
* createdAt

`type` admitirá `ROUND_OF_32`, `ROUND_OF_16`, `QUARTER_FINAL`, `SEMI_FINAL` o `FINAL`. La combinación torneo–orden y la combinación torneo–tipo serán únicas. Las fases serán generadas por el sistema y no se administrarán manualmente.

---

### Equipo

#### Propósito

Representa un equipo de fútbol participante.

La entidad forma parte de un catálogo global y evita duplicar información en múltiples partidos y torneos. Su inscripción se representa mediante Equipo por Torneo.

#### Campos principales

* id
* name
* abbreviation
* createdAt
* updatedAt

#### Relaciones

Un equipo puede inscribirse en muchos torneos y participar en muchos partidos como local o visitante.

El nombre y la abreviatura serán únicos según sus valores normalizados. Un equipo podrá editarse solo mientras no esté asociado a un partido iniciado y podrá eliminarse solo si no está asociado a ningún partido ni inscripto en un torneo. Estas restricciones preservan la integridad histórica y referencial.

---

### Partido

#### Propósito

Representa una posición concreta dentro de una fase de la llave. Sus participantes pueden estar pendientes de resolución hasta que finalicen los partidos anteriores.

#### Campos principales

* id
* tournamentId
* stageId
* bracketPosition
* homeTeamId (nullable)
* awayTeamId (nullable)
* homeSourceMatchId (nullable)
* awaySourceMatchId (nullable)
* startsAt (nullable)
* homeScore (nullable)
* awayScore (nullable)
* penaltyWinnerTeamId (nullable)
* resultPublishedAt (nullable)

#### Relaciones

* Pertenece a un torneo y una fase.
* Puede recibir sus equipos del sorteo inicial o de los ganadores de dos partidos anteriores.
* Posee múltiples pronósticos.

La combinación fase–posición será única. Los partidos de la primera fase tendrán equipos concretos y no tendrán partidos de origen. Los partidos posteriores tendrán dos partidos de origen y recibirán sus equipos al publicarse esos resultados. Un equipo no podrá ocupar ambos lados.

Los dos marcadores oficiales serán ambos nulos o ambos no nulos. `resultPublishedAt` será nulo mientras no exista resultado y obligatorio cuando ambos marcadores estén definidos. Las fuentes deberán ser partidos distintos, pertenecer al mismo torneo y a la fase inmediatamente anterior; cada partido de origen alimentará un único slot de la fase siguiente.

---

### Pronóstico

#### Propósito

Almacena la predicción realizada por un usuario para un partido determinado.

#### Campos principales

* id
* userId
* matchId
* homeScore
* awayScore
* penaltyWinnerTeamId (nullable)
* createdAt

#### Relaciones

* Pertenece a un usuario.
* Pertenece a un partido.

Debe existir un único pronóstico por usuario y partido.

Cuando `homeScore == awayScore`, `penaltyWinnerTeamId` será obligatorio y deberá ser uno de los dos equipos del partido. Cuando los goles sean diferentes, deberá ser nulo.


---

### Puntaje por Torneo

#### Propósito

Almacena la cantidad de puntos acumulados por un usuario dentro de un torneo.

Esta entidad evita recalcular continuamente todos los pronósticos para generar la tabla de posiciones.

#### Campos principales

* id
* userId
* tournamentId
* points

#### Relaciones

* Pertenece a un usuario.
* Pertenece a un torneo.

La combinación usuario–torneo debe ser única.

El registro de Puntaje por Torneo se creará al guardar el primer pronóstico del usuario dentro del torneo, con un puntaje inicial de cero. De esta forma, el mismo registro representa su participación y permite incluirlo en la clasificación antes de que se publiquen resultados.

---

### Modelo Conceptual

```text
Usuario ──< Pronóstico >── Partido >── Fase >── Torneo
   │                           │                    │
   └──< PuntajeTorneo          ├── ganador ──> siguiente Partido
                               │                    │
Equipo ──< EquipoTorneo >──────┴────────────────────┘
```

---

## Seguridad

La seguridad constituye un aspecto central de la arquitectura y se implementa en múltiples niveles para proteger tanto la información como las reglas del negocio.

### Autenticación

La autenticación será gestionada mediante Supabase Authentication.

Las responsabilidades incluyen:

* registro de usuarios;
* inicio de sesión;
* cierre de sesión;
* administración de sesiones.

La recuperación de contraseña no forma parte del MVP. El registro público solo permitirá crear cuentas con rol `USER`; las cuentas administrativas se aprovisionarán manualmente tanto en Supabase Authentication como en la tabla de usuarios.

Las credenciales nunca serán almacenadas ni procesadas directamente por la aplicación.

---

### Autorización

La autorización determina qué acciones puede realizar cada usuario.

El sistema distingue dos roles:

* **ADMIN**
* **USER**

Las verificaciones de permisos se realizarán exclusivamente en el servidor.

Por ejemplo:

* solo un administrador puede crear torneos;
* solo un administrador puede registrar resultados oficiales;
* ningún usuario, incluido un administrador, puede modificar o eliminar un resultado oficial ya registrado;
* un usuario común solo puede modificar sus propios pronósticos.

La interfaz podrá ocultar opciones según el rol del usuario, pero esta medida tiene únicamente fines de experiencia de usuario y no reemplaza las validaciones del servidor.

---

### Row Level Security (RLS)

Se utilizará Row Level Security (RLS) de Supabase para reforzar el control de acceso a los datos.

Las políticas permitirán garantizar que cada usuario únicamente pueda acceder a la información que le corresponde.

Ejemplos:

* un usuario solo podrá consultar y modificar sus propios pronósticos;
* un usuario no podrá alterar el puntaje de otro participante;
* las operaciones administrativas estarán restringidas a usuarios con rol ADMIN.

El uso de RLS agrega una capa adicional de seguridad incluso si un cliente intenta acceder directamente a la base de datos mediante el SDK de Supabase.

---

### Validaciones del Lado del Servidor

Todas las reglas críticas del negocio serán verificadas mediante Server Actions antes de modificar la base de datos.

Entre ellas:

* verificar autenticación;
* verificar autorización;
* validar existencia de entidades;
* comprobar que un torneo no haya comenzado;
* comprobar que un partido no haya iniciado;
* impedir que usuarios no autorizados actualicen el resultado de un partido.
* evitar pronósticos duplicados para un mismo partido.
* impedir cambios de inscripciones o cruces después del sorteo;
* validar la coherencia del ganador por penales;
* impedir que el cliente decida qué equipo avanza en la llave.

Estas validaciones son obligatorias, independientemente de las comprobaciones realizadas en el cliente.

---

### Protección Contra Manipulación del Cliente

Ninguna decisión de negocio dependerá de información enviada por el navegador sin ser validada.

El servidor será responsable de:

* determinar el usuario autenticado;
* verificar el rol del usuario;
* comprobar las fechas de inicio de los partidos;
* calcular los puntajes;
* actualizar la clasificación.

Este enfoque evita que un usuario pueda modificar el comportamiento del sistema manipulando el código ejecutado en el navegador.

---

