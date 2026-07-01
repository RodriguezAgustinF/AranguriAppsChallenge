# Plan de entrega — 1 de julio de 2026

Este documento define la versión entregable actual como un **gestor de torneos de eliminación directa**. El Prode descrito en `alcance-funcional.md` y `lista-de-tareas.md` queda como evolución posterior y no forma parte de la presentación de esta versión.

## Objetivo de la entrega

Permitir que un administrador prepare y ejecute un torneo de eliminación directa desde la aplicación, y que cualquier visitante pueda observar su estado y su llave.

## Camino crítico

- [x] Iniciar y cerrar sesión con una cuenta `ADMIN` aprovisionada manualmente.
- [x] Proteger las pantallas y operaciones administrativas.
- [x] Crear, consultar, editar y eliminar equipos con su imagen.
- [x] Crear, consultar, editar y eliminar torneos antes de su inicio.
- [x] Inscribir y quitar equipos antes de generar la llave.
- [x] Generar una única llave aleatoria y completa.
- [x] Programar los partidos generados.
- [x] Publicar resultados oficiales definitivos, incluyendo penales.
- [x] Avanzar automáticamente al ganador hasta obtener un campeón.
- [x] Mostrar una vista pública básica de torneos, partidos y llave.
- [x] Preparar datos de demostración y ejecutar el flujo completo.

La ejecución manual está detallada en [Guía de demostración](./guia-de-demostracion.md). El flujo transaccional completo también se verifica con `npm run db:test:delivery`.

## Evolución futura: Prode

- registro público de usuarios;
- pronósticos y participación;
- cálculo de puntos y ranking;
- experiencia completa del usuario común;
- recuperación de contraseña, que continúa fuera de esta versión.

## Criterio de aceptación

La entrega está lista cuando una cuenta `ADMIN` puede crear equipos y un torneo, inscribir participantes, generar la llave, programar encuentros y publicar resultados hasta que la vista pública muestre al campeón, sin editar manualmente cruces ni ganadores.
