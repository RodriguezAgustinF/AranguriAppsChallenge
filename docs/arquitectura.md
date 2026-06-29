# Arquitectura de software

## Proyecto: Prode de Fútbol

Este documento presenta la visión general y funciona como punto de entrada a la documentación técnica del proyecto.

## Documentos relacionados

* [Dominio y flujos](./dominio-y-flujos.md): reglas del torneo, llave, estados, fechas, puntuación y flujos.
* [Datos y seguridad](./datos-y-seguridad.md): backend, modelo relacional, autenticación, RLS y transacciones.
* [Decisiones arquitectónicas](./decisiones-arquitectonicas.md): escalabilidad, buenas prácticas y ADR.
* [Alcance funcional](./alcance-funcional.md): funcionalidades y reglas visibles del producto.
* [Lista de tareas](./lista-de-tareas.md): backlog ordenado del MVP.
* [Registro de decisiones](./registro-de-decisiones.md): historial cronológico de decisiones y rectificaciones.

---

## Objetivo del proyecto

### Descripción General

El objetivo del proyecto es desarrollar una aplicación web que permita organizar torneos de pronósticos deportivos ("Prode") sobre partidos de fútbol.

La aplicación contará con dos perfiles de usuario:

* **Administrador**, responsable de la gestión de los torneos, partidos y resultados oficiales.
* **Usuario Común**, encargado de realizar pronósticos sobre los resultados de los partidos y competir con otros participantes dentro de cada torneo.

Cada torneo funcionará de manera completamente independiente, manteniendo sus equipos inscriptos, su llave, sus usuarios participantes y su tabla de posiciones del Prode.

Una vez que un administrador publique el resultado oficial de un partido, el sistema calculará automáticamente el puntaje obtenido por cada participante según la precisión de su pronóstico.

El proyecto busca priorizar:

* simplicidad
* mantenibilidad
* escalabilidad
* bajo costo operativo
* buena experiencia de desarrollo

Por este motivo se adopta una arquitectura Full Stack basada en Next.js y Supabase, evitando la complejidad de mantener un backend independiente.

---

### Objetivos funcionales

La aplicación deberá permitir:

#### Administradores

* Iniciar sesión con una cuenta aprovisionada manualmente.
* Crear torneos.
* Editar torneos antes de su inicio.
* Eliminar torneos antes de su inicio y mientras no posean pronósticos.
* Inscribir equipos y generar aleatoriamente la llave.
* Crear equipos.
* Editar equipos que no hayan sido utilizados en partidos iniciados.
* Eliminar equipos que no estén asociados a partidos.
* Programar y reprogramar los partidos generados por la llave.
* Registrar el resultado oficial de los partidos finalizados.

Las cuentas administrativas no podrán crearse mediante el registro público. Su aprovisionamiento requerirá crear manualmente la identidad en Supabase Authentication y el perfil correspondiente en la tabla de usuarios con rol `ADMIN`.

#### Usuarios

* Registrarse.
* Iniciar sesión.
* Consultar torneos.
* Consultar partidos.
* Registrar pronósticos.
* Modificar pronósticos únicamente antes del inicio del partido.
* Consultar su puntaje dentro de cada torneo.

#### Sistema

* Calcular automáticamente los puntajes cuando exista un resultado oficial.
* Mantener una tabla de posiciones independiente para cada torneo.
* Garantizar que las reglas del negocio no puedan ser vulneradas desde el cliente.
* Considerar participante de un torneo a todo usuario que haya guardado al menos un pronóstico para uno de sus partidos.
* Impedir la modificación o eliminación de un resultado oficial una vez registrado.
* Generar una llave de eliminación directa para 4, 8, 16 o 32 equipos.
* Propagar automáticamente cada ganador al partido siguiente.

---

### Objetivos no funcionales

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

## Tecnologías elegidas

### Next.js (App Router)

Next.js constituye el núcleo de la aplicación.

Permite desarrollar una solución Full Stack utilizando un único proyecto para frontend y backend.

Su App Router ofrece una arquitectura moderna basada en componentes del servidor, rutas anidadas y renderizado híbrido.

#### ¿Por qué se eligió?

* Unifica frontend y backend.
* Excelente integración con React.
* Renderizado híbrido (SSR, SSG y CSR).
* Excelente experiencia de desarrollo.
* Integración nativa con Server Actions.
* Optimización automática.
* Despliegue directo en Vercel.

---

### React

React será utilizado para construir toda la interfaz de usuario.

Su modelo basado en componentes favorece la reutilización, el mantenimiento y la composición de interfaces complejas.

#### Ventajas

* Componentes reutilizables.
* Gran ecosistema.
* Excelente integración con Next.js.
* Comunidad madura.
* Fácil mantenimiento.

---

### TypeScript

Todo el proyecto será desarrollado utilizando TypeScript en modo estricto.

#### Motivos

* Tipado estático.
* Menor cantidad de errores en producción.
* Refactorizaciones seguras.
* Mejor autocompletado.
* Mayor mantenibilidad.

