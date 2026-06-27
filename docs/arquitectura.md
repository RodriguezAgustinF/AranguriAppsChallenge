# ARCHITECTURE.md

# Arquitectura de Software

## Proyecto: Prode de Fútbol

---

# 1. Objetivo del Proyecto

## Descripción General

El objetivo del proyecto es desarrollar una aplicación web que permita organizar torneos de pronósticos deportivos ("Prode") sobre partidos de fútbol.

La aplicación contará con dos perfiles de usuario:

* **Administrador**, responsable de la gestión de los torneos, partidos y resultados oficiales.
* **Usuario Común**, encargado de realizar pronósticos sobre los resultados de los partidos y competir con otros participantes dentro de cada torneo.

Cada torneo funcionará de manera completamente independiente, manteniendo su propio conjunto de partidos, participantes y tabla de posiciones.

Una vez que un administrador publique el resultado oficial de un partido, el sistema calculará automáticamente el puntaje obtenido por cada participante según la precisión de su pronóstico.

El proyecto busca priorizar:

* simplicidad
* mantenibilidad
* escalabilidad
* bajo costo operativo
* buena experiencia de desarrollo

Por este motivo se adopta una arquitectura Full Stack basada en Next.js y Supabase, evitando la complejidad de mantener un backend independiente.

---

# Objetivos Funcionales

La aplicación deberá permitir:

### Administradores

* Iniciar sesión con una cuenta aprovisionada manualmente.
* Crear torneos.
* Editar torneos antes de su inicio.
* Eliminar torneos antes de su inicio.
* Crear partidos.
* Editar partidos antes de su inicio.
* Eliminar partidos antes de su inicio.
* Registrar el resultado oficial de los partidos finalizados.

Las cuentas administrativas no podrán crearse mediante el registro público. Su aprovisionamiento requerirá crear manualmente la identidad en Supabase Authentication y el perfil correspondiente en la tabla de usuarios con rol `ADMIN`.

### Usuarios

* Registrarse.
* Iniciar sesión.
* Consultar torneos.
* Consultar partidos.
* Registrar pronósticos.
* Modificar pronósticos únicamente antes del inicio del partido.
* Consultar su puntaje dentro de cada torneo.

### Sistema

* Calcular automáticamente los puntajes cuando exista un resultado oficial.
* Mantener una tabla de posiciones independiente para cada torneo.
* Garantizar que las reglas del negocio no puedan ser vulneradas desde el cliente.
* Considerar participante de un torneo a todo usuario que haya guardado al menos un pronóstico para uno de sus partidos.
* Impedir la modificación o eliminación de un resultado oficial una vez registrado.

---

# Objetivos No Funcionales

La solución deberá cumplir los siguientes atributos de calidad:

* Código mantenible.
* Arquitectura modular.
* Separación clara de responsabilidades.
* Seguridad basada en autenticación y autorización.
* Escalabilidad para incorporar nuevas funcionalidades.
* Despliegue sencillo.
* Baja complejidad operacional.
* Excelente experiencia para el desarrollador.

---

# 2. Tecnologías Elegidas

## Next.js (App Router)

Next.js constituye el núcleo de la aplicación.

Permite desarrollar una solución Full Stack utilizando un único proyecto para frontend y backend.

Su App Router ofrece una arquitectura moderna basada en componentes del servidor, rutas anidadas y renderizado híbrido.

### ¿Por qué se eligió?

* Unifica frontend y backend.
* Excelente integración con React.
* Renderizado híbrido (SSR, SSG y CSR).
* Excelente experiencia de desarrollo.
* Integración nativa con Server Actions.
* Optimización automática.
* Despliegue directo en Vercel.

---

## React

React será utilizado para construir toda la interfaz de usuario.

Su modelo basado en componentes favorece la reutilización, el mantenimiento y la composición de interfaces complejas.

### Ventajas

* Componentes reutilizables.
* Gran ecosistema.
* Excelente integración con Next.js.
* Comunidad madura.
* Fácil mantenimiento.

---

## TypeScript

Todo el proyecto será desarrollado utilizando TypeScript en modo estricto.

### Motivos

* Tipado estático.
* Menor cantidad de errores en producción.
* Refactorizaciones seguras.
* Mejor autocompletado.
* Mayor mantenibilidad.

Al tratarse de una aplicación basada en múltiples entidades (usuarios, torneos, partidos, pronósticos, puntajes), el tipado aporta una ventaja significativa.

