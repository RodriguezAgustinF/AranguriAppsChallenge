# Gestor de Torneos de Fútbol

Aplicación web para crear, administrar y consultar torneos de fútbol por eliminación directa. La entrega actual está enfocada en la gestión completa del torneo; su evolución planificada es convertirse en un Prode con pronósticos y rankings.

## Funcionalidades disponibles

### Administración

- Inicio y cierre de sesión con una cuenta administradora.
- Creación, edición y eliminación de equipos con escudo o bandera.
- Creación, edición y eliminación de torneos antes de su inicio.
- Torneos de 4, 8, 16 o 32 equipos.
- Inscripción y eliminación de equipos antes del sorteo.
- Sorteo aleatorio y generación de una llave de eliminación directa.
- Programación y reprogramación de partidos.
- Publicación de resultados oficiales, incluyendo definición por penales.
- Avance automático de los ganadores hasta obtener un campeón.

Las cuentas administradoras no se registran desde la aplicación: deben crearse manualmente en Supabase Auth y tener el rol `ADMIN` en `public.profiles`.

### Vista pública

- Listado de torneos.
- Estado de cada competencia: próxima, en juego o finalizada.
- Visualización de la llave completa, partidos y resultados.
- Consulta del ganador por penales y del campeón del torneo.

## Reglas principales

- La llave se genera una sola vez y sus cruces no pueden editarse manualmente.
- Un resultado solamente puede publicarse después del inicio del partido.
- Los resultados oficiales son definitivos.
- Si el marcador termina empatado, se debe indicar el ganador por penales.
- El ganador avanza automáticamente al partido correspondiente de la fase siguiente.

## Tecnologías

- Next.js 16 con App Router y Server Actions.
- React 19 y TypeScript.
- Supabase Auth, PostgreSQL, Row Level Security y Storage.
- Vercel para el despliegue de la aplicación.

## Ejecución local

### Requisitos

- Node.js 24.18.x.
- npm 11.16.x.
- Docker Desktop.

### Instalación

```powershell
npm install
npx supabase start
npm run db:reset
```

Creá un archivo `.env.local` tomando `.env.example` como referencia y completá las variables con los valores del entorno local mostrados por `npx supabase status`:

```text
NEXT_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=<publishable-key-local>
NEXT_PUBLIC_SITE_URL=http://localhost:3000
```

Después iniciá la aplicación:

```powershell
npm run dev
```

Abrí [http://localhost:3000](http://localhost:3000).

## Seguridad y calidad

Las operaciones administrativas verifican autenticación y rol en el servidor. La base de datos aplica políticas RLS, restricciones de integridad y funciones transaccionales para proteger el sorteo, el avance de ganadores y los resultados oficiales.

Controles de la aplicación:

```powershell
npm run check
```

Prueba del flujo completo de la entrega:

```powershell
npm run db:start
npm run db:test:delivery
```

Para ejecutar todas las pruebas de base de datos:

```powershell
npm run db:test
```

## Evolución futura: Prode

La arquitectura y el modelo de datos contemplan continuar el proyecto con:

- registro e inicio de sesión de usuarios comunes;
- pronósticos antes del comienzo de cada partido;
- participación automática al guardar el primer pronóstico de un torneo;
- cálculo de puntos según la precisión del resultado;
- ranking independiente por torneo;
- panel personal con pronósticos y puntajes.

La recuperación de contraseña, fases de grupos, partidos de ida y vuelta y cantidades de equipos distintas de 4, 8, 16 o 32 permanecen fuera del alcance previsto.

## Documentación

- [Plan de la entrega actual](./docs/plan-de-entrega.md)
- [Guía de demostración](./docs/guia-de-demostracion.md)
- [Alcance funcional completo](./docs/alcance-funcional.md)
- [Arquitectura](./docs/arquitectura.md)
- [Datos y seguridad](./docs/datos-y-seguridad.md)
- [Lista de tareas](./docs/lista-de-tareas.md)
- [Registro de decisiones](./docs/registro-de-decisiones.md)

## Flujo Git

- `main`: versiones estables y listas para desplegar.
- `develop`: integración de la próxima versión.
- `feat/*`, `fix/*`, `hotfix/*`, `chore/*`, `docs/*` y `test/*`: ramas de trabajo cortas.

Las funcionalidades habituales parten de `develop`. Los hotfix urgentes parten de `main` y, después de publicarse, deben incorporarse también en `develop`.
