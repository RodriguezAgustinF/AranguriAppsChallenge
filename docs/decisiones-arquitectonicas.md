# Decisiones arquitectónicas

Lineamientos evolutivos, buenas prácticas y Architecture Decision Records del proyecto.

[Volver a Arquitectura](./arquitectura.md)

---

## Escalabilidad

Aunque la aplicación se desarrolla como un MVP, la arquitectura permite incorporar nuevas funcionalidades sin necesidad de realizar cambios estructurales significativos.

### Nuevos Deportes

El modelo puede extenderse para soportar otras disciplinas deportivas mediante la incorporación de una entidad que represente el deporte y la adaptación de las reglas de puntaje.

---

### Temporadas

Los torneos podrían agruparse en temporadas, permitiendo mantener el historial de competencias y estadísticas entre distintos años.

---

### Estadísticas

Podrían incorporarse funcionalidades como:

* porcentaje de aciertos;
* mejor racha de pronósticos;
* ranking histórico;
* cantidad de resultados exactos;
* evolución del puntaje por fecha.

La estructura actual favorece este tipo de consultas.

---

### Notificaciones

La aplicación podría integrar notificaciones por correo electrónico o push para informar a los usuarios sobre:

* inicio de nuevos torneos;
* cierre del período de pronósticos;
* publicación de resultados oficiales.

---

### Tiempo Real

La incorporación de Supabase Realtime permitiría actualizar automáticamente:

* resultados oficiales;
* tablas de posiciones;
* puntajes de los participantes.

De esta manera se eliminaría la necesidad de recargar manualmente la interfaz.

---

## Buenas prácticas

El desarrollo seguirá un conjunto de lineamientos destinados a mantener un código consistente y fácil de mantener.

### TypeScript Estricto

Se utilizará el modo estricto de TypeScript para reducir errores en tiempo de compilación y facilitar las refactorizaciones.

---

### Separación de Responsabilidades

Cada módulo tendrá una responsabilidad claramente definida.

* los componentes renderizan información;
* las Server Actions coordinan operaciones;
* los servicios encapsulan lógica reutilizable;
* la base de datos almacena el estado de la aplicación.

---

### Componentes Reutilizables

Los componentes compartidos se ubicarán en una carpeta común para evitar duplicación de código y promover una interfaz consistente.

---

### Manejo de Errores

Las operaciones críticas deberán manejar errores de forma controlada.

Los mensajes presentados al usuario serán claros y evitarán exponer detalles internos del sistema.

Los errores inesperados podrán registrarse para facilitar su análisis y resolución.

---

### Variables de Entorno

Las credenciales y configuraciones sensibles se almacenarán mediante variables de entorno.

No se incluirán secretos directamente en el código fuente.

---

### Validaciones

Las validaciones se implementarán en dos niveles:

* cliente, para mejorar la experiencia del usuario;
* servidor, para garantizar el cumplimiento de las reglas del negocio.

---

### Convenciones de Nombres

Se adoptarán convenciones consistentes en todo el proyecto.

Reglas adoptadas:

* Variables, funciones y métodos: `camelCase`.
* Booleanos: `camelCase` con prefijos semánticos como `is`, `has`, `can` o `should`.
* Componentes, clases, tipos, interfaces y enums de TypeScript: `PascalCase`.
* Hooks: `camelCase` con prefijo `use`.
* Constantes globales y variables de entorno: `UPPER_SNAKE_CASE`.
* Archivos de componentes React: `PascalCase.tsx`.
* Otros archivos y carpetas propias: `kebab-case`.
* Archivos especiales de Next.js: la convención exigida por el framework, por ejemplo `page.tsx`, `layout.tsx` y `route.ts`.
* Segmentos de URL: palabras inglesas en `kebab-case`.
* Tablas y columnas de PostgreSQL: `snake_case`; las tablas utilizarán sustantivos plurales.
* Claves primarias: `id`; claves foráneas: `<entity>_id`.
* Valores de roles y estados persistidos: `UPPER_SNAKE_CASE`.
* Migraciones: `<timestamp>_<description_in_snake_case>.sql`.
* Server Actions: verbo y objeto en `camelCase`, por ejemplo `createTournament`.

