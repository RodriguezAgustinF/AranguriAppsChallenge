# Alcance Funcional - Aplicación Prode de Fútbol

## Descripción General

La aplicación permite gestionar torneos de fútbol y realizar pronósticos (prode) sobre los resultados de los partidos. Existen dos tipos de usuarios:

* Administrador
* Usuario común

Los usuarios comunes podrán registrarse desde la aplicación. Las cuentas de administrador no tendrán registro público: deberán aprovisionarse manualmente creando tanto la identidad en Supabase Authentication como su perfil en la tabla de usuarios con rol `ADMIN`.

Cada torneo es independiente, con su propia tabla de posiciones y puntajes.

---

# Funcionalidades del Administrador

## Gestión de torneos

El administrador podrá:

* Crear torneos.
* Consultar el listado de torneos.
* Visualizar el detalle de un torneo.
* Modificar la información de un torneo, siempre que el torneo aún no haya comenzado.
* Eliminar un torneo, siempre que el torneo aún no haya comenzado.

## Gestión de partidos

Dentro de cada torneo el administrador podrá:

* Crear partidos indicando los equipos participantes y la fecha/hora de inicio.
* Modificar un partido únicamente antes de que haya comenzado.
* Eliminar un partido únicamente antes de que haya comenzado.
* Registrar el resultado oficial de un partido una vez finalizado.

Una vez registrado, el resultado oficial será definitivo y no podrá modificarse ni eliminarse.

Al registrar un resultado oficial, el sistema deberá recalcular automáticamente los puntajes de todos los usuarios que participaron en ese partido.

---

# Funcionalidades del Usuario Común

## Autenticación

El usuario podrá:

* Registrarse en la aplicación.
* Iniciar sesión.
* Cerrar sesión.

## Consulta de torneos

El usuario podrá:

* Visualizar el listado de torneos disponibles.
* Consultar los partidos de cada torneo.
* Consultar su puntaje dentro de cada torneo.

## Pronósticos

Para cada partido, el usuario podrá ingresar un pronóstico indicando la cantidad de goles esperados para ambos equipos.

Un usuario comenzará a participar en un torneo cuando guarde al menos un pronóstico para alguno de sus partidos. No será necesaria una inscripción separada al torneo.

Las siguientes reglas deberán cumplirse:

* El pronóstico podrá modificarse únicamente mientras el partido no haya comenzado.
* Una vez iniciada la fecha y hora del partido, el pronóstico quedará bloqueado y no podrá editarse.

---

# Sistema de Puntajes

Cada torneo posee una tabla de posiciones independiente.

Los puntos obtenidos por un usuario en un torneo no afectan ni se comparten con otros torneos.

Cuando el administrador registre el resultado oficial de un partido, el sistema actualizará automáticamente los puntajes de todos los usuarios participantes según las siguientes reglas:

* Se otorgarán 0 si se falla el ganador del partido.
* Se otorgarán 3 puntos por acertar el ganador del partido (o el empate).
* Se otorgarán 6 puntos si además se acierta el resultado exacto (cantidad de goles de ambos equipos).

---

# Reglas de Negocio

* Solo los administradores pueden crear, modificar o eliminar torneos y partidos.
* No se pueden modificar ni eliminar torneos o partidos que ya hayan comenzado.
* Solo los administradores pueden registrar los resultados oficiales.
* Un resultado oficial registrado no puede modificarse ni eliminarse.
* Los usuarios comunes únicamente pueden realizar y modificar sus pronósticos antes del inicio del partido.
* Los puntajes se calculan exclusivamente a partir de los resultados oficiales registrados por un administrador.
* Cada torneo mantiene su propia clasificación de usuarios y sus puntajes de manera independiente.
* Un usuario integra la clasificación de un torneo desde el momento en que guarda su primer pronóstico para un partido de ese torneo.
* La recuperación de contraseña no forma parte del alcance del MVP.

---

# Entidades Principales

* Usuario
* Torneo
* Partido
* Equipo
* Pronóstico
* Puntaje por Torneo