Al tratarse de una aplicación basada en múltiples entidades (usuarios, torneos, partidos, pronósticos, puntajes), el tipado aporta una ventaja significativa.

---

### Tailwind CSS

Tailwind será utilizado como framework CSS.

#### Justificación

* Desarrollo rápido.
* Bajo costo de mantenimiento.
* Consistencia visual.
* Eliminación automática de estilos no utilizados.
* Excelente integración con React.

No se considera necesario incorporar librerías UI pesadas para el alcance del MVP.

---

### Supabase

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

### PostgreSQL

La persistencia de datos estará basada en PostgreSQL administrado por Supabase.

#### Motivos

* Base de datos relacional.
* Excelente soporte para integridad referencial.
* Transacciones ACID.
* Alto rendimiento.
* Escalabilidad.
* Consultas complejas.

El modelo del negocio (usuarios, torneos, equipos, partidos y pronósticos) posee relaciones claramente definidas, lo que hace que una base de datos relacional sea la opción más adecuada.

---

### Server Actions

La lógica de negocio se implementará principalmente mediante Server Actions.

Estas permiten ejecutar código exclusivamente del lado del servidor sin necesidad de construir una API REST tradicional.

#### Ventajas

* Menor cantidad de código.
* Mayor seguridad.
* Acceso directo a Supabase.
* Mejor integración con formularios.
* Menor complejidad arquitectónica.

Las operaciones críticas, como crear torneos, registrar pronósticos o calcular puntajes, serán ejecutadas mediante Server Actions.

---

### Route Handlers

Los Route Handlers se utilizarán únicamente cuando sea necesario exponer endpoints HTTP.

Ejemplos:

* Webhooks.
* Integraciones futuras.
* Exportación de datos.
* APIs públicas.

No serán el mecanismo principal para la lógica del negocio.

---

### Vercel

La aplicación será desplegada en Vercel.

#### Razones

* Integración nativa con Next.js.
* Despliegue automático desde GitHub.
* HTTPS incluido.
* Escalado automático.
* Excelente rendimiento.
* Configuración mínima.

Esta elección reduce considerablemente el esfuerzo operativo del proyecto.

---

### Resumen tecnológico

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

## Arquitectura general

### Visión General

La aplicación seguirá una arquitectura **Full Stack** basada en Next.js y Supabase.

El objetivo principal es centralizar tanto la interfaz de usuario como la lógica del servidor en un único proyecto, reduciendo la complejidad de desarrollo y mantenimiento.

Las operaciones de negocio se ejecutarán en el servidor mediante **Server Actions** y, en casos específicos, mediante **Route Handlers**. Estas capas serán responsables de validar las solicitudes, aplicar las reglas de negocio e interactuar con Supabase.

Supabase proporcionará los servicios de autenticación y persistencia utilizando PostgreSQL como motor de base de datos.

### Arquitectura de Alto Nivel

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

### Responsabilidades de cada capa

#### Cliente (React)

Responsabilidades:

* Renderizar la interfaz de usuario.
* Capturar las acciones del usuario.
* Mostrar el estado de la aplicación.
* Consumir Server Actions.
* Mostrar mensajes de éxito o error.

El cliente **no contiene reglas críticas del negocio**. Las validaciones del lado del cliente se utilizan únicamente para mejorar la experiencia del usuario.

---

#### Next.js (App Router)

Representa el núcleo de la aplicación.

Responsabilidades:

* Enrutamiento.
* Renderizado de páginas.
* Renderizado híbrido (SSR/CSR).
* Composición de componentes.
* Integración entre cliente y servidor.

Además, organiza el proyecto utilizando una estructura modular basada en funcionalidades.

---

#### Server Actions

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

#### Route Handlers

Se utilizarán únicamente cuando sea necesario exponer un endpoint HTTP.

Posibles casos de uso futuros:

* Integración con servicios externos.
* Exportación de datos.
* Webhooks.
* API pública.

En el MVP no se espera un uso intensivo de esta capa.

---

#### Supabase

Supabase actúa como plataforma backend administrada.

Servicios utilizados:

* Authentication.
* PostgreSQL.
* Row Level Security.
* SDK oficial.

No se utilizará Storage en el MVP, ya que la aplicación no requiere carga de archivos. Su incorporación queda abierta para futuras funcionalidades, como imágenes de equipos o avatares de usuarios.

---

#### PostgreSQL

Es la fuente única de verdad del sistema.

Responsabilidades:

* Persistencia.
* Integridad referencial.
* Restricciones.
* Relaciones entre entidades.
* Consultas de datos.

Toda la información crítica se almacena en PostgreSQL, garantizando consistencia y durabilidad.

---

### Principios Arquitectónicos

La arquitectura se basa en los siguientes principios:

#### Separación de responsabilidades

Cada capa posee responsabilidades claramente definidas.

* La interfaz presenta información.
* El servidor aplica reglas de negocio.
* La base de datos almacena la información.

Esta separación facilita el mantenimiento y las pruebas.

#### Single Source of Truth

La base de datos representa la única fuente válida de información.

El cliente nunca debe asumir que posee el estado correcto; toda operación crítica debe confirmarse contra el servidor.

