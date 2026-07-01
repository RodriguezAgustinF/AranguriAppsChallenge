# Dominio y flujos

Reglas técnicas del dominio y recorridos principales de la aplicación.

[Volver a Arquitectura](./arquitectura.md)

---

## Reglas del dominio

### Generación y Resolución de la Llave

El torneo será siempre de eliminación directa, a un solo partido y sin encuentro por el tercer puesto. La capacidad admitida será `4`, `8`, `16` o `32`, por lo que nunca serán necesarios equipos libres.

Antes del sorteo, el administrador inscribirá equipos del catálogo hasta completar la capacidad. La operación `generateBracket` se ejecutará una sola vez en el servidor y realizará atómicamente los siguientes pasos:

1. bloquear el torneo y sus inscripciones para evitar cambios concurrentes;
2. verificar que el torneo no haya comenzado, que no posea una llave y que tenga exactamente `team_count` equipos únicos;
3. asignar una clave `gen_random_uuid()` a cada inscripción y ordenar por esa clave para obtener una permutación aleatoria dentro de PostgreSQL;
4. persistir una `draw_position` única para cada inscripción;
5. crear las fases necesarias y los `team_count - 1` partidos de la llave;
6. asignar pares consecutivos del orden sorteado a la primera fase;
7. conectar cada partido posterior con sus dos partidos de origen;
8. establecer `bracket_generated_at`.

La permutación persistida será la fuente de verdad del sorteo. No se guardará una semilla ni se ofrecerá una regeneración: permitir múltiples sorteos facilitaría elegir un resultado conveniente. Si se detecta un error antes de comenzar y aún no existen pronósticos, deberá eliminarse el torneo y crearse otro.

Cuando se publique un resultado, la misma transacción que guarda el resultado y actualiza puntajes resolverá el ganador. Si no es la final, escribirá ese equipo en el lado correspondiente del siguiente partido. Si es la final, el ganador se considerará campeón del torneo. Ningún participante de la llave podrá ser reemplazado manualmente.

Las fases generadas serán:

| Equipos | Fases |
| ---: | --- |
| 4 | `SEMI_FINAL`, `FINAL` |
| 8 | `QUARTER_FINAL`, `SEMI_FINAL`, `FINAL` |
| 16 | `ROUND_OF_16`, `QUARTER_FINAL`, `SEMI_FINAL`, `FINAL` |
| 32 | `ROUND_OF_32`, `ROUND_OF_16`, `QUARTER_FINAL`, `SEMI_FINAL`, `FINAL` |

---

### Estados de Torneos y Partidos

Los estados se derivarán de fechas y datos persistidos en lugar de modificarse manualmente. Esto evita que un registro conserve un estado incompatible con la hora del servidor.

Un torneo podrá encontrarse en uno de estos estados lógicos:

* `UPCOMING`: la hora del servidor es anterior a `starts_at`.
* `IN_PROGRESS`: la hora del servidor es igual o posterior a `starts_at` y la final todavía no posee un resultado oficial.
* `FINISHED`: la final posee un resultado oficial y, por lo tanto, existe un campeón.

La transición será lineal: `UPCOMING` → `IN_PROGRESS` → `FINISHED`. No se estima una fecha de finalización: el torneo continúa `IN_PROGRESS` hasta que la final tenga un resultado oficial. Un torneo solo podrá editarse en `UPCOMING` y solo podrá eliminarse en ese estado si además no posee pronósticos.

Un partido podrá encontrarse en uno de estos estados lógicos:

* `UNSCHEDULED`: `starts_at` es nulo.
* `SCHEDULED`: la hora del servidor es anterior a `starts_at` y no existe resultado oficial.
* `STARTED`: la hora del servidor es igual o posterior a `starts_at` y todavía no existe resultado oficial.
* `FINISHED`: posee goles oficiales y `result_published_at`.

La transición será `UNSCHEDULED` → `SCHEDULED` → `STARTED` → `FINISHED`. Una reprogramación mantiene el estado `SCHEDULED`; el MVP no incluye una operación para retirar por completo la programación. El paso a `STARTED` será temporal y el paso a `FINISHED` ocurrirá al publicar el resultado oficial. `FINISHED` será terminal porque el resultado no podrá modificarse ni eliminarse.

