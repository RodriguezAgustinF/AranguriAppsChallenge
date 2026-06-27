# Lista de tareas del proyecto

Backlog ordenado desde el inicio para construir el MVP definido en `alcance-funcional.md` y `arquitectura.md`.

## 1. Definiciones iniciales

- [ ] Confirmar versiones de Node.js, Next.js y dependencias principales.
- [ ] Adoptar nombres en inglés para código, tablas, columnas y migraciones.
- [ ] Definir estados válidos de torneos y partidos y sus transiciones.
- [ ] Definir validaciones de fechas y zona horaria del sistema.
- [ ] Definir el criterio de desempate del ranking.
- [ ] Definir el mecanismo administrativo para mantener equipos.
- [ ] Definir la estrategia transaccional para publicar resultados y actualizar puntajes atómicamente.
- [ ] Registrar mediante ADR cualquier cambio de arquitectura.

## 2. Inicialización

- [ ] Crear la aplicación con Next.js, App Router y TypeScript estricto.
- [ ] Configurar Tailwind CSS, ESLint y formateo.
- [ ] Crear la estructura `app`, `actions`, `components`, `features`, `hooks`, `lib`, `services`, `types` y `utils`.
- [ ] Configurar alias de importación.
- [ ] Crear `.env.example` sin secretos.
- [ ] Configurar scripts de desarrollo, lint, type-check, pruebas y build.
- [ ] Verificar ejecución local y build inicial.

## 3. Supabase y entornos

- [ ] Crear proyectos Supabase de desarrollo y producción.
- [ ] Configurar variables de entorno.
- [ ] Configurar clientes Supabase para navegador y servidor.
- [ ] Configurar sesiones compatibles con Next.js.
- [ ] Preparar migraciones y generación de tipos TypeScript.

## 4. Base de datos

- [ ] Crear el enum de roles `ADMIN` y `USER`.
- [ ] Crear la tabla de perfiles vinculada con Supabase Authentication.
- [ ] Crear tablas de torneos, equipos, partidos, pronósticos y puntajes por torneo.
- [ ] Agregar claves, relaciones e índices.
- [ ] Garantizar un único pronóstico por usuario y partido.
- [ ] Garantizar un único puntaje por usuario y torneo.
- [ ] Impedir equipos iguales en un partido y valores de goles negativos.
- [ ] Validar la coherencia de fechas de torneos y partidos.
- [ ] Definir valores iniciales de roles y estados.
- [ ] Agregar campos de auditoría.
- [ ] Impedir desde PostgreSQL modificar o eliminar resultados oficiales publicados.
- [ ] Crear datos semilla para desarrollo.

## 5. Seguridad y RLS

- [ ] Habilitar RLS en todas las tablas expuestas.
- [ ] Permitir consultar torneos, equipos y partidos disponibles.
- [ ] Permitir que cada usuario consulte sus pronósticos.
- [ ] Permitir crear o editar pronósticos propios solo antes del partido.
- [ ] Impedir escrituras sobre pronósticos ajenos.
- [ ] Permitir consultar rankings.
- [ ] Impedir modificar puntajes directamente desde el cliente.
- [ ] Restringir la administración al rol `ADMIN`.
- [ ] Impedir que el registro público asigne el rol `ADMIN`.
- [ ] Probar RLS con usuarios anónimos, `USER` y `ADMIN`.

## 6. Autenticación y autorización

- [ ] Implementar registro público con rol fijo `USER`.
- [ ] Crear automáticamente el perfil del usuario.
- [ ] Implementar inicio y cierre de sesión.
- [ ] Restaurar y refrescar sesiones.
- [ ] Proteger rutas autenticadas y administrativas.
- [ ] Crear helpers de servidor para obtener el usuario y validar su rol.
- [ ] Documentar el alta manual en Supabase Auth y de su perfil `ADMIN`.
- [ ] Crear una cuenta administrativa de desarrollo.
- [ ] Verificar que el MVP no ofrezca recuperación de contraseña.

## 7. Interfaz base

- [ ] Crear layout y navegación.
- [ ] Crear componentes reutilizables para formularios, botones, tablas y mensajes.
- [ ] Implementar estados de carga, error, éxito y contenido vacío.
- [ ] Crear páginas de acceso denegado y recurso no encontrado.
- [ ] Verificar diseño responsive y navegación por teclado.

## 8. Torneos

- [ ] Crear tipos y validadores.
- [ ] Implementar Server Actions para crear, listar y consultar torneos.
- [ ] Implementar edición y eliminación solo antes del inicio.
- [ ] Crear pantallas administrativas de listado, alta, edición y detalle.
- [ ] Probar intentos de modificación posteriores al inicio.

## 9. Equipos

- [ ] Crear tipos y validadores.
- [ ] Implementar el mecanismo administrativo definido para crear y consultar equipos.
- [ ] Evitar duplicados según el criterio acordado.
- [ ] Crear el selector de equipos para partidos.

## 10. Partidos

