# Registro de decisiones — 09. Equipos

[Volver al índice de registros](../registro-de-decisiones.md)

## 2026-06-30 — Primer recorrido vertical del catálogo

### Estado

Completada la primera versión del CRUD administrativo para la entrega.

### Decisiones

- La creación valida en el servidor nombre, abreviatura, tipo MIME y límite de 1 MiB aunque el formulario también restrinja el archivo.
- Cada imagen recibe una ruta UUID dentro de `teams/`, evitando colisiones y nombres controlados por el cliente.
- Primero se carga el objeto y luego se inserta el equipo. Si falla PostgreSQL, la Server Action elimina el objeto recién cargado como compensación.
- La eliminación borra primero la fila protegida por claves foráneas y luego limpia la imagen. Así nunca se pierde el archivo de un equipo cuya eliminación fue rechazada por estar inscripto o utilizado.
- Las políticas de `storage.objects` permiten lectura de `team-logos` y reservan altas, cambios y bajas a perfiles `ADMIN` mediante `is_admin()`.
- La lista se renderiza en el servidor y obtiene las URLs públicas desde el bucket, sin almacenar URLs dependientes del entorno en PostgreSQL.
- La edición permite conservar la imagen o cargar una nueva. La nueva se sube antes de actualizar PostgreSQL; ante un fallo se elimina, y la imagen anterior solo se borra después de confirmar el cambio.
- La Server Action rechaza editar equipos que ya participaron en un partido iniciado, usando la hora del servidor de la aplicación y conservando la regla histórica del dominio.

### Verificación

- ESLint, TypeScript, formato y build de producción finalizaron correctamente.
- Next.js registró `/admin/equipos` como ruta dinámica protegida.
- La prueba manual con Storage queda pendiente de aprovisionar la cuenta administradora de desarrollo.
