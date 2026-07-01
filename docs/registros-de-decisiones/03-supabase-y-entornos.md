# Registro de decisiones — 03. Supabase y entornos

[Volver al índice de registros](../registro-de-decisiones.md)

## 2026-06-29 — Estrategia de proyectos remotos

### Tarea

Crear los proyectos de Supabase para desarrollo y producción.

### Estado

Completada el 29 de junio de 2026 por el propietario desde el Dashboard de Supabase.

### Decisiones

- Se utilizan dos proyectos Supabase independientes:
  - `AranguriAppsChallengeDev`, asociado al trabajo integrado en `develop`, creado en `us-east-1`;
  - `AranguriAppsChallengeProd`, reservado para despliegues provenientes de `main`, creado en `us-west-2`.
- Se conservaron las regiones recomendadas por el Dashboard durante la creación. Los proyectos no se comunican entre sí, por lo que utilizar regiones diferentes no afecta la consistencia funcional; puede existir una diferencia de latencia entre entornos.
- Inicialmente se utilizará el plan Free. Supabase permite dos proyectos gratuitos activos, suficiente para separar desarrollo y producción durante el MVP.
- Los proyectos gratuitos pueden pausarse después de una semana de inactividad; esto se acepta para desarrollo y deberá reevaluarse antes de considerar producción estable.
- Los esquemas se mantendrán sincronizados mediante migraciones versionadas, nunca mediante cambios manuales no documentados en producción.
- No se copiarán datos reales de producción al entorno de desarrollo.
- No se utilizará Supabase Branching porque no forma parte del plan Free y no es necesario para el MVP.

### Credenciales

- La contraseña de base de datos se guardará únicamente en un gestor de contraseñas y no se compartirá por chat ni se incluirá en Git.
- Las variables reales se almacenarán en `.env.local`, ignorado por Git.
- El repositorio solo conservará nombres de variables vacíos en `.env.example`.
- La aplicación cliente usará la URL del proyecto y la publishable key correspondiente al entorno.
- No se agregará una `service_role` al frontend ni al archivo de ejemplo.

## Configuración de variables de entorno

### Tarea

Configurar las variables locales necesarias para conectar la aplicación con el proyecto de desarrollo.

### Estado

Completada el 29 de junio de 2026.

### Decisiones

- `.env.local` contiene la URL y la publishable key de `AranguriAppsChallengeDev`, además de `NEXT_PUBLIC_SITE_URL=http://localhost:3000`.
- `.env.example` conserva las mismas variables sin valores reales para documentar el contrato de configuración del proyecto.
- Las variables llevan el prefijo `NEXT_PUBLIC_` porque la URL y la publishable key están diseñadas para utilizarse desde el navegador; la autorización efectiva dependerá de las políticas RLS y no del secreto de esta clave.
- No se almacenarán la contraseña de la base de datos ni una clave `service_role` en variables accesibles al navegador.
- Se verificó que `.env.local` permanece ignorado por Git.

### Verificación

- Se comprobó la presencia y el formato esperado de las tres variables sin mostrar sus valores.
- Se consultó el endpoint de configuración de Supabase Auth con la URL y la publishable key de desarrollo; respondió correctamente con HTTP 200.

## Clientes Supabase para navegador y servidor

### Tarea

Configurar clientes de Supabase compatibles con los dos entornos de ejecución de Next.js.

### Estado

Completada el 29 de junio de 2026.

### Decisiones

- Se instalaron `@supabase/supabase-js` 2.108.2 y `@supabase/ssr` 0.12.0, las versiones fijadas durante las definiciones iniciales.
- `src/lib/supabase/client.ts` crea el cliente del navegador mediante `createBrowserClient` y está marcado como `client-only` para impedir su uso accidental desde módulos de servidor.
- `src/lib/supabase/server.ts` crea un cliente nuevo por solicitud mediante `createServerClient`; no se comparte una instancia global entre usuarios.
- El cliente de servidor espera `cookies()` porque en Next.js 16 esta API es asíncrona.
- El adaptador usa `getAll` y `setAll`, en lugar de los métodos individuales obsoletos de `@supabase/ssr`.
- La escritura de cookies se tolera como una operación no disponible durante el render de un Server Component. La renovación efectiva se incorporará en el proxy al realizar la siguiente tarea de sesiones.
- La lectura y validación de las variables públicas se centralizó en `src/lib/supabase/config.ts`, con acceso estático a `process.env` para que Next.js pueda incluirlas correctamente en el bundle del navegador.
- Los dos clientes usan exclusivamente la publishable key. La seguridad de los datos se implementará posteriormente mediante RLS.

### Verificación

- Se ejecutaron lint, comprobación de tipos, formato y build de producción.

## Migraciones y tipos TypeScript

### Tarea

Preparar el flujo versionado de migraciones y generación de tipos de base de datos.

### Estado

Completada el 29 de junio de 2026.