- [ ] Crear tipos y validadores.
- [ ] Implementar creación de partidos dentro de un torneo.
- [ ] Validar equipos, fecha, hora y pertenencia al torneo.
- [ ] Implementar edición y eliminación solo antes del inicio.
- [ ] Implementar consulta por torneo.
- [ ] Crear pantallas administrativas de alta, edición y listado.
- [ ] Probar las restricciones usando siempre la hora del servidor.

## 11. Consulta para usuarios

- [ ] Crear listado y detalle de torneos disponibles.
- [ ] Mostrar partidos ordenados por fecha y hora.
- [ ] Indicar si admiten pronósticos, están iniciados o finalizados.
- [ ] Mostrar el pronóstico existente del usuario.

## 12. Pronósticos y participación

- [ ] Crear tipos y validadores.
- [ ] Implementar alta y edición de pronósticos.
- [ ] Validar usuario, propiedad, partido y goles no negativos.
- [ ] Comparar la fecha del partido con la hora del servidor.
- [ ] Bloquear cualquier escritura después del inicio.
- [ ] Crear Puntaje por Torneo con cero puntos al guardar el primer pronóstico del usuario.
- [ ] Hacer idempotente la creación de la participación.
- [ ] Crear el formulario y sus estados de edición y bloqueo.
- [ ] Probar concurrencia y unicidad por usuario y partido.

## 13. Resultados y puntuación

- [ ] Implementar una función pura de cálculo de puntos.
- [ ] Otorgar 0 puntos al fallar el ganador o empate.
- [ ] Otorgar 3 puntos al acertar ganador o empate sin marcador exacto.
- [ ] Otorgar 6 puntos al acertar el marcador exacto.
- [ ] Crear pruebas unitarias para todos los casos.
- [ ] Implementar la publicación administrativa del resultado de un partido finalizado.
- [ ] Verificar que no exista un resultado previo.
- [ ] Publicar el resultado y actualizar puntajes en una operación atómica.
- [ ] Impedir modificaciones o eliminaciones posteriores desde servidor, RLS y PostgreSQL.
- [ ] Crear una confirmación explícita de que el resultado será definitivo.
- [ ] Probar publicaciones repetidas y simultáneas.

## 14. Ranking

- [ ] Implementar la consulta por torneo.
- [ ] Aplicar el criterio de desempate definido.
- [ ] Incluir participantes con cero puntos.
- [ ] Mostrar el puntaje del usuario y la tabla de posiciones.
- [ ] Verificar independencia entre torneos.
- [ ] Verificar que los totales coincidan con los pronósticos puntuados.

## 15. Errores y rendimiento

- [ ] Normalizar respuestas de Server Actions.
- [ ] Evitar exponer secretos o detalles internos.
- [ ] Registrar errores inesperados.
- [ ] Añadir índices para consultas frecuentes.
- [ ] Configurar caché y revalidación después de mutaciones.
- [ ] Añadir límites básicos contra abuso cuando corresponda.

## 16. Pruebas y calidad

- [ ] Configurar pruebas unitarias, de integración y end-to-end.
- [ ] Probar validadores, reglas de dominio y puntuación.
- [ ] Probar permisos de todas las Server Actions.
- [ ] Probar restricciones y políticas RLS mediante acceso directo.
- [ ] Probar límites temporales.
- [ ] Probar registro, inicio y cierre de sesión.
- [ ] Probar el flujo de usuario: consultar, pronosticar y ver puntaje.
- [ ] Probar el flujo administrador: crear torneo, partido y publicar resultado.
- [ ] Ejecutar lint, type-check, pruebas y build.
- [ ] Revisar accesibilidad y diseño responsive.

## 17. CI y despliegue

- [ ] Configurar CI con lint, type-check, pruebas y build.
- [ ] Vincular GitHub con Vercel.
- [ ] Configurar variables de producción.
- [ ] Aplicar migraciones en Supabase de producción.
- [ ] Configurar URLs de autenticación.
- [ ] Crear manualmente la primera cuenta `ADMIN` de producción.
- [ ] Ejecutar pruebas de humo.
- [ ] Verificar HTTPS, sesiones, permisos y RLS en producción.

## 18. Cierre del MVP

- [ ] Actualizar el README con instalación, configuración, migraciones, pruebas y despliegue.
- [ ] Documentar el aprovisionamiento de administradores y la publicación de resultados.
- [ ] Revisar todas las funcionalidades contra el alcance.
- [ ] Confirmar que no se incorporaron funciones fuera del MVP.
- [ ] Preparar datos de demostración.
- [ ] Completar una prueba de aceptación con roles `USER` y `ADMIN`.
- [ ] Etiquetar y publicar la primera versión.

## Definición de terminado

Una tarea se considera terminada cuando:

- cumple el alcance funcional;
- valida datos y permisos en el servidor;
- respeta RLS y las restricciones de PostgreSQL;
- incluye pruebas proporcionales al riesgo;
- supera lint, type-check y build;
- maneja carga, éxito y error cuando posee interfaz;
- no introduce secretos ni problemas de seguridad conocidos;
- actualiza la documentación si cambia una decisión o comportamiento.