Las operaciones usarán exclusivamente la hora del servidor. Los pronósticos y las modificaciones del partido se bloquearán al abandonar `SCHEDULED`. La aplicación impedirá publicar un resultado antes de `starts_at`; como el MVP no integra una fuente deportiva externa ni almacena una hora de finalización del partido, será responsabilidad del administrador confirmar que el encuentro haya terminado realmente.

No se incluirán estados `DRAFT`, `CANCELLED`, `POSTPONED` o `SUSPENDED` en el MVP. Incorporarlos requerirá definir nuevas reglas funcionales.

El resultado oficial no será una entidad independiente. Se representará dentro del partido mediante los goles oficiales, `penalty_winner_team_id` cuando corresponda y `result_published_at`; existe como concepto de dominio y como entrada de la operación de publicación.

---

### Fechas y Zona Horaria

Todos los instantes se almacenarán en PostgreSQL como `timestamptz` y se normalizarán a UTC. Las comparaciones de reglas de negocio utilizarán la hora de la base de datos o del servidor, nunca el reloj del navegador.

La zona horaria de presentación del MVP será `America/Argentina/Buenos_Aires`. Los formularios mostrarán las fechas en esa zona y deberán enviar al servidor un instante inequívoco con offset. La conversión a UTC ocurrirá antes de persistirlo. El uso de una zona IANA evita codificar manualmente un offset fijo.

Reglas para torneos:

* `starts_at` es obligatorio y debe representar un instante válido.
* Al crear un torneo, `starts_at` debe ser estrictamente posterior a la hora actual del servidor.
* Solo puede editarse o eliminarse mientras `server_now < starts_at`.
* Una edición de `starts_at` debe mantener todos los partidos existentes en el torneo.

Reglas para partidos:

* `starts_at` será nulo al generar la llave y, cuando se programe, deberá representar un instante válido.
* Cuando exista, debe cumplirse `tournament.starts_at <= match.starts_at`.
* Al programar o reprogramar un partido, su nuevo `starts_at` debe ser estrictamente posterior a la hora actual del servidor.
* Solo puede programarse o reprogramarse mientras todavía no haya comenzado; no puede eliminarse independientemente de la llave.
* Puede publicarse un resultado únicamente cuando `server_now >= match.starts_at` y aún no existe un resultado oficial.
* La finalización real del torneo se deriva exclusivamente de la publicación del resultado de la fase `FINAL`.

Reglas para pronósticos:

* Solo pueden crearse cuando ambos equipos estén resueltos y `starts_at` no sea nulo.
* Pueden crearse o modificarse únicamente mientras `server_now < match.starts_at`.
* Cuando `server_now == match.starts_at`, el pronóstico ya está bloqueado.

El cliente podrá anticipar estos bloqueos para mejorar la experiencia, pero el servidor repetirá siempre las validaciones inmediatamente antes de escribir. No se aplicará una tolerancia temporal ni se inferirá la finalización del partido mediante una duración fija.

---

### Rol de Usuario

El rol se modelará como un atributo de la entidad **Usuario**, utilizando un tipo enumerado (`ADMIN` o `USER`).

Dado que el sistema únicamente contempla dos perfiles de usuario y no se prevé la incorporación de nuevos roles en el MVP, modelarlo como una entidad independiente añadiría complejidad sin aportar beneficios significativos.

Esta decisión simplifica tanto el modelo de datos como la implementación de la autorización.

El formulario de registro público asignará siempre el rol `USER` y no aceptará el rol enviado por el cliente. Para crear un administrador será necesario aprovisionar manualmente su identidad en Supabase Authentication y su perfil con rol `ADMIN`; insertar únicamente el perfil no sería suficiente para que pueda autenticarse.

---

### Puntajes Materializados

Aunque el puntaje de un usuario podría calcularse recorriendo todos sus pronósticos, se opta por persistir el total en la entidad **Puntaje por Torneo**.

Esta decisión reduce el costo de las consultas del ranking y mejora el rendimiento, especialmente a medida que aumenta la cantidad de partidos y participantes.

