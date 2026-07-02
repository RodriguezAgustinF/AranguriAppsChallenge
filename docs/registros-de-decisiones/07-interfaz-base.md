# Registro de decisiones — 07. Interfaz base

[Volver al índice de registros](../registro-de-decisiones.md)

## 2026-07-01 — Identidad visual para la entrega

- Se adoptó una paleta verde de competencia deportiva con superficies claras y un acento dorado reservado para el campeón.
- La portada combina una propuesta de valor directa con una representación decorativa de la llave; no utiliza imágenes externas ni agrega dependencias.
- La tipografía usa la pila del sistema para evitar descargas, cambios de layout y fallos por red durante la entrega.
- Las cabeceras pública y administrativa permanecen visibles al desplazarse y comparten jerarquía, espaciado y estados interactivos.
- Tarjetas, formularios, botones, estados y sombras se normalizaron mediante variables CSS para mantener coherencia entre administración y consulta pública.
- La llave conserva desplazamiento horizontal en pantallas pequeñas, mientras formularios y filas administrativas pasan a una sola columna.
- Se corrigió la grilla de filas: los equipos reservan una columna para su escudo y el resto de entidades utiliza correctamente contenido más acciones.

## 2026-07-01 — Apariencia de sitio web público

- La portada dejó de presentarse como un único panel centrado y pasó a una composición web de ancho completo con encabezado, hero, secciones editoriales, llamado a la acción y pie.
- La navegación pública se extrajo a componentes compartidos para que inicio y torneos mantengan la misma identidad y estructura de sitio.
- La explicación del flujo se presenta como contenido editorial numerado; las tarjetas se reservan para torneos y partidos, donde representan información real.
- El panel administrativo conserva su apariencia funcional porque responde a tareas de gestión y no a navegación pública.

## 2026-07-01 — Unificación visual completa

- Administración, login y sitio público comparten marca, variables, encabezados, anchos máximos, botones, campos y pie cuando corresponde.
- El administrador mantiene una organización operativa, pero abandona la apariencia aislada de dashboard mediante el mismo encabezado web y títulos editoriales.
- El login se integra al sitio como una página de acceso de dos columnas en lugar de una tarjeta flotante sin contexto.

## 2026-07-01 — Identidad de la versión entregable

- La interfaz se presenta como **Gestor de Torneos** y no como Prode porque pronósticos, participación y ranking no integran la entrega actual.
- La evolución hacia Prode se conserva en alcance, arquitectura y backlog; no se eliminan tablas ni reglas ya preparadas para esa etapa.
- Metadatos, encabezados, pie y nombre técnico del paquete reflejan la funcionalidad realmente disponible hoy.

## 2026-07-01 — Ajuste de accesos administrativos

- Se conservó la estructura original de las tarjetas de Equipos y Torneos y se corrigió únicamente su jerarquía visual.
- El número deja de heredar el margen editorial de 52 px y se presenta como una etiqueta compacta; título, descripción y espaciado mantienen una lectura continua.
- Se agregó foco visible para teclado y un fondo sutil, evitando incorporar iconos o elementos decorativos que compitan con el contenido.

## 2026-07-01 — Página para recursos inexistentes

- Se utiliza la convención estable `app/not-found.tsx` de Next.js 16 para responder a rutas inexistentes y llamadas explícitas a `notFound()`.
- La página ofrece acciones para volver al inicio o consultar torneos y conserva la identidad visual sin realizar una redirección silenciosa.
- La composición es autónoma para funcionar bajo el layout raíz y evita incluir encabezado o pie propios, que podrían duplicarse cuando un layout de sección permanece montado.
