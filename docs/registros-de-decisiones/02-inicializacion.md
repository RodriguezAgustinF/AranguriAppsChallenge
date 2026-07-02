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

## 2026-06-29 — Estilo, estructura y herramientas de calidad

### Tareas

- Configurar Tailwind CSS, ESLint y formateo.
- Crear la estructura inicial de carpetas.
- Configurar el alias de importación.
- Crear `.env.example` sin secretos.
- Configurar scripts de desarrollo y control de calidad.
- Verificar ejecución local y build inicial.

### Tailwind CSS

- Se mantuvo Tailwind CSS 4.3.2 con `@tailwindcss/postcss`.
- `postcss.config.mjs` registra el plugin oficial.
- `src/app/globals.css` utiliza `@import "tailwindcss"`.
- No se creó `tailwind.config.*`: Tailwind 4 utiliza configuración CSS-first y el MVP todavía no necesita personalizaciones.
- Los tokens visuales se definirán cuando comience el trabajo real de interfaz, evitando anticipar un sistema de diseño sin requerimientos.

### ESLint y Prettier

- ESLint se ocupa de calidad y errores; Prettier se ocupa exclusivamente del formato.
- Se instaló Prettier 3.9.3 de forma local y exacta.
- Se instaló `eslint-config-prettier` 10.1.8 al final del flat config para desactivar reglas que podrían competir con Prettier.
- `.prettierrc.json` fija 100 columnas, dos espacios, punto y coma, comillas dobles, trailing commas y finales de línea LF.
- `.editorconfig` comparte las reglas esenciales con editores que no ejecuten Prettier.
- `.prettierignore` excluye artefactos, dependencias, lockfile y documentación. La documentación queda fuera para evitar reformateos masivos y se valida mediante `git diff --check` y revisión de enlaces.
- No se agregaron hooks Git todavía. Se priorizan comandos explícitos y más adelante CI aplicará los mismos controles.

### Estructura inicial

Se crearon dentro de `src`:

- `actions`;
- `components`;
- `features`;
- `hooks`;
- `lib`;
- `services`;
- `types`;
- `utils`.

Las carpetas aún vacías contienen `.gitkeep` para que Git preserve la estructura. No se crearon barrels `index.ts` vacíos porque agregarían módulos sin una API real.

### Alias y convención de Next.js 16

- `@/*` resuelve a `./src/*` mediante `tsconfig.json`.
- La arquitectura se corrigió de `middleware.ts` a `proxy.ts`: Next.js 16 deprecó Middleware y renombró la convención a Proxy.
- No se creó `proxy.ts` todavía. Se añadirá al integrar Supabase Auth si el refresco de sesión lo requiere.
- Proxy podrá realizar redirecciones optimistas, pero nunca reemplazará autorización de servidor, funciones PostgreSQL ni RLS.

### Variables de entorno

`.env.example` declara únicamente nombres y valores públicos de desarrollo:

- `NEXT_PUBLIC_SUPABASE_URL`;
- `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`;
- `NEXT_PUBLIC_SITE_URL`.

`.gitignore` permite versionar `.env.example` y continúa ignorando los archivos `.env` reales. No se agregó `service_role`, de acuerdo con la estrategia de menor privilegio.

### Scripts

- `npm run dev`: servidor de desarrollo.
- `npm run build`: build de producción.
- `npm run start`: servidor de producción.
- `npm run lint` y `npm run lint:fix`.
- `npm run typecheck`.
- `npm run format` y `npm run format:check`.
- `npm run check`: lint, TypeScript, formato y build en una sola secuencia.

No se agregó todavía un script de pruebas porque el framework de pruebas pertenece a la fase 17. Incluir un comando vacío daría una señal falsa de cobertura.

### Metadatos y documentación base

- El layout raíz utiliza `lang="es"`.
- Los metadatos dejaron de mostrar “Create Next App” y ahora identifican el Prode de Fútbol.
- `README.md` documenta requisitos, ejecución, controles, documentación y flujo Git.

### Flujo Git acordado

- `main` se reservará para estados estables.
- `develop` será la rama de integración.
- El trabajo nacerá desde `develop` en ramas cortas con prefijos `feat/`, `fix/`, `chore/`, `docs/` o `test/`.
- Las ramas volverán a `develop` mediante pull request.
- Las versiones validadas pasarán de `develop` a `main` mediante pull request.

Este flujo agrega más ceremonia que GitHub Flow, pero fue elegido para practicar integración separada de la rama estable. Se evitarán commits directos en `main` y `develop` después de crear la rama de integración.

### Verificaciones finales

- `npm run check`: correcto.
- `npm run lint`: correcto.
- `npm run typecheck`: correcto.
- `npm run format:check`: correcto.
- `npm run build`: correcto.
- Servidor de desarrollo: respuesta HTTP 200 en `127.0.0.1:3000` y contenido esperado.
- `npm audit`: cero vulnerabilidades.
- Enlaces Markdown: correctos.

### Fuentes consultadas

- [Proxy en Next.js 16](https://nextjs.org/docs/app/getting-started/proxy)
- [Instalación de Prettier](https://prettier.io/docs/install)
- [Configuración de Prettier](https://prettier.io/docs/configuration)
- [Tailwind CSS 4](https://tailwindcss.com/blog/tailwindcss-v4)

## 2026-07-01 — README orientado a la evaluación

- El README resume la arquitectura full stack y justifica Next.js, Supabase, PostgreSQL y Vercel sin duplicar la documentación técnica extensa.
- Se documenta de forma explícita el uso de OpenAI Codex para planificación, implementación, pruebas, revisión y documentación, tal como solicita el challenge.
- Se aclara que las propuestas generadas fueron auditadas con controles automáticos, pruebas SQL, revisión manual y Git; la responsabilidad sobre decisiones y resultado final permaneció en el desarrollador.