La consistencia en la nomenclatura facilita la comprensión y el mantenimiento del código.

---

### Idioma del Código

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

La documentación funcional, los textos visibles de la interfaz y los mensajes destinados al usuario podrán redactarse en español, pero cualquier elemento que forme parte del código o del modelo de datos utilizará nomenclatura en inglés.

Esta decisión favorece la consistencia del proyecto, facilita la incorporación de nuevas herramientas y simplifica la colaboración con desarrolladores de distintos entornos.

## Architecture Decision Records (ADR simplificados)

### ADR-001: Uso de Next.js como Framework Full Stack

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

### ADR-002: Uso de Supabase como Backend as a Service

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

### ADR-003: Uso de Server Actions para la Lógica de Negocio

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

### ADR-004: Arquitectura Basada en Features

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

### ADR-005: No Implementar un Backend Independiente

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

### ADR-006: Llaves de Eliminación Directa Generadas por el Sistema

**Decisión**

Limitar los torneos del MVP a 4, 8, 16 o 32 equipos y generar una llave de eliminación directa mediante un único sorteo aleatorio ejecutado en el servidor. Los ganadores avanzarán automáticamente y los empates se resolverán por penales.

**Ventajas**

* No requiere equipos libres ni reglas configurables de clasificación.
* Permite generar de antemano una estructura completa de `N-1` partidos.
* Evita que el administrador elija cruces favorables.
* Mantiene la progresión y el campeón como datos derivados de resultados oficiales.
* Permite pronosticar partidos eliminatorios con una regla uniforme.

**Desventajas**

* Aumenta el modelo con inscripciones, fases y dependencias entre partidos.
* Exige transacciones para sortear y propagar ganadores de forma segura.
* No soporta grupos, equipos libres, cabezas de serie, ida y vuelta ni tercer puesto.
* Los partidos posteriores no pueden pronosticarse hasta conocer ambos equipos y su horario.

---

### ADR-007: Funciones PostgreSQL como Fronteras Transaccionales

**Decisión**

Implementar `publish_match_result` y `generate_bracket` como funciones PostgreSQL invocadas desde Server Actions mediante Supabase RPC. La primera persistirá el resultado, actualizará puntajes y avanzará al ganador en una única transacción. La segunda generará toda la llave atómicamente.

**Ventajas**

* Garantiza rollback completo ante cualquier error.
* Evita estados parciales entre resultado, puntajes y llave.
* Permite bloquear filas con `SELECT ... FOR UPDATE` y controlar concurrencia.
* No requiere una conexión PostgreSQL directa adicional ni otro backend.
* Mantiene RLS utilizando `SECURITY INVOKER` y el JWT autenticado.

**Desventajas**

* Parte de la lógica crítica se implementa en PL/pgSQL y no en TypeScript.
* Requiere pruebas específicas de migraciones y funciones de base de datos.
* Aumenta el acoplamiento con PostgreSQL y Supabase RPC.
* Los cambios de puntuación deben versionarse cuidadosamente para mantener una única fuente de verdad.

---

### ADR-008: Imágenes de Equipos en Supabase Storage

**Decisión**

Almacenar los escudos o banderas de equipos en un bucket público `team-logos` de Supabase Storage. PostgreSQL conservará únicamente la ruta del objeto en `teams.logo_path`.

**Ventajas**

* Evita guardar datos binarios dentro de PostgreSQL.
* Mantiene las rutas independientes de las URLs de desarrollo y producción.
* Permite mostrar imágenes en pantallas públicas sin generar URLs firmadas.
* Centraliza archivos, límites y tipos MIME dentro de la infraestructura ya elegida.

**Desventajas**

* Requiere políticas RLS adicionales sobre `storage.objects`.
* Las operaciones de base de datos y Storage no comparten una única transacción, por lo que los servicios deberán limpiar archivos si una operación posterior falla.
* El bucket público permite acceder a una imagen conociendo su URL, una concesión aceptable para recursos visuales no sensibles.

---