#### Server First

Las reglas de negocio residen en el servidor.

Esto incluye operaciones como:

* creación de torneos;
* modificación de partidos;
* registro de resultados oficiales;
* cálculo de puntajes;
* validación de permisos.

#### Simplicidad

Se evita incorporar componentes arquitectónicos innecesarios como:

* microservicios;
* backend independiente;
* colas de mensajería;
* gateways;
* Redux;
* patrones empresariales complejos.

Estas decisiones mantienen el proyecto liviano y fácil de evolucionar.

---

## Arquitectura del frontend

### Enfoque basado en Features

La aplicación adoptará una organización basada en **features** (funcionalidades del negocio), en lugar de una estructura puramente técnica.

Este enfoque favorece:

* alta cohesión;
* bajo acoplamiento;
* escalabilidad;
* reutilización;
* facilidad para incorporar nuevas funcionalidades.

Cada feature encapsula sus componentes, lógica y tipos relacionados.

### Estructura de Carpetas

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
└── proxy.ts
```

#### app/

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

#### actions/

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

#### components/

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

#### features/

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

#### hooks/

Contiene hooks reutilizables.

Ejemplos:

* useCurrentUser
* useDebounce
* usePagination
* useCountdownToMatch

Los hooks no deben contener reglas críticas de negocio.

---

#### lib/

Agrupa configuraciones compartidas.

Ejemplos:

* cliente de Supabase;
* helpers de autenticación;
* utilidades de acceso al servidor;
* configuración global.

---

#### services/

Contiene funciones encargadas de interactuar con servicios externos o encapsular operaciones reutilizables.

Ejemplos:

* consultas complejas a Supabase;
* utilidades para rankings;
* funciones de cálculo compartidas.

Su objetivo es evitar duplicación de lógica entre distintas Server Actions.

---

#### types/

Define los tipos globales de la aplicación.

Ejemplos:

* User
* Tournament
* Match
* Prediction
* LeaderboardEntry

Centralizar los tipos mejora la consistencia y facilita las refactorizaciones.

---

#### utils/

Incluye funciones auxiliares sin dependencia del dominio.

Ejemplos:

* formateo de fechas;
* validaciones comunes;
* conversión de datos;
* utilidades matemáticas.

---

#### proxy.ts

Next.js 16 renombró y deprecó la convención `middleware.ts` en favor de `proxy.ts`. Proxy se utilizará únicamente cuando sea necesario refrescar sesiones o realizar redirecciones optimistas. La autorización real continuará ejecutándose en páginas, Server Actions, funciones PostgreSQL y políticas RLS; Proxy no será la frontera de seguridad.

Ejemplos:

* impedir que usuarios no autenticados accedan al panel;
* redirigir usuarios autenticados desde la pantalla de login;
* validar sesiones activas.

### Organización de Componentes

Se promoverá una jerarquía clara de componentes:

* Componentes de presentación: muestran información y reciben datos mediante props.
* Componentes de feature: encapsulan la lógica específica de una funcionalidad.
* Componentes de página: componen la interfaz utilizando componentes de menor nivel.

Esta separación mejora la reutilización y facilita el mantenimiento del código.

## Alcance

### Funcionalidades Incluidas en el MVP

El MVP contempla las capacidades necesarias para ofrecer una experiencia completa de gestión de torneos y pronósticos deportivos.

Incluye:

* registro e inicio de sesión de usuarios;
* gestión de torneos por administradores;
* gestión del catálogo global de equipos;
* inscripción de 4, 8, 16 o 32 equipos por torneo;
* sorteo aleatorio único y generación de llaves de eliminación directa;
* programación de los partidos generados;
* avance automático de ganadores;
* definición del ganador por penales cuando el marcador esté empatado;
* carga de resultados oficiales;
* registro y edición de pronósticos antes del inicio de los partidos;
* cálculo automático de puntajes;
* tabla de posiciones por torneo;
* autenticación y autorización basadas en roles.

---

### Funcionalidades Fuera del Alcance del MVP

Las siguientes funcionalidades se consideran posibles evoluciones del sistema y no forman parte de la primera versión:

* múltiples deportes;
* fase de grupos;
* torneos con cantidades de equipos diferentes de 4, 8, 16 o 32;
* partidos de ida y vuelta;
* partido por el tercer puesto;
* cabezas de serie o sorteos condicionados;
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

## Conclusión

La arquitectura propuesta prioriza la simplicidad, la mantenibilidad y la calidad del código, evitando complejidad innecesaria para el alcance del proyecto.

La combinación de Next.js, Supabase y PostgreSQL permite construir una aplicación Full Stack moderna con una única base de código, reduciendo el esfuerzo de desarrollo y operación sin comprometer la escalabilidad futura.

La organización basada en *features*, el uso de Server Actions para encapsular la lógica de negocio y las políticas de seguridad proporcionadas por Supabase constituyen una base sólida para la evolución del sistema, permitiendo incorporar nuevas funcionalidades de manera incremental y manteniendo una clara separación de responsabilidades.