### Decisiones

- Se instaló el CLI estable de Supabase 2.108.0 como dependencia de desarrollo exacta para que todos los colaboradores y CI utilicen la misma versión.
- `supabase init` creó `supabase/config.toml`; esta carpeta se versionará porque describe el entorno local y alojará migraciones y datos semilla.
- Las migraciones se crearán con `npm run db:migration:new -- <description>` y se almacenarán en `supabase/migrations` con el timestamp generado por el CLI.
- `supabase/seed.sql` será el punto de entrada versionado para datos de desarrollo. Por ahora permanece sin datos porque el esquema se construirá en la fase 4.
- Se agregaron comandos para iniciar, detener, reiniciar y validar la base local. Iniciar el stack local será opcional y requerirá Docker Desktop; no es necesario para ejecutar la interfaz contra el proyecto remoto de desarrollo.
- Los tipos se generan desde el proyecto remoto vinculado con `npm run db:types` o desde la base local con `npm run db:types:local`.
- `scripts/generate-database-types.mjs` captura la salida del CLI y reemplaza `src/types/database.types.ts` solamente cuando la generación finaliza y contiene un tipo `Database` válido. Esto evita truncar el archivo si falla la conexión.
- Se versionará el archivo generado para que el build y el editor no dependan de una base disponible. Mientras el esquema está vacío se conserva una definición inicial compatible, que será reemplazada después de cada cambio de migración.
- Los clientes de navegador, servidor y proxy ahora reciben el genérico `Database`, habilitando inferencia de tablas, funciones y relaciones cuando se genere el esquema real.
- La configuración local de Auth usa `http://localhost:3000`, igual que `NEXT_PUBLIC_SITE_URL`.

### Flujo acordado

1. Crear una migración con `npm run db:migration:new -- <description>`.
2. Escribir y revisar el SQL generado.
3. Aplicar y probar localmente con `npm run db:reset`, si Docker está disponible.
4. Ejecutar `npm run db:lint`.
5. Regenerar tipos con `npm run db:types:local` o, después de aplicar la migración al proyecto de desarrollo vinculado, con `npm run db:types`.
6. Incluir la migración y el archivo de tipos actualizado en el mismo commit.

### Verificación

- Se comprobó la versión instalada del CLI y la disponibilidad de los comandos de migraciones y generación de tipos.
- Se ejecutaron lint, comprobación de tipos, formato y build de producción.
- No se inició ni validó una base local: todavía no existen migraciones de dominio y el stack requiere Docker. Los comandos que dependen de PostgreSQL local se probarán desde la fase 4.

## Sesiones compatibles con Next.js

### Tarea

Configurar la propagación y renovación de sesiones de Supabase Auth entre el navegador y el servidor.

### Estado

Completada el 29 de junio de 2026.

### Decisiones

- Se creó `src/proxy.ts`, la convención vigente en Next.js 16 que reemplaza al archivo `middleware.ts`.
- El proxy delega en `src/lib/supabase/proxy.ts` para mantener aislada y reutilizable la adaptación de cookies de Supabase.
- En cada solicitud aplicable se llama a `auth.getClaims()`. Este método valida el token y provoca su renovación cuando corresponde; no se confía en `getSession()` para tomar decisiones de seguridad en el servidor.
- Las cookies renovadas se copian tanto a la solicitud que continúa hacia los Server Components como a la respuesta que vuelve al navegador. Esto mantiene consistente la sesión durante la solicitud actual y las siguientes.
- El matcher cubre páginas, Route Handlers y Server Functions, pero omite recursos internos de Next.js e imágenes estáticas para evitar trabajo de autenticación innecesario.
- El proxy solo mantiene la sesión. La protección de rutas y la autorización por rol se implementarán en la fase de autenticación y también se verificarán dentro de cada operación sensible; no se considerará al proxy una frontera de autorización suficiente.

### Verificación

- Se ejecutaron lint, comprobación de tipos, formato y build de producción.

### Intervención requerida del propietario

Los dos proyectos fueron creados manualmente desde el Dashboard. La acción no se automatizó porque requería sesión personal, elección de organización, aceptación del plan y custodia de la contraseña de base de datos.

### Rectificación de la propuesta inicial

La propuesta inicial sugería nombres en `kebab-case` y la región São Paulo. El propietario utilizó los nombres mostrados arriba y aceptó las regiones recomendadas por Supabase. Los nombres de proyectos son metadatos externos y no están sujetos a las convenciones del código. No se recrearán los proyectos únicamente para cambiar nombres o regiones.

### Fuentes consultadas

- [Gestión de entornos en Supabase](https://supabase.com/docs/guides/deployment/managing-environments)
- [Regiones disponibles](https://supabase.com/docs/guides/platform/regions)
- [Facturación y límite de proyectos gratuitos](https://supabase.com/docs/guides/platform/billing-on-supabase)