---

## Tailwind CSS

Tailwind será utilizado como framework CSS.

### Justificación

* Desarrollo rápido.
* Bajo costo de mantenimiento.
* Consistencia visual.
* Eliminación automática de estilos no utilizados.
* Excelente integración con React.

No se considera necesario incorporar librerías UI pesadas para el alcance del MVP.

---

## Supabase

Supabase será utilizado como Backend as a Service (BaaS).

Proporciona los principales servicios requeridos por la aplicación:

* Base de datos PostgreSQL.
* Autenticación.
* Row Level Security.
* API automática.
* Almacenamiento de archivos (Storage).
* Panel administrativo.

Su integración con Next.js reduce significativamente la complejidad del proyecto.

---

## PostgreSQL

La persistencia de datos estará basada en PostgreSQL administrado por Supabase.

### Motivos

* Base de datos relacional.
* Excelente soporte para integridad referencial.
* Transacciones ACID.
* Alto rendimiento.
* Escalabilidad.
* Consultas complejas.

El modelo del negocio (usuarios, torneos, equipos, partidos y pronósticos) posee relaciones claramente definidas, lo que hace que una base de datos relacional sea la opción más adecuada.

---

## Server Actions

La lógica de negocio se implementará principalmente mediante Server Actions.

Estas permiten ejecutar código exclusivamente del lado del servidor sin necesidad de construir una API REST tradicional.

### Ventajas

* Menor cantidad de código.
* Mayor seguridad.
* Acceso directo a Supabase.
* Mejor integración con formularios.
* Menor complejidad arquitectónica.

Las operaciones críticas, como crear torneos, registrar pronósticos o calcular puntajes, serán ejecutadas mediante Server Actions.

---

## Route Handlers

Los Route Handlers se utilizarán únicamente cuando sea necesario exponer endpoints HTTP.

Ejemplos:

* Webhooks.
* Integraciones futuras.
* Exportación de datos.
* APIs públicas.

No serán el mecanismo principal para la lógica del negocio.

---

## Vercel

La aplicación será desplegada en Vercel.

### Razones

* Integración nativa con Next.js.
* Despliegue automático desde GitHub.
* HTTPS incluido.
* Escalado automático.
* Excelente rendimiento.
* Configuración mínima.

Esta elección reduce considerablemente el esfuerzo operativo del proyecto.

---

# Resumen Tecnológico

| Tecnología     | Responsabilidad       |
| -------------- | --------------------- |
| Next.js        | Framework Full Stack  |
| React          | Interfaz de usuario   |
| TypeScript     | Tipado estático       |
| Tailwind CSS   | Estilos               |
| Supabase Auth  | Autenticación         |
| PostgreSQL     | Persistencia          |
| Server Actions | Lógica del negocio    |
| Route Handlers | Endpoints específicos |
| Vercel         | Despliegue            |

# 3. Arquitectura General

## Visión General

La aplicación seguirá una arquitectura **Full Stack** basada en Next.js y Supabase.

El objetivo principal es centralizar tanto la interfaz de usuario como la lógica del servidor en un único proyecto, reduciendo la complejidad de desarrollo y mantenimiento.

Las operaciones de negocio se ejecutarán en el servidor mediante **Server Actions** y, en casos específicos, mediante **Route Handlers**. Estas capas serán responsables de validar las solicitudes, aplicar las reglas de negocio e interactuar con Supabase.

Supabase proporcionará los servicios de autenticación y persistencia utilizando PostgreSQL como motor de base de datos.

## Arquitectura de Alto Nivel

```text
                    ┌──────────────────────┐
                    │       Cliente        │
                    │  (Browser / React)   │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │      Next.js         │
                    │      App Router      │
                    └──────────┬───────────┘
                               │
               ┌───────────────┴────────────────┐
               ▼                                ▼
      ┌─────────────────┐              ┌─────────────────┐
      │ Server Actions  │              │ Route Handlers  │
      └────────┬────────┘              └────────┬────────┘
               │                                │
               └───────────────┬────────────────┘
                               ▼
                    ┌──────────────────────┐
                    │      Supabase        │
                    │ Auth + PostgreSQL    │
                    └──────────┬───────────┘
                               ▼
                    ┌──────────────────────┐
                    │     PostgreSQL       │
                    └──────────────────────┘
```

## Responsabilidades de cada capa

### Cliente (React)

Responsabilidades:

