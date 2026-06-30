# Registro de decisiones — 06. Autenticación y autorización

[Volver al índice de registros](../registro-de-decisiones.md)

## 2026-06-30 — Acceso administrativo para la entrega

### Contexto

El plan de entrega prioriza un flujo administrativo completo. La cuenta `ADMIN` se aprovisiona manualmente y necesita iniciar sesión, conservarla entre solicitudes y cerrar sesión desde la aplicación.

### Decisiones

- El login usa una Server Action y `supabase.auth.signInWithPassword`; las credenciales no pasan por un Client Component ni se almacenan en código propio.
- Después de autenticar, la acción invoca `is_admin()`. Una identidad válida con perfil `USER` cierra sesión inmediatamente y recibe un mensaje de acceso denegado.
- `getAdminSession()` valida la identidad mediante `supabase.auth.getUser()` y vuelve a consultar el rol con RLS. No confía solamente en la presencia de cookies.
- El layout de `/admin` ejecuta `requireAdmin()` desde el servidor. Proxy continúa refrescando sesiones, pero no reemplaza esta verificación de autorización cercana a los datos.
- El cierre de sesión también es una Server Action y redirige a `/login` después de eliminar la sesión de Supabase.
- No se implementa registro público en el camino crítico de la entrega. Las cuentas administrativas siguen creándose manualmente.
- Se consultaron las guías locales de Next.js 16 para autenticación, formularios, cookies, `redirect` y Proxy antes de escribir el código.

### Verificación

- Lint, TypeScript, formato y build de producción finalizaron correctamente.
- Next.js confirmó `/login` y `/admin` como rutas dinámicas renderizadas por solicitud.
- La prueba manual en navegador queda pendiente de aprovisionar una cuenta `ADMIN` en el proyecto Supabase de desarrollo.
