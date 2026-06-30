# Lista de tareas del proyecto

Backlog ordenado desde el inicio para construir el MVP definido en `alcance-funcional.md` y en la documentación enlazada desde `arquitectura.md`.

## 1. Definiciones iniciales

- [x] Confirmar versiones de Node.js, Next.js y dependencias principales.
- [x] Adoptar nombres en inglés para código, tablas, columnas y migraciones.
- [x] Definir estados válidos de torneos y partidos y sus transiciones.
- [x] Definir validaciones de fechas y zona horaria del sistema.
- [x] Definir el criterio de desempate del ranking.
- [x] Definir el mecanismo administrativo para mantener equipos.
- [x] Definir el formato de eliminación directa, sorteo, avance automático y penales.
- [x] Definir la estrategia transaccional para publicar resultados y actualizar puntajes atómicamente.
- [x] Registrar mediante ADR cualquier cambio de arquitectura.

## 2. Inicialización

- [x] Crear la aplicación con Next.js, App Router y TypeScript estricto.
- [x] Configurar Tailwind CSS, ESLint y formateo.
- [x] Crear la estructura `app`, `actions`, `components`, `features`, `hooks`, `lib`, `services`, `types` y `utils`.
- [x] Configurar alias de importación.
- [x] Crear `.env.example` sin secretos.
- [x] Configurar scripts de desarrollo, lint, type-check, pruebas y build.
- [x] Verificar ejecución local y build inicial.

## 3. Supabase y entornos

- [x] Crear proyectos Supabase de desarrollo y producción.
- [x] Configurar variables de entorno.
- [x] Configurar clientes Supabase para navegador y servidor.
- [x] Configurar sesiones compatibles con Next.js.
- [x] Preparar migraciones y generación de tipos TypeScript.

## 4. Base de datos

- [x] Crear el enum de roles `ADMIN` y `USER`.
- [x] Crear la tabla de perfiles vinculada con Supabase Authentication.
- [x] Crear tablas de torneos, equipos, equipos por torneo, fases, partidos, pronósticos y puntajes por torneo.
- [x] Crear el almacenamiento y la referencia para escudos o banderas de equipos.
- [x] Restringir `team_count` a 4, 8, 16 o 32.
- [x] Garantizar inscripciones y posiciones de sorteo únicas por torneo.
- [x] Modelar dependencias entre partidos y posiciones únicas dentro de cada fase.
- [x] Validar torneo, fase anterior y uso único de los partidos fuente de cada cruce.
- [x] Agregar claves, relaciones e índices.
- [x] Garantizar un único pronóstico por usuario y partido.
- [x] Garantizar un único puntaje por usuario y torneo.
- [x] Impedir equipos iguales en un partido y valores de goles negativos.
- [x] Exigir que los dos marcadores oficiales sean ambos nulos o ambos no nulos.
- [x] Validar que, al generar la llave, los partidos iniciales tengan equipos sin fuentes y los posteriores fuentes con equipos aún nulos.
- [x] Validar la coherencia condicional de `penalty_winner_team_id` en resultados y pronósticos.
- [x] Impedir cambios en inscripciones, fases y cruces después de generar la llave.
- [x] Validar la coherencia de fechas de torneos y partidos.
- [x] Derivar `FINISHED` del resultado de la final y detectar torneos atrasados después de `ends_at`.
- [x] Definir valores iniciales de roles y estados.
- [x] Agregar campos de auditoría.
- [x] Impedir desde PostgreSQL modificar o eliminar resultados oficiales publicados.
- [x] Crear datos semilla para desarrollo.

## 5. Seguridad y RLS

- [ ] Habilitar RLS en todas las tablas expuestas.
- [ ] Permitir consultar torneos, equipos y partidos disponibles.
- [ ] Permitir que cada usuario consulte sus pronósticos.
- [ ] Permitir crear o editar pronósticos propios solo antes del partido.
- [ ] Impedir escrituras sobre pronósticos ajenos.
- [ ] Permitir consultar rankings.
- [ ] Impedir modificar puntajes directamente desde el cliente.
- [ ] Restringir la administración al rol `ADMIN`.
- [ ] Permitir lectura pública y restringir a `ADMIN` las escrituras del bucket `team-logos`.
- [ ] Impedir que el cliente genere nuevamente la llave o elija participantes de partidos posteriores.
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
- [ ] Impedir eliminar torneos que ya posean pronósticos.
- [ ] Validar capacidades de 4, 8, 16 o 32 equipos.
- [ ] Crear pantallas administrativas de listado, alta, edición y detalle.
- [ ] Probar intentos de modificación posteriores al inicio.

## 9. Equipos

- [ ] Crear tipos y validadores.
- [ ] Implementar el mecanismo administrativo definido para crear y consultar equipos.
- [ ] Implementar carga, reemplazo y eliminación segura de imágenes en Supabase Storage.
- [ ] Evitar duplicados según el criterio acordado.
- [ ] Crear el selector para inscribir equipos en torneos.
- [ ] Impedir eliminar equipos inscriptos o utilizados en partidos.
- [ ] Mostrar escudos o banderas en listados, selectores, partidos y llaves.

## 10. Inscripciones, sorteo y llave

