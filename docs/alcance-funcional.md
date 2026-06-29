# Alcance Funcional - Aplicación Prode de Fútbol

## Descripción General

La aplicación permite gestionar torneos de fútbol y realizar pronósticos (prode) sobre los resultados de los partidos. Existen dos tipos de usuarios:

* Administrador
* Usuario común

Los usuarios comunes podrán registrarse desde la aplicación. Las cuentas de administrador no tendrán registro público: deberán aprovisionarse manualmente creando tanto la identidad en Supabase Authentication como su perfil en la tabla de usuarios con rol `ADMIN`.

Cada torneo es independiente, con su propia llave de eliminación directa, tabla de posiciones de usuarios y puntajes.

---

# Funcionalidades del Administrador

## Gestión de torneos

El administrador podrá:

* Crear torneos.
* Elegir una capacidad de 4, 8, 16 o 32 equipos.
* Consultar el listado de torneos.
* Visualizar el detalle de un torneo.
* Modificar la información de un torneo, siempre que el torneo aún no haya comenzado.
* Eliminar un torneo, siempre que aún no haya comenzado y no existan pronósticos de usuarios.

## Equipos del torneo y sorteo

Antes de generar la llave, el administrador podrá:

* Inscribir equipos del catálogo global en el torneo.
* Retirar equipos inscriptos.
* Consultar la cantidad de lugares disponibles.

El sorteo podrá ejecutarse cuando el torneo tenga exactamente la cantidad de equipos configurada. El sistema generará aleatoriamente los cruces iniciales y todas las fases de la llave.

El sorteo será único y definitivo: después de generarlo no podrán modificarse la capacidad, los equipos inscriptos ni los cruces. Si hubiera un error antes del inicio y todavía no existieran pronósticos, el administrador podrá eliminar el torneo completo y crear uno nuevo.

Las fases dependerán de la capacidad:

* 4 equipos: semifinales y final.
* 8 equipos: cuartos de final, semifinales y final.
* 16 equipos: octavos de final, cuartos de final, semifinales y final.
* 32 equipos: ronda de 32, octavos de final, cuartos de final, semifinales y final.

No se incluirá un partido por el tercer puesto.

## Gestión de partidos

Dentro de cada torneo el administrador podrá:

* Asignar fecha y hora a los partidos generados por la llave.
* Reprogramar un partido únicamente antes de que haya comenzado.
* Registrar el resultado oficial de un partido una vez finalizado.

Los participantes de la primera fase surgirán del sorteo. En las fases siguientes surgirán automáticamente de los ganadores de los partidos anteriores y no podrán elegirse manualmente.

Una vez registrado, el resultado oficial será definitivo y no podrá modificarse ni eliminarse.

Al registrar un resultado oficial, el sistema deberá recalcular automáticamente los puntajes de todos los usuarios que participaron en ese partido y ubicar al ganador en el partido siguiente de la llave.

## Gestión de equipos

El administrador podrá mantener un catálogo global de equipos reutilizable entre torneos.

Podrá:

* Consultar el listado de equipos.
* Crear equipos indicando nombre y abreviatura.
* Modificar un equipo únicamente si todavía no fue utilizado en un partido iniciado.
* Eliminar un equipo únicamente si no está asociado a ningún partido ni inscripto en un torneo.

Los partidos deberán utilizar equipos existentes del catálogo. La carga de escudos no forma parte del MVP.

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

Para cada partido con participantes y fecha definidos, el usuario podrá ingresar un pronóstico indicando la cantidad de goles esperados para ambos equipos.

Si pronostica un empate, deberá seleccionar cuál de los dos equipos ganará por penales. Si pronostica un resultado no empatado, no podrá indicar un ganador por penales.

Un usuario comenzará a participar en un torneo cuando guarde al menos un pronóstico para alguno de sus partidos. No será necesaria una inscripción separada al torneo.

Las siguientes reglas deberán cumplirse:

* El pronóstico podrá modificarse únicamente mientras el partido no haya comenzado.
* Una vez iniciada la fecha y hora del partido, el pronóstico quedará bloqueado y no podrá editarse.

---

# Sistema de Puntajes

Cada torneo posee una tabla de posiciones independiente.

Los puntos obtenidos por un usuario en un torneo no afectan ni se comparten con otros torneos.

Cuando el administrador registre el resultado oficial de un partido, el sistema actualizará automáticamente los puntajes de todos los usuarios participantes según las siguientes reglas:

* Se otorgarán 0 puntos si no se acierta el equipo que avanza a la siguiente fase.
* Se otorgarán 3 puntos si se acierta el equipo que avanza, pero no el marcador exacto previo a penales.
* Se otorgarán 6 puntos si se acierta el marcador exacto previo a penales y, cuando exista empate, también el ganador por penales.

El resultado oficial deberá indicar un ganador por penales cuando el marcador esté empatado. Los goles de la tanda de penales no formarán parte del marcador pronosticado.

---

# Reglas de Negocio

* Solo los administradores pueden crear, modificar o eliminar torneos y programar sus partidos.
* Solo los administradores pueden crear, modificar o eliminar equipos.
* No se puede modificar un equipo utilizado en un partido iniciado ni eliminar un equipo asociado a un partido o inscripto en un torneo.
* No se pueden modificar torneos que ya hayan comenzado ni eliminar torneos iniciados o que ya posean pronósticos.
* Los partidos de la llave no pueden crearse ni eliminarse manualmente; solo pueden programarse o reprogramarse antes de su inicio.
* La capacidad del torneo debe ser 4, 8, 16 o 32.
* La llave solo puede sortearse con la cantidad exacta de equipos y no puede regenerarse.
* Después del sorteo no pueden cambiarse la capacidad, los equipos inscriptos ni los cruces.
* Solo los administradores pueden registrar los resultados oficiales.
* Un resultado oficial registrado no puede modificarse ni eliminarse.
* Todo partido debe producir un ganador; si el marcador oficial está empatado, debe registrarse el ganador por penales.
* El ganador oficial debe avanzar automáticamente al partido correspondiente de la siguiente fase.
* Los usuarios comunes únicamente pueden realizar y modificar sus pronósticos antes del inicio del partido.
* No se puede pronosticar un partido que todavía no tenga ambos participantes y fecha definidos.
* Los puntajes se calculan exclusivamente a partir de los resultados oficiales registrados por un administrador.
* Cada torneo mantiene su propia clasificación de usuarios y sus puntajes de manera independiente.
* Un usuario integra la clasificación de un torneo desde el momento en que guarda su primer pronóstico para un partido de ese torneo.
* La recuperación de contraseña no forma parte del alcance del MVP.

---

# Entidades Principales

* Usuario
* Torneo
* Equipo por Torneo
* Fase
* Partido
* Equipo
* Pronóstico
* Puntaje por Torneo
