# Guía de demostración de la entrega

Esta guía recorre el camino crítico administrativo sin depender de pronósticos ni del ranking, que continúan pospuestos en el plan de entrega.

## Preparación

1. Aplicar las migraciones del entorno que se utilizará para demostrar.
2. Confirmar que existe una cuenta de Supabase Auth cuyo registro en `public.profiles` tiene `role = 'ADMIN'`.
3. Iniciar la aplicación y acceder a `/login` con esa cuenta.
4. Tener preparadas cuatro imágenes pequeñas para los escudos o banderas.

En desarrollo local, `npm run db:reset` deja cuatro equipos y la **Copa de desarrollo** ya completa en inscripciones. Antes de sortearla, editá su inicio para dejarlo unos minutos por delante de la hora actual; después puede recorrerse directamente el resto del flujo. Los paths de sus imágenes son referencias estables; para mostrar archivos reales se pueden editar esos equipos desde la interfaz y cargar las cuatro imágenes.

## Recorrido recomendado

1. En **Equipos**, mostrar el alta, edición e imagen de un equipo.
2. En **Torneos**, crear una competencia de cuatro equipos. Elegir un inicio unos minutos posterior a la hora actual.
3. Abrir el torneo, inscribir exactamente cuatro equipos y generar la llave.
4. Programar los tres partidos para una hora posterior al inicio del torneo. Para una demostración rápida pueden compartir horario.
5. Abrir `/torneos` en otra pestaña y comprobar que la competencia y la llave son públicas.
6. Al alcanzar el horario, publicar las dos semifinales. Incluir un empate para mostrar la selección obligatoria del ganador por penales.
7. Comprobar que ambos ganadores aparecen automáticamente en la final.
8. Publicar la final y verificar que el resultado queda bloqueado.
9. Actualizar el detalle público y confirmar el estado **Finalizado** y el campeón.

## Comprobaciones automáticas

- `npm run db:test:delivery` ejecuta el flujo de aceptación de cuatro equipos: sorteo, programación, penales, avance, final y campeón público.
- `npm run db:test` ejecuta además todas las restricciones, políticas y reglas de la base de datos.
- `npm run check` ejecuta lint, TypeScript, formato y build de producción.

## Observaciones

- Un resultado solo puede publicarse después del horario de inicio del partido.
- La aplicación no estima cuánto dura un encuentro; el administrador confirma cuándo terminó.
- Los resultados publicados son definitivos y no existe una operación para corregirlos o eliminarlos.
- La semilla local no crea usuarios administrativos porque los administradores se aprovisionan manualmente.