* Renderizar la interfaz de usuario.
* Capturar las acciones del usuario.
* Mostrar el estado de la aplicación.
* Consumir Server Actions.
* Mostrar mensajes de éxito o error.

El cliente **no contiene reglas críticas del negocio**. Las validaciones del lado del cliente se utilizan únicamente para mejorar la experiencia del usuario.

---

### Next.js (App Router)

Representa el núcleo de la aplicación.

Responsabilidades:

* Enrutamiento.
* Renderizado de páginas.
* Renderizado híbrido (SSR/CSR).
* Composición de componentes.
* Integración entre cliente y servidor.

Además, organiza el proyecto utilizando una estructura modular basada en funcionalidades.

---

### Server Actions

Constituyen la principal capa de lógica de negocio.

Responsabilidades:

* Validar permisos.
* Validar datos recibidos.
* Ejecutar reglas del negocio.
* Consultar y actualizar la base de datos.
* Recalcular puntajes.
* Gestionar transacciones cuando sea necesario.

Al ejecutarse exclusivamente en el servidor, reducen la superficie de ataque y evitan exponer lógica sensible al cliente.

---

### Route Handlers

Se utilizarán únicamente cuando sea necesario exponer un endpoint HTTP.

Posibles casos de uso futuros:

* Integración con servicios externos.
* Exportación de datos.
* Webhooks.
* API pública.

En el MVP no se espera un uso intensivo de esta capa.

---

### Supabase

Supabase actúa como plataforma backend administrada.

Servicios utilizados:

* Authentication.
* PostgreSQL.
* Row Level Security.
* SDK oficial.

No se utilizará Storage en el MVP, ya que la aplicación no requiere carga de archivos. Su incorporación queda abierta para futuras funcionalidades, como imágenes de equipos o avatares de usuarios.

---

### PostgreSQL

Es la fuente única de verdad del sistema.

Responsabilidades:

* Persistencia.
* Integridad referencial.
* Restricciones.
* Relaciones entre entidades.
* Consultas de datos.

Toda la información crítica se almacena en PostgreSQL, garantizando consistencia y durabilidad.

---

## Principios Arquitectónicos

La arquitectura se basa en los siguientes principios:

### Separación de responsabilidades

Cada capa posee responsabilidades claramente definidas.

* La interfaz presenta información.
* El servidor aplica reglas de negocio.
* La base de datos almacena la información.

Esta separación facilita el mantenimiento y las pruebas.

### Single Source of Truth

La base de datos representa la única fuente válida de información.

El cliente nunca debe asumir que posee el estado correcto; toda operación crítica debe confirmarse contra el servidor.

### Server First

Las reglas de negocio residen en el servidor.

Esto incluye operaciones como:

* creación de torneos;
* modificación de partidos;
* registro de resultados oficiales;
* cálculo de puntajes;
* validación de permisos.

### Simplicidad

Se evita incorporar componentes arquitectónicos innecesarios como:

* microservicios;
* backend independiente;
* colas de mensajería;
* gateways;
* Redux;
* patrones empresariales complejos.

Estas decisiones mantienen el proyecto liviano y fácil de evolucionar.

---

# 4. Arquitectura del Frontend

## Enfoque basado en Features

La aplicación adoptará una organización basada en **features** (funcionalidades del negocio), en lugar de una estructura puramente técnica.

Este enfoque favorece:

* alta cohesión;
* bajo acoplamiento;
* escalabilidad;
* reutilización;
* facilidad para incorporar nuevas funcionalidades.

Cada feature encapsula sus componentes, lógica y tipos relacionados.

## Estructura de Carpetas

```text
src/
│
├── app/
│
├── actions/
│
├── components/
│
├── features/
│
├── hooks/
│
├── lib/
│
├── services/
│
├── types/
│
├── utils/
│
└── middleware.ts
```

### app/

Contiene la definición de rutas mediante el App Router.

Ejemplo:

```text
app/
│
├── login/
├── register/
├── dashboard/
├── tournaments/
├── tournaments/[id]/
├── admin/
└── profile/
```

Cada carpeta representa una ruta accesible por el usuario.

---

### actions/

Agrupa todas las Server Actions del proyecto.

Ejemplos:

```text
actions/
│
├── auth/
├── tournaments/
├── matches/
├── predictions/
└── rankings/
```

Cada acción representa una operación de negocio ejecutada en el servidor.

---

### components/

Incluye componentes reutilizables y desacoplados de una funcionalidad específica.

