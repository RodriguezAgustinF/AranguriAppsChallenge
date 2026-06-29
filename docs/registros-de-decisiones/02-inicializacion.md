# Registro de decisiones — 02. Inicialización

[Volver al índice de registros](../registro-de-decisiones.md)

## 2026-06-29 — Creación del scaffold de Next.js

### Tarea

Crear la aplicación con Next.js, App Router y TypeScript estricto.

### Contexto

El repositorio contenía documentación y Git, pero todavía no existía una aplicación. La carpeta raíz se llama `AranguriAppsChallenge`, nombre que no cumple las restricciones de nombres de paquetes npm por contener mayúsculas. Además, ejecutar el generador directamente sobre una carpeta no vacía podía interferir con `docs`.

### Decisiones

- Se utilizó `create-next-app@16.2.9`, alineado con la versión de Next.js aprobada.
- El scaffold se generó sin instalar dependencias dentro de una carpeta temporal del workspace y luego se trasladaron sus archivos a la raíz.
- La carpeta temporal fue eliminada después de verificar que no existían conflictos de nombres.
- El paquete se llama `football-prediction-app`, en inglés y compatible con npm.
- Se habilitaron App Router, directorio `src`, TypeScript, modo estricto, Tailwind CSS, ESLint y alias `@/*`.
- Se utilizó npm como único gestor y `package-lock.json` como lockfile.
- Se declararon Node.js `24.18.x` y npm `11.16.x` en `engines`.
- `packageManager` fija npm `11.16.0`, versión incluida con Node.js 24.18.0. No se instaló npm globalmente solo para usar una versión patch posterior.
- Las dependencias directas quedaron fijadas sin rangos para que el lockfile y `package.json` expresen la misma intención.

### Compatibilidad de dependencias

El generador propuso versiones conservadoras. Se contrastaron con el registro de npm y se fijaron:

| Paquete | Versión |
| --- | ---: |
| Next.js | `16.2.9` |
| React | `19.2.7` |
| React DOM | `19.2.7` |
| TypeScript | `6.0.3` |
| Tailwind CSS | `4.3.2` |
| ESLint | `9.39.4` |
| eslint-config-next | `16.2.9` |
| @types/node | `24.13.2` |
| @types/react | `19.2.17` |
| @types/react-dom | `19.2.3` |

`@types/node` se mantuvo en la línea 24 para no ofrecer durante la compilación APIs exclusivas de Node.js 26.

### Rectificación de ESLint

Inicialmente se intentó utilizar ESLint `10.6.0` porque `eslint-config-next` declara compatibilidad con ESLint 9 o superior. La ejecución real falló dentro de `eslint-plugin-react` porque ese plugin todavía utilizaba una API incompatible con ESLint 10.

Se fijó ESLint `9.39.4`, última versión disponible de la línea 9. Con ella, la configuración generada por Next.js ejecuta correctamente. Esta corrección también se reflejó en el registro de Definiciones iniciales.

### Seguridad de dependencias

El primer `npm audit` encontró una vulnerabilidad moderada en la copia de PostCSS incluida transitivamente por Next.js. No se utilizó `npm audit fix --force`, porque proponía una versión incorrecta y disruptiva de Next.js.

Se agregó un override explícito a PostCSS `8.5.16`, versión corregida y compatible. Después de regenerar el lockfile, `npm audit` y `npm audit --omit=dev` informaron cero vulnerabilidades.

npm solicitó aprobación para dos scripts de instalación. Se aprobaron exclusivamente:

- `sharp@0.34.5`, utilizado por Next.js para procesamiento de imágenes;
- `unrs-resolver@1.12.2`, utilizado por la cadena de resolución de ESLint.

Las aprobaciones quedaron declaradas en `allowScripts`; no se habilitaron scripts globalmente para cualquier dependencia.

### Archivos principales creados

- `package.json` y `package-lock.json`.
- `tsconfig.json` con `strict: true`.
- `next.config.ts` y `next-env.d.ts`.
- `eslint.config.mjs`.
- `postcss.config.mjs`.
- `src/app/layout.tsx`, `src/app/page.tsx` y `src/app/globals.css`.
- `.gitignore`.
- Archivos de orientación para agentes generados por Next.js.

### Verificaciones

- `npm ls`: árbol de dependencias válido.
- `npm run lint`: correcto con ESLint 9.39.4.
- `npx tsc --noEmit`: correcto con TypeScript estricto.
- `npm run build`: build de producción correcto con Next.js 16.2.9 y Turbopack.
- `npm audit`: cero vulnerabilidades.
- `npm audit --omit=dev`: cero vulnerabilidades de producción.

### Próximos pasos

La siguiente tarea configurará de forma deliberada Tailwind CSS, ESLint y el formateador. Aunque el scaffold ya proporciona una base funcional para Tailwind y ESLint, esa tarea verificará y completará las reglas de estilo, scripts y formato antes de marcarlos como terminados.