La consistencia se garantiza actualizando estos registros inmediatamente después de registrar un resultado oficial.

---

### Orden y Empates del Ranking

El puntaje total será el único criterio competitivo del ranking durante el MVP. Dos o más participantes con la misma cantidad de puntos compartirán la misma posición; el sistema no utilizará cantidad de resultados exactos, momento de registro ni ningún otro desempate no definido en el alcance funcional.

Las posiciones seguirán el criterio de competición estándar. Por ejemplo, los puntajes `12, 9, 9, 6` producirán las posiciones `1, 2, 2, 4`.

Para obtener una salida determinista, la consulta ordenará por:

1. `points` descendente;
2. nombre visible del usuario ascendente, sin distinguir mayúsculas y minúsculas;
3. `user_id` ascendente como último criterio técnico estable.

Los criterios segundo y tercero solo determinan el orden visual entre participantes empatados y no modifican su posición. La posición se calculará con una función equivalente a `RANK() OVER (ORDER BY points DESC)`.

Participarán en el ranking únicamente los usuarios que hayan guardado al menos un pronóstico para el torneo. Su registro de puntaje podrá mostrar cero puntos hasta que obtengan puntos.


## Flujos de la aplicación

### Flujo General

El siguiente diagrama representa el recorrido típico de un usuario dentro de la aplicación.

```text
Registro
    │
    ▼
Inicio de sesión
    │
    ▼
Visualizar torneos
    │
    ▼
Seleccionar torneo
    │
    ▼
Consultar partidos
    │
    ▼
Registrar pronósticos
    │
    ▼
Esperar resultados oficiales
    │
    ▼
Administrador publica resultado
    │
    ▼
Servidor calcula puntajes
    │
    ▼
Actualizar tabla de posiciones
```

Este flujo resume la interacción principal entre usuarios, administradores y el sistema.

---

### Flujo de Registro

1. El usuario completa el formulario de registro.
2. La información se envía a una Server Action.
3. Se validan los datos recibidos.
4. Supabase Authentication crea la cuenta.
5. Se crea el perfil del usuario en la base de datos.
6. El usuario inicia sesión automáticamente o es redirigido al formulario de autenticación, según la configuración adoptada.

---

### Flujo de Pronóstico

1. El usuario selecciona un torneo.
2. Consulta los partidos que ya poseen dos equipos y fecha definida.
3. Ingresa el resultado esperado y, si pronostica empate, selecciona el ganador por penales.
4. El cliente envía la información mediante una Server Action.
5. El servidor verifica que el partido aún no haya comenzado.
6. El servidor valida la coherencia entre el marcador y el ganador por penales.
7. El pronóstico se almacena en la base de datos.
8. Si es el primer pronóstico del usuario en ese torneo, se crea su registro de Puntaje por Torneo con cero puntos.
9. El usuario recibe una confirmación de la operación.

---

### Flujo de Publicación de Resultados

1. El administrador selecciona un partido finalizado.
2. Ingresa el resultado oficial y, si está empatado, el ganador por penales.
3. El servidor valida que el usuario tenga permisos de administrador.
4. El servidor verifica que el partido aún no tenga un resultado oficial registrado.
5. Se valida la coherencia entre el marcador y el ganador por penales.
6. Se determina el equipo que avanza.
7. Se actualiza el partido con el resultado oficial y este queda bloqueado de forma permanente.
8. Se recuperan todos los pronósticos correspondientes al partido.
9. Se calcula el puntaje obtenido por cada participante aplicando las reglas de 0, 3 o 6 puntos.
10. Se actualizan los registros de Puntaje por Torneo.
11. El ganador se ubica en el partido siguiente o se marca como campeón si es la final.
12. La tabla de posiciones refleja automáticamente los nuevos puntajes.

---

### Flujo de Consulta del Ranking

1. El usuario accede al torneo.
2. El servidor consulta la tabla de Puntaje por Torneo.
3. Los resultados se ordenan por puntos descendentes y por los criterios visuales estables definidos para los empates.
4. Se calcula la posición compartida mediante el criterio de competición estándar.
5. Se devuelve la clasificación al cliente.
6. La interfaz presenta la tabla de posiciones actualizada.

---