Ejemplos:

* Button
* Card
* Modal
* Table
* Badge
* Input
* Select
* Dialog
* Spinner
* Navbar

Estos componentes conforman el sistema de diseño de la aplicación.

---

### features/

Representa el corazón de la aplicación.

Cada carpeta encapsula una funcionalidad del dominio.

```text
features/
│
├── auth/
├── tournaments/
├── matches/
├── predictions/
├── leaderboard/
└── users/
```

Cada feature puede contener:

```text
matches/
│
├── components/
├── hooks/
├── types/
├── validators/
└── utils/
```

Este enfoque reduce el acoplamiento y facilita el mantenimiento.

---

### hooks/

Contiene hooks reutilizables.

Ejemplos:

* useCurrentUser
* useDebounce
* usePagination
* useCountdownToMatch

Los hooks no deben contener reglas críticas de negocio.

---

### lib/

Agrupa configuraciones compartidas.

Ejemplos:

* cliente de Supabase;
* helpers de autenticación;
* utilidades de acceso al servidor;
* configuración global.

---

### services/

Contiene funciones encargadas de interactuar con servicios externos o encapsular operaciones reutilizables.

Ejemplos:

* consultas complejas a Supabase;
* utilidades para rankings;
* funciones de cálculo compartidas.

Su objetivo es evitar duplicación de lógica entre distintas Server Actions.

---

### types/

Define los tipos globales de la aplicación.

Ejemplos:

* User
* Tournament
* Match
* Prediction
* LeaderboardEntry

Centralizar los tipos mejora la consistencia y facilita las refactorizaciones.

---

### utils/

Incluye funciones auxiliares sin dependencia del dominio.

Ejemplos:

* formateo de fechas;
* validaciones comunes;
* conversión de datos;
* utilidades matemáticas.

---

### middleware.ts

El middleware se utilizará para proteger rutas que requieren autenticación.

Ejemplos:

* impedir que usuarios no autenticados accedan al panel;
* redirigir usuarios autenticados desde la pantalla de login;
* validar sesiones activas.

## Organización de Componentes

Se promoverá una jerarquía clara de componentes:

* Componentes de presentación: muestran información y reciben datos mediante props.
* Componentes de feature: encapsulan la lógica específica de una funcionalidad.
* Componentes de página: componen la interfaz utilizando componentes de menor nivel.

Esta separación mejora la reutilización y facilita el mantenimiento del código.

# 5. Arquitectura Backend

## Enfoque General

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

## Responsabilidades del Cliente

El cliente únicamente será responsable de:

* capturar la interacción del usuario;
* mostrar información;
* realizar validaciones básicas de formularios;
* invocar Server Actions.

No contendrá reglas de negocio críticas, ya que cualquier validación realizada en el navegador puede ser modificada o eludida por un usuario malintencionado.

---

## Responsabilidades de las Server Actions

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

### Autenticación

Responsabilidades:

* registro de usuarios;
* inicio de sesión;
* cierre de sesión.

El registro público creará exclusivamente usuarios con rol `USER`. Las cuentas con rol `ADMIN` serán aprovisionadas manualmente en Supabase Authentication y en la tabla de usuarios.

### Torneos

Responsabilidades:

* crear torneo;
* actualizar torneo;
* eliminar torneo;
* obtener información del torneo.

Antes de modificar un torneo deberán verificarse reglas como:

* que el usuario sea administrador;
* que el torneo aún no haya comenzado.

---

### Partidos

Responsabilidades:

* crear partido;
* editar partido;
* eliminar partido;
* obtener partidos de un torneo.

Antes de modificar un partido se validará:

* rol del usuario;
* fecha de inicio del partido.

---

### Pronósticos

Responsabilidades:

* registrar pronóstico;
* modificar pronóstico;
* consultar pronósticos del usuario.

La Server Action verificará siempre que el partido no haya comenzado.

La decisión nunca dependerá del reloj del navegador.

La comparación se realizará utilizando la fecha almacenada en la base de datos y el horario del servidor.

---

### Resultados Oficiales

Cuando un administrador publique un resultado oficial se ejecutará una Server Action encargada de:

1. validar permisos;
2. actualizar los goles del partido y marcarlo como finalizado.
3. recuperar todos los pronósticos correspondientes al partido;
4. calcular el puntaje obtenido por cada participante;
5. actualizar la tabla de posiciones del torneo.

De esta manera se garantiza que el ranking siempre refleje los resultados oficiales.

