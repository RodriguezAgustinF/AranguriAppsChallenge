# Prode de Fútbol

Aplicación web para organizar torneos de eliminación directa y competir mediante pronósticos de resultados.

## Requisitos

- Node.js 24.18.x
- npm 11.16.x

## Desarrollo local

```powershell
npm install
npm run dev
```

Abrir [http://localhost:3000](http://localhost:3000).

## Controles de calidad

```powershell
npm run lint
npm run typecheck
npm run format:check
npm run build
```

Para ejecutar todos los controles:

```powershell
npm run check
```

## Documentación

- [Arquitectura](./docs/arquitectura.md)
- [Alcance funcional](./docs/alcance-funcional.md)
- [Lista de tareas](./docs/lista-de-tareas.md)
- [Registro de decisiones](./docs/registro-de-decisiones.md)

## Flujo Git

- `main`: versiones estables y listas para desplegar.
- `develop`: integración de trabajo aprobado para la próxima versión.
- `feat/*`, `fix/*`, `chore/*`, `docs/*` y `test/*`: ramas cortas creadas desde `develop`.

Las ramas de trabajo vuelven a `develop` mediante pull request. Cuando una versión está validada, `develop` se integra en `main` mediante otro pull request.