- [ ] Crear tipos y validadores para inscripciones, fases y slots de la llave.
- [ ] Implementar alta y baja de equipos antes del sorteo.
- [ ] Mostrar capacidad, equipos inscriptos y lugares disponibles.
- [ ] Implementar el orden aleatorio dentro de PostgreSQL mediante `gen_random_uuid()`.
- [ ] Generar atómicamente posiciones, fases, partidos y dependencias.
- [ ] Crear exactamente `team_count - 1` partidos.
- [ ] Bloquear capacidad e inscripciones después del sorteo.
- [ ] Impedir regenerar la llave.
- [ ] Crear la visualización administrativa y pública de la llave.
- [ ] Probar sorteos de 4, 8, 16 y 32 equipos, incluyendo concurrencia.

## 11. Partidos

- [ ] Crear tipos y validadores.
- [ ] Implementar programación y reprogramación de partidos generados.
- [ ] Validar fecha, hora, fase y pertenencia al torneo.
- [ ] Impedir crear, eliminar o reemplazar participantes manualmente.
- [ ] Implementar consulta por torneo.
- [ ] Crear pantallas administrativas de programación y listado.
- [ ] Probar las restricciones usando siempre la hora del servidor.

## 12. Consulta para usuarios

- [ ] Crear listado y detalle de torneos disponibles.
- [ ] Mostrar partidos ordenados por fecha y hora.
- [ ] Mostrar fase, llave y participantes aún no resueltos.
- [ ] Indicar si admiten pronósticos, están iniciados o finalizados.
- [ ] Mostrar el pronóstico existente del usuario.

## 13. Pronósticos y participación

- [ ] Crear tipos y validadores.
- [ ] Implementar alta y edición de pronósticos.
- [ ] Validar usuario, propiedad, partido y goles no negativos.
- [ ] Exigir un ganador por penales solo cuando el marcador pronosticado esté empatado.
- [ ] Impedir pronósticos hasta que ambos participantes y la fecha estén definidos.
- [ ] Comparar la fecha del partido con la hora del servidor.
- [ ] Bloquear cualquier escritura después del inicio.
- [ ] Crear Puntaje por Torneo con cero puntos al guardar el primer pronóstico del usuario.
- [ ] Hacer idempotente la creación de la participación.
- [ ] Crear el formulario y sus estados de edición y bloqueo.
- [ ] Probar concurrencia y unicidad por usuario y partido.

## 14. Resultados, avance y puntuación

- [ ] Implementar una función pura de cálculo de puntos.
- [ ] Determinar el equipo que avanza a partir del marcador y los penales.
- [ ] Otorgar 0 puntos al fallar el equipo que avanza.
- [ ] Otorgar 3 puntos al acertar el equipo que avanza sin marcador exacto.
- [ ] Otorgar 6 puntos al acertar el marcador exacto y el ganador por penales cuando corresponda.
- [ ] Crear pruebas unitarias para todos los casos.
- [ ] Implementar la publicación administrativa del resultado de un partido finalizado.
- [ ] Verificar que no exista un resultado previo.
- [ ] Validar el ganador por penales cuando el resultado esté empatado.
- [ ] Publicar el resultado, actualizar puntajes y avanzar al ganador en una operación atómica.
- [ ] Marcar al ganador de la final como campeón.
- [ ] Impedir modificaciones o eliminaciones posteriores desde servidor, RLS y PostgreSQL.
- [ ] Crear una confirmación explícita de que el resultado será definitivo.
- [ ] Probar publicaciones repetidas y simultáneas.

## 15. Ranking

- [ ] Implementar la consulta por torneo.
- [ ] Aplicar el criterio de desempate definido.
- [ ] Incluir participantes con cero puntos.
- [ ] Mostrar el puntaje del usuario y la tabla de posiciones.
- [ ] Verificar independencia entre torneos.
- [ ] Verificar que los totales coincidan con los pronósticos puntuados.

## 16. Errores y rendimiento

- [ ] Normalizar respuestas de Server Actions.
- [ ] Evitar exponer secretos o detalles internos.
- [ ] Registrar errores inesperados.
- [ ] Añadir índices para consultas frecuentes.
- [ ] Configurar caché y revalidación después de mutaciones.
- [ ] Añadir límites básicos contra abuso cuando corresponda.

## 17. Pruebas y calidad

- [ ] Configurar pruebas unitarias, de integración y end-to-end.
- [ ] Probar validadores, reglas de dominio y puntuación.
- [ ] Probar permisos de todas las Server Actions.
- [ ] Probar restricciones y políticas RLS mediante acceso directo.
- [ ] Probar límites temporales.
- [ ] Probar registro, inicio y cierre de sesión.
- [ ] Probar el flujo de usuario: consultar llave, pronosticar con penales y ver puntaje.
- [ ] Probar el flujo administrador: crear torneo, inscribir equipos, sortear, programar y publicar resultados hasta la final.
- [ ] Probar la propagación completa de ganadores en llaves de todos los tamaños.
- [ ] Ejecutar lint, type-check, pruebas y build.
- [ ] Revisar accesibilidad y diseño responsive.

## 18. CI y despliegue

- [ ] Configurar CI con lint, type-check, pruebas y build.
- [ ] Vincular GitHub con Vercel.
- [ ] Configurar variables de producción.
- [ ] Aplicar migraciones en Supabase de producción.
- [ ] Configurar URLs de autenticación.
- [ ] Crear manualmente la primera cuenta `ADMIN` de producción.
- [ ] Ejecutar pruebas de humo.
- [ ] Verificar HTTPS, sesiones, permisos y RLS en producción.

## 19. Cierre del MVP

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