Antes de registrar el resultado, la Server Action verificará que el partido no posea ya un resultado oficial. Una vez publicado, el resultado será inmutable y no existirá una operación para editarlo o eliminarlo.

El cálculo aplicará las siguientes reglas:

* 0 puntos si no se acierta el ganador ni el empate;
* 3 puntos si se acierta el ganador o el empate, pero no el marcador exacto;
* 6 puntos si se acierta el marcador exacto.

---

## Servicios del Dominio

Aunque el proyecto no contará con una arquitectura en capas tradicional, resulta conveniente encapsular determinadas operaciones reutilizables dentro de servicios del dominio.

Ejemplos:

```text
services/

calculatePoints.ts
rankingService.ts
tournamentService.ts
predictionService.ts
```

Estos servicios contienen lógica reutilizable, mientras que las Server Actions coordinan el flujo de ejecución.

Por ejemplo, el cálculo de puntos no debería implementarse directamente dentro de la Server Action, ya que podría reutilizarse en distintos escenarios futuros.

---

## Distribución de la Lógica de Negocio

| Regla                       | Ubicación            |
| --------------------------- | -------------------- |
| Crear torneo                | Server Action        |
| Editar torneo               | Server Action        |
| Eliminar torneo             | Server Action        |
| Crear partido               | Server Action        |
| Editar partido              | Server Action        |
| Eliminar partido            | Server Action        |
| Registrar pronóstico        | Server Action        |
| Editar pronóstico            | Server Action        |
| Registrar resultado del partido  | Server Action        |
| Calcular puntos             | Servicio del dominio |
| Actualizar ranking          | Servicio del dominio |
| Validar permisos            | Server Action        |
| Validar fechas              | Server Action        |

---

## Acceso a la Base de Datos

Toda interacción con PostgreSQL se realizará mediante el cliente oficial de Supabase.

Las consultas se mantendrán lo más simples posible, delegando la lógica de negocio al servidor.

Este enfoque evita concentrar reglas complejas en la base de datos y favorece una mayor legibilidad del código.

---

# 6. Base de Datos

## Principios de Diseño

El modelo de datos sigue un enfoque relacional, aprovechando las capacidades de PostgreSQL para garantizar:

* integridad referencial;
* consistencia;
* normalización;
* facilidad de consulta.

Cada entidad representa un concepto propio del dominio del negocio.

---

## Usuario

### Propósito

Representa a las personas que utilizan la aplicación.

Un usuario puede participar en múltiples torneos y realizar pronósticos sobre distintos partidos. La participación comienza al guardar su primer pronóstico para un partido del torneo y no requiere una entidad ni un proceso de inscripción independiente.

### Campos principales

* id
* nombre
* email
* rol
* createdAt

### Relaciones

* Un usuario puede registrar muchos pronósticos.
* Un usuario posee un puntaje por cada torneo en el que participa.

---

## Torneo

### Propósito

Agrupa un conjunto de partidos y mantiene una clasificación independiente de participantes.

Cada torneo constituye una competencia aislada.

### Campos principales

* id
* nombre
* descripción
* fechaInicio
* fechaFin
* estado
* createdAt

### Relaciones

* Un torneo contiene muchos partidos.
* Un torneo posee muchos puntajes.
* Un torneo posee muchos participantes, derivados de los usuarios que registraron al menos un pronóstico para sus partidos.

---

## Equipo

### Propósito

Representa un equipo de fútbol participante.

La entidad evita duplicar información de los equipos en múltiples partidos.

### Campos principales

* id
* nombre
* abreviatura
* escudo (opcional)

### Relaciones

Un equipo participa en muchos partidos.

---

## Partido

### Propósito

Representa un encuentro deportivo entre dos equipos perteneciente a un torneo.

### Campos principales

* id
* torneoId
* equipoLocalId
* equipoVisitanteId
* fechaHora
* estado
* golesLocal (nullable)
* golesVisitante (nullable)
* resultadoPublicadoEn (nullable)

### Relaciones

* Pertenece a un torneo.
* Posee dos equipos.
* Posee múltiples pronósticos.

---

## Pronóstico

### Propósito

Almacena la predicción realizada por un usuario para un partido determinado.

### Campos principales

* id
* usuarioId
* partidoId
* golesLocal
* golesVisitante
* createdAt

### Relaciones

* Pertenece a un usuario.
* Pertenece a un partido.

