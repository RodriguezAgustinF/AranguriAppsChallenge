# Plan de entrega — 1 de julio de 2026

Este documento prioriza una demostración administrativa funcional para la entrega. No reemplaza ni elimina el alcance final descrito en `alcance-funcional.md` y `lista-de-tareas.md`; las funciones pospuestas se retomarán después.

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
- [ ] Preparar datos de demostración y ejecutar el flujo completo.

## Pospuesto después de la entrega

- registro público de usuarios;
- pronósticos y participación;
- cálculo de puntos y ranking;
- experiencia completa del usuario común;
- recuperación de contraseña, que continúa fuera del MVP final.

## Criterio de aceptación

La entrega está lista cuando una cuenta `ADMIN` puede crear equipos y un torneo, inscribir participantes, generar la llave, programar encuentros y publicar resultados hasta que la vista pública muestre al campeón, sin editar manualmente cruces ni ganadores.