Debe existir un único pronóstico por usuario y partido.


---

## Puntaje por Torneo

### Propósito

Almacena la cantidad de puntos acumulados por un usuario dentro de un torneo.

Esta entidad evita recalcular continuamente todos los pronósticos para generar la tabla de posiciones.

### Campos principales

* id
* usuarioId
* torneoId
* puntos

### Relaciones

* Pertenece a un usuario.
* Pertenece a un torneo.

La combinación usuario–torneo debe ser única.

El registro de Puntaje por Torneo se creará al guardar el primer pronóstico del usuario dentro del torneo, con un puntaje inicial de cero. De esta forma, el mismo registro representa su participación y permite incluirlo en la clasificación antes de que se publiquen resultados.

---

## Modelo Conceptual

```text
                    Usuario
                       │
        ┌──────────────┴──────────────┐
        │                             │
        ▼                             ▼
   Pronóstico                  PuntajeTorneo
        │                             │
        ▼                             ▼
      Partido ─────────────► Torneo
        │
        │
 ┌──────┴────────┐
 ▼               ▼
Equipo       Equipo
(Local)     (Visitante)
```

---

## Consideraciones de Modelado

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


# 7. Flujo de la Aplicación

## Flujo General

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

## Flujo de Registro

1. El usuario completa el formulario de registro.
2. La información se envía a una Server Action.
3. Se validan los datos recibidos.
4. Supabase Authentication crea la cuenta.
5. Se crea el perfil del usuario en la base de datos.
6. El usuario inicia sesión automáticamente o es redirigido al formulario de autenticación, según la configuración adoptada.

---

## Flujo de Pronóstico

1. El usuario selecciona un torneo.
2. Consulta los partidos disponibles.
3. Ingresa el resultado esperado para cada partido.
4. El cliente envía la información mediante una Server Action.
5. El servidor verifica que el partido aún no haya comenzado.
6. El pronóstico se almacena en la base de datos.
7. Si es el primer pronóstico del usuario en ese torneo, se crea su registro de Puntaje por Torneo con cero puntos.
8. El usuario recibe una confirmación de la operación.

---

## Flujo de Publicación de Resultados

1. El administrador selecciona un partido finalizado.
2. Ingresa el resultado oficial.
3. El servidor valida que el usuario tenga permisos de administrador.
4. El servidor verifica que el partido aún no tenga un resultado oficial registrado.
5. Se actualiza el partido con el resultado oficial y este queda bloqueado de forma permanente.
6. Se recuperan todos los pronósticos correspondientes al partido.
7. Se calcula el puntaje obtenido por cada participante aplicando las reglas de 0, 3 o 6 puntos.
8. Se actualizan los registros de Puntaje por Torneo.
9. La tabla de posiciones refleja automáticamente los nuevos puntajes.

---

## Flujo de Consulta del Ranking

1. El usuario accede al torneo.
2. El servidor consulta la tabla de Puntaje por Torneo.
3. Los resultados se ordenan por cantidad de puntos.
4. Se devuelve la clasificación al cliente.
5. La interfaz presenta la tabla de posiciones actualizada.

---

# 8. Seguridad

La seguridad constituye un aspecto central de la arquitectura y se implementa en múltiples niveles para proteger tanto la información como las reglas del negocio.

## Autenticación

La autenticación será gestionada mediante Supabase Authentication.

Las responsabilidades incluyen:

* registro de usuarios;
* inicio de sesión;
* cierre de sesión;
* administración de sesiones.

La recuperación de contraseña no forma parte del MVP. El registro público solo permitirá crear cuentas con rol `USER`; las cuentas administrativas se aprovisionarán manualmente tanto en Supabase Authentication como en la tabla de usuarios.

Las credenciales nunca serán almacenadas ni procesadas directamente por la aplicación.

---

## Autorización

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

## Row Level Security (RLS)

Se utilizará Row Level Security (RLS) de Supabase para reforzar el control de acceso a los datos.

Las políticas permitirán garantizar que cada usuario únicamente pueda acceder a la información que le corresponde.

Ejemplos:

* un usuario solo podrá consultar y modificar sus propios pronósticos;
* un usuario no podrá alterar el puntaje de otro participante;
* las operaciones administrativas estarán restringidas a usuarios con rol ADMIN.

El uso de RLS agrega una capa adicional de seguridad incluso si un cliente intenta acceder directamente a la base de datos mediante el SDK de Supabase.

---

## Validaciones del Lado del Servidor

Todas las reglas críticas del negocio serán verificadas mediante Server Actions antes de modificar la base de datos.

Entre ellas:

* verificar autenticación;
* verificar autorización;
* validar existencia de entidades;
* comprobar que un torneo no haya comenzado;
* comprobar que un partido no haya iniciado;
* impedir que usuarios no autorizados actualicen el resultado de un partido.
* evitar pronósticos duplicados para un mismo partido.

Estas validaciones son obligatorias, independientemente de las comprobaciones realizadas en el cliente.

---

## Protección Contra Manipulación del Cliente

Ninguna decisión de negocio dependerá de información enviada por el navegador sin ser validada.

El servidor será responsable de:

* determinar el usuario autenticado;
* verificar el rol del usuario;
* comprobar las fechas de inicio de los partidos;
* calcular los puntajes;
* actualizar la clasificación.

Este enfoque evita que un usuario pueda modificar el comportamiento del sistema manipulando el código ejecutado en el navegador.

---

# 9. Escalabilidad

Aunque la aplicación se desarrolla como un MVP, la arquitectura permite incorporar nuevas funcionalidades sin necesidad de realizar cambios estructurales significativos.

## Nuevos Deportes

El modelo puede extenderse para soportar otras disciplinas deportivas mediante la incorporación de una entidad que represente el deporte y la adaptación de las reglas de puntaje.

---

## Temporadas

Los torneos podrían agruparse en temporadas, permitiendo mantener el historial de competencias y estadísticas entre distintos años.

---

## Estadísticas

Podrían incorporarse funcionalidades como:

* porcentaje de aciertos;
* mejor racha de pronósticos;
* ranking histórico;
* cantidad de resultados exactos;
* evolución del puntaje por fecha.

La estructura actual favorece este tipo de consultas.

---

## Notificaciones

La aplicación podría integrar notificaciones por correo electrónico o push para informar a los usuarios sobre:

* inicio de nuevos torneos;
* cierre del período de pronósticos;
* publicación de resultados oficiales.

---

## Tiempo Real

La incorporación de Supabase Realtime permitiría actualizar automáticamente:

* resultados oficiales;
* tablas de posiciones;
* puntajes de los participantes.

De esta manera se eliminaría la necesidad de recargar manualmente la interfaz.

---

# 10. Buenas Prácticas

El desarrollo seguirá un conjunto de lineamientos destinados a mantener un código consistente y fácil de mantener.

## TypeScript Estricto

Se utilizará el modo estricto de TypeScript para reducir errores en tiempo de compilación y facilitar las refactorizaciones.

---

## Separación de Responsabilidades

Cada módulo tendrá una responsabilidad claramente definida.

* los componentes renderizan información;
* las Server Actions coordinan operaciones;
* los servicios encapsulan lógica reutilizable;
* la base de datos almacena el estado de la aplicación.

---

## Componentes Reutilizables

Los componentes compartidos se ubicarán en una carpeta común para evitar duplicación de código y promover una interfaz consistente.

---

## Manejo de Errores

Las operaciones críticas deberán manejar errores de forma controlada.

Los mensajes presentados al usuario serán claros y evitarán exponer detalles internos del sistema.

Los errores inesperados podrán registrarse para facilitar su análisis y resolución.

---

## Variables de Entorno

Las credenciales y configuraciones sensibles se almacenarán mediante variables de entorno.

No se incluirán secretos directamente en el código fuente.

---

## Validaciones

Las validaciones se implementarán en dos niveles:

* cliente, para mejorar la experiencia del usuario;
* servidor, para garantizar el cumplimiento de las reglas del negocio.

---

## Convenciones de Nombres

Se adoptarán convenciones consistentes en todo el proyecto.

Ejemplos:

* Componentes: PascalCase.
* Hooks: prefijo `use`.
* Funciones: camelCase.
* Tipos e interfaces: PascalCase.
* Constantes: UPPER_SNAKE_CASE.
* Carpetas: kebab-case o minúsculas, manteniendo un criterio uniforme.

La consistencia en la nomenclatura facilita la comprensión y el mantenimiento del código.

---

## Idioma del Código

Todo el código fuente deberá escribirse en inglés.

Esto incluye:

- nombres de variables;
- funciones;
- clases;
- componentes;
- interfaces;
- tipos;
- enumeraciones;
- tablas y columnas de la base de datos;
- comentarios técnicos.

La documentación funcional podrá redactarse en español, pero cualquier elemento que forme parte del código o del modelo de datos utilizará nomenclatura en inglés.

Esta decisión favorece la consistencia del proyecto, facilita la incorporación de nuevas herramientas y simplifica la colaboración con desarrolladores de distintos entornos.

# 11. Architecture Decision Records (ADR Simplificados)

## ADR-001: Uso de Next.js como Framework Full Stack

**Decisión**

Utilizar Next.js con App Router como base de la aplicación.

**Ventajas**

* Un único proyecto para frontend y backend.
* Excelente integración con React.
* Server Actions integradas.
* Despliegue optimizado en Vercel.

**Desventajas**

* Mayor dependencia del ecosistema Next.js.
* Menor flexibilidad para reutilizar la lógica del servidor en otros clientes.

---

## ADR-002: Uso de Supabase como Backend as a Service

**Decisión**

Adoptar Supabase para la autenticación y persistencia.

**Ventajas**

* Reduce significativamente el código de infraestructura.
* PostgreSQL administrado.
* Autenticación integrada.
* Row Level Security.
* Escalabilidad administrada.

**Desventajas**

* Dependencia de un proveedor externo.
* Algunas funcionalidades avanzadas pueden requerir adaptar la solución al ecosistema de Supabase.

---

## ADR-003: Uso de Server Actions para la Lógica de Negocio

**Decisión**

Implementar las operaciones principales mediante Server Actions.

**Ventajas**

* Menor cantidad de código.
* Mayor seguridad.
* Integración natural con Next.js.
* Evita la creación de una API REST innecesaria.

**Desventajas**

* Acoplamiento con el framework.
* Menor reutilización directa desde clientes externos.

---

## ADR-004: Arquitectura Basada en Features

**Decisión**

Organizar el código por funcionalidades del dominio.

**Ventajas**

* Mayor cohesión.
* Bajo acoplamiento.
* Escalabilidad.
* Mejor mantenibilidad.
* Facilita el trabajo sobre módulos independientes.

**Desventajas**

* Requiere mantener una estructura consistente a medida que crece el proyecto.

---

## ADR-005: No Implementar un Backend Independiente

**Decisión**

Evitar un backend separado en el MVP.

**Ventajas**

* Menor complejidad arquitectónica.
* Reducción del esfuerzo de desarrollo y despliegue.
* Un único repositorio.
* Menores costos operativos.

**Desventajas**

* La lógica de negocio queda acoplada a Next.js.
* Si en el futuro se requirieran múltiples clientes con necesidades muy diferentes, podría ser necesario reevaluar esta decisión.

---

# 12. Alcance

## Funcionalidades Incluidas en el MVP

El MVP contempla las capacidades necesarias para ofrecer una experiencia completa de gestión de torneos y pronósticos deportivos.

Incluye:

* registro e inicio de sesión de usuarios;
* gestión de torneos por administradores;
* gestión de partidos;
* carga de resultados oficiales;
* registro y edición de pronósticos antes del inicio de los partidos;
* cálculo automático de puntajes;
* tabla de posiciones por torneo;
* autenticación y autorización basadas en roles.

---

## Funcionalidades Fuera del Alcance del MVP

Las siguientes funcionalidades se consideran posibles evoluciones del sistema y no forman parte de la primera versión:

* múltiples deportes;
* temporadas y competencias históricas;
* carga de imágenes y avatares;
* notificaciones por correo o push;
* estadísticas avanzadas;
* actualizaciones en tiempo real mediante Supabase Realtime;
* exportación de resultados;
* integración con APIs deportivas externas;
* panel de administración avanzado;
* internacionalización.

Estas funcionalidades podrán incorporarse en futuras iteraciones sin requerir cambios significativos en la arquitectura propuesta.

---

# Conclusión

La arquitectura propuesta prioriza la simplicidad, la mantenibilidad y la calidad del código, evitando complejidad innecesaria para el alcance del proyecto.

La combinación de Next.js, Supabase y PostgreSQL permite construir una aplicación Full Stack moderna con una única base de código, reduciendo el esfuerzo de desarrollo y operación sin comprometer la escalabilidad futura.

La organización basada en *features*, el uso de Server Actions para encapsular la lógica de negocio y las políticas de seguridad proporcionadas por Supabase constituyen una base sólida para la evolución del sistema, permitiendo incorporar nuevas funcionalidades de manera incremental y manteniendo una clara separación de responsabilidades.
