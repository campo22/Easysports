# Lógica de la Aplicación: "Crear Encuentro", "Unirse a Encuentro" y Funcionalidades Adicionales

## 1. Crear Encuentro

### ¿Qué es un Encuentro?
Un "encuentro" es el nombre que le da la aplicación a un partido o juego. Puede ser un partido casual entre amigos o un partido formal entre dos equipos.

### ¿Quién puede crear un encuentro?
Cualquier usuario que esté registrado y haya iniciado sesión en la aplicación puede crear un encuentro.

### ¿Qué información se necesita para crear un encuentro?
Cuando un usuario quiere crear un encuentro, la aplicación le pide que proporcione cierta información:

*   **Tipo de Encuentro:** Puede ser "CASUAL" o "FORMAL".
    *   **CASUAL:** Es un partido informal, como una partida de fútbol en el parque con amigos. No hay equipos fijos, solo personas que se unen.
    *   **FORMAL:** Es un partido entre dos equipos organizados. Por ejemplo, el equipo A contra el equipo B.
*   **Deporte:** El deporte que se va a jugar (fútbol, baloncesto, etc.).
*   **Fecha y Hora:** Cuándo se va a jugar el encuentro. El sistema verifica que la fecha no sea más de 3 días en el futuro y que la hora sea en intervalos de 15 minutos (00, 15, 30, 45).
*   **Lugar (Cancha):** Donde se va a jugar. Puede ser una cancha específica de la base de datos o simplemente un nombre (por ejemplo, "Cancha del Parque").
*   **Cupo de Jugadores:** Cuántas personas pueden participar (mínimo 2).
*   **(Para partidos FORMALES):** Los IDs de los equipos local y visitante.

### ¿Qué pasa cuando un usuario envía la información?
1.  **Autenticación:** La aplicación verifica que el usuario esté logueado y tenga permisos (rol 'USER'). El token JWT que se envía en el header lo confirma.
2.  **Validación de Reglas de Negocio:**
    *   **Fecha y Hora:** Se comprueba que la fecha no sea superior a 3 días en el futuro y que la hora sea en los intervalos permitidos.
    *   **Partidos Formales:** Si es un partido formal, se verifica que el usuario que está intentando crearlo sea el **capitán** de alguno de los equipos involucrados (local o visitante). Esto asegura que solo los capitanes puedan crear partidos formales con sus equipos.
3.  **Generación de Código:** La aplicación genera un **código único** alfanumérico (por ejemplo, `A1B2C3`). Este código es como un identificador corto e intercambiable para el encuentro.
4.  **Persistencia:** Se guarda toda la información del encuentro en la base de datos (en la tabla `encuentros`).
5.  **Registro de Participante:** Se crea un **nuevo registro** en la tabla pivote `participantes_encuentro` (entidad `Participant`) asociando al usuario creador con el encuentro recién creado.
6.  **Respuesta:** Se devuelve un mensaje o JSON con la información del encuentro recién creado, incluyendo el código generado.

## 2. Unirse a Encuentro

### ¿Quién puede unirse a un encuentro?
Cualquier usuario registrado y logueado puede unirse a un encuentro *que esté abierto* y *que no esté lleno*.

### ¿Cómo se une un usuario a un encuentro?
El usuario necesita conocer el **código único** del encuentro que quiere unirse (el que se generó al crearlo). Luego, puede usar una función de "unirse" en la app.

### ¿Qué pasa cuando un usuario intenta unirse a un encuentro?
1.  **Autenticación:** La aplicación verifica que el usuario esté logueado y tenga permisos (rol 'USER') usando el token JWT.
2.  **Buscar Encuentro:** La aplicación busca en la base de datos el encuentro que corresponde al código proporcionado.
3.  **Validaciones:**
    *   **Estado:** Se comprueba que el estado del encuentro sea `ABIERTO`. Si está `FINALIZADO`, `CANCELADO` o `LLENO`, no se puede unir.
    *   **Cupo:** Se verifica si el número de jugadores actuales (`jugadores_actuales`) ha alcanzado el `maxJugadores`. Si está lleno, no se puede unir.
    *   **Ya Inscrito:** Se verifica si el usuario ya está registrado como participante en este encuentro (buscando en la tabla pivote `participantes_encuentro`). Si ya está inscrito, no se puede unir de nuevo.
    *   **Crear/Capitán:** Se verifica que el usuario no sea el mismo que creó el encuentro (el creador ya está registrado como participante automáticamente al crear el encuentro).
4.  **Registro de Participante:** Si todas las validaciones pasan, se crea un **nuevo registro** en la tabla pivote `participantes_encuentro` (representada por la entidad `Participant` en el código), asociando al usuario con el encuentro y registrando la fecha de inscripción.
5.  **Actualizar Contador y Estado:** Se incrementa en 1 la columna `jugadores_actuales` del encuentro en la base de datos. Si el nuevo número de jugadores alcanza el `maxJugadores`, el estado del encuentro se cambia a `LLENO`.
6.  **Respuesta:** Se devuelve un mensaje o JSON con la información actualizada del encuentro (mostrando el nuevo número de jugadores y estado).

## 3. Crear Equipo

### ¿Qué es un Equipo?
Un "equipo" es un grupo de usuarios que se organizan para jugar partidos formales juntos. Tiene un nombre, un deporte específico y un **capitán**.

### ¿Quién puede crear un equipo?
Cualquier usuario registrado y logueado puede crear un equipo. Al crearlo, ese usuario se convierte automáticamente en el **capitán** del equipo.

### ¿Qué información se necesita para crear un equipo?
Cuando un usuario quiere crear un equipo, la aplicación le pide:

*   **Nombre del Equipo:** El nombre con el que se identificará el equipo (por ejemplo, "Los Campeones").
*   **Deporte:** El deporte principal del equipo (fútbol, baloncesto, etc.).

### ¿Qué pasa cuando un usuario envía la información?
1.  **Autenticación:** La aplicación verifica que el usuario esté logueado y tenga permisos (rol 'USER'). El token JWT lo confirma.
2.  **Creación:** Se crea un nuevo registro en la base de datos (tabla `equipos`) con el nombre, el deporte y el ID del usuario que lo creó como `capitan_id`.
3.  **Respuesta:** Se devuelve un mensaje o JSON con la información del equipo recién creado.

### ¿Para qué sirve crear un equipo?
*   **Organizar partidos formales:** Los equipos son necesarios para jugar partidos formales. El capitán puede crear encuentros y desafiar a otros equipos.
*   **Identidad:** Permite que un grupo de jugadores tenga una identidad compartida dentro de la aplicación.
*   **Gestión:** En el futuro, se podría añadir lógica para que el capitán invite o acepte miembros, registre estadísticas del equipo, etc. (Aunque por ahora, el proceso de unirse al equipo se maneja con una tabla pivote `miembros_equipos`).

## 4. Gestión de Miembros del Equipo

### ¿Qué es la Gestión de Miembros del Equipo?
Es el conjunto de funcionalidades que permiten a los **capitanes** invitar a otros usuarios a unirse a su equipo, y a los **usuarios** aceptar o rechazar esas invitaciones. También permite a los usuarios ver los equipos a los que pertenecen o han sido invitados.

### ¿Quién puede gestionar los miembros de un equipo?
*   **Capitán del Equipo:** Es el único usuario con permisos para **invitar** a nuevos miembros.
*   **Usuario Invitado:** Es el único usuario que puede **aceptar** o **rechazar** una invitación que le haya sido enviada a él mismo.

### ¿Qué información se necesita para invitar a un miembro?
Cuando un capitán quiere invitar a un usuario, la aplicación le pide:

*   **Email del Usuario:** La aplicación buscará al usuario en la base de datos usando este email.

### ¿Qué pasa cuando un capitán envía la invitación?
1.  **Autenticación y Autorización:** La aplicación verifica que el usuario que envía la invitación esté logueado y sea efectivamente el **capitán** del equipo al que quiere invitar al usuario.
2.  **Buscar Usuario:** La aplicación busca en la base de datos al usuario usando el email proporcionado. Si no se encuentra, se devuelve un error.
3.  **Verificar Estado Existente:** La aplicación verifica si ya existe una relación entre este usuario y este equipo (por ejemplo, si ya es miembro o si tiene una invitación pendiente). Si es así, puede devolver un error (por ejemplo, "Ya existe una invitación pendiente" o "El usuario ya es miembro").
4.  **Creación de la Relación:** Si no hay estados que lo impidan, se crea una nueva entrada en la tabla pivote `miembros_equipos` con los IDs del usuario y del equipo, el estado `INVITADO_PENDIENTE`, el rol `MIEMBRO` y la fecha del estado.
5.  **Respuesta:** Se devuelve un código de éxito (por ejemplo, 200 OK).

### ¿Qué pasa cuando un usuario acepta una invitación?
1.  **Autenticación y Autorización:** La aplicación verifica que el usuario que acepta esté logueado y que la invitación exista, esté pendiente y sea para *ese* usuario y *ese* equipo.
2.  **Actualizar Estado:** La aplicación encuentra la entrada correspondiente en la tabla `miembros_equipos` y **actualiza** su estado a `ACEPTADO`.
3.  **Actualizar Fecha de Ingreso:** Se **actualiza** el campo `fecha_ingreso` con la fecha y hora actuales.
4.  **Actualizar Fecha de Estado:** Se **actualiza** el campo `fecha_estado` con la fecha y hora actuales.
5.  **Respuesta:** Se devuelve un código de éxito (por ejemplo, 200 OK).

### ¿Qué pasa cuando un usuario rechaza una invitación?
1.  **Autenticación y Autorización:** La aplicación verifica que el usuario que rechaza esté logueado y que la invitación exista, esté pendiente y sea para *ese* usuario y *ese* equipo.
2.  **Actualizar Estado:** La aplicación encuentra la entrada correspondiente en la tabla `miembros_equipos` y **actualiza** su estado a `RECHAZADO`.
3.  **Actualizar Fecha de Estado:** Se **actualiza** el campo `fecha_estado` con la fecha y hora actuales.
4.  **Respuesta:** Se devuelve un código de éxito (por ejemplo, 200 OK).

### ¿Qué pasa cuando un usuario lista sus equipos?
1.  **Autenticación:** La aplicación verifica que el usuario esté logueado.
2.  **Buscar Relaciones:** La aplicación busca todas las entradas en la tabla `miembros_equipos` donde el `usuario_id` sea el del usuario autenticado.
3.  **Filtrar por Estado:** Se pueden filtrar las entradas para devolver solo las que tengan estado `ACEPTADO` (miembro activo) o `INVITADO_PENDIENTE` (invitación pendiente), dependiendo del objetivo del endpoint.
4.  **Mapear a DTO:** La información de los equipos relacionados se mapea a una lista de `TeamResponse`.
5.  **Respuesta:** Se devuelve la lista de equipos.

### ¿Para qué sirve la Gestión de Miembros del Equipo?
*   **Formar Equipos:** Permite que los capitanes organicen sus equipos y agreguen jugadores de forma controlada.
*   **Invitaciones y Control:** Proporciona un mecanismo para que los usuarios acepten activamente unirse a un equipo, en lugar de ser agregados directamente.
*   **Visibilidad:** Permite a los usuarios ver en qué equipos están como miembros activos o con invitaciones pendientes.

## 5. Expulsión de Miembros del Equipo

### ¿Quién puede expulsar a un miembro de un equipo?
Solo el capitán del equipo tiene permisos para expulsar a un miembro del equipo.

### ¿Qué información se necesita para expulsar a un miembro?
Para expulsar a un miembro, se necesita:
*   **ID del Equipo:** El equipo del que se quiere expulsar al miembro.
*   **ID del Usuario:** El usuario que será expulsado.

### ¿Qué pasa cuando un capitán expulsa a un miembro?
1.  **Autenticación y Autorización:** La aplicación verifica que el usuario que intenta expulsar esté logueado y sea efectivamente el **capitán** del equipo.
2.  **Verificación de membresía:** Se verifica que el usuario que se va a expulsar efectivamente pertenezca al equipo.
3.  **Restricción:** No se puede expulsar al capitán del equipo (verificación adicional).
4.  **Actualizar Estado:** La aplicación encuentra la entrada correspondiente en la tabla `miembros_equipos` y **actualiza** su estado a `EXPULSADO`.
5.  **Actualizar Fechas:** Se **actualiza** el campo `fecha_estado` con la fecha y hora actuales y se **anula** la fecha de ingreso.
6.  **Respuesta:** Se devuelve un código de éxito (por ejemplo, 204 No Content).

## 6. Edición de Perfil del Equipo

### ¿Quién puede editar el perfil de un equipo?
Solo el capitán del equipo tiene permisos para editar la información del equipo.

### ¿Qué información se puede editar?
Actualmente se pueden editar:
*   **Nombre del Equipo:** El nuevo nombre con el que se identificará el equipo.
*   **Deporte:** El deporte principal del equipo.

### ¿Qué pasa cuando un capitán edita el equipo?
1.  **Autenticación y Autorización:** La aplicación verifica que el usuario que intenta editar esté logueado y sea efectivamente el **capitán** del equipo.
2.  **Validación de Datos:** Se validan los nuevos datos proporcionados (nombre no vacío, deporte válido).
3.  **Actualizar Información:** Se actualiza la información del equipo en la base de datos.
4.  **Respuesta:** Se devuelve un mensaje o JSON con la información actualizada del equipo.

## 7. Registro de Resultados de Encuentro

### ¿Quién puede registrar resultados de un encuentro?
Solo el creador del encuentro puede registrar los resultados.

### ¿Qué información se necesita para registrar resultados?
Para registrar resultados, se necesita:
*   **Código del Encuentro:** El código único del encuentro.
*   **ID del Equipo Local:** El equipo local (en partidos formales).
*   **ID del Equipo Visitante:** El equipo visitante (en partidos formales).
*   **Resultado Local:** El número de puntos/goles anotados por el equipo local.
*   **Resultado Visitante:** El número de puntos/goles anotados por el equipo visitante.

### ¿Qué pasa cuando se registran los resultados?
1.  **Autenticación:** La aplicación verifica que el usuario esté logueado y tenga permisos.
2.  **Autorización:** Se verifica que el usuario sea el creador del encuentro.
3.  **Validación de Equipos:** En partidos formales, se verifica que los IDs de los equipos coincidan con los del encuentro.
4.  **Actualizar Resultados:** Se actualizan los campos de resultado en el encuentro y se cambia el estado a `FINALIZADO`.
5.  **Respuesta:** Se devuelve un mensaje o JSON con la información actualizada del encuentro.

## 8. Cancelación de Encuentro

### ¿Quién puede cancelar un encuentro?
Solo el creador del encuentro puede cancelarlo.

### ¿Qué información se necesita para cancelar un encuentro?
Para cancelar un encuentro, se necesita:
*   **Código del Encuentro:** El código único del encuentro a cancelar.

### ¿Qué pasa cuando se cancela un encuentro?
1.  **Autenticación:** La aplicación verifica que el usuario esté logueado y tenga permisos.
2.  **Autorización:** Se verifica que el usuario sea el creador del encuentro.
3.  **Estado:** Se verifica que el encuentro no esté ya finalizado o cancelado.
4.  **Actualizar Estado:** Se cambia el estado del encuentro a `CANCELADO`.
5.  **Respuesta:** Se devuelve un mensaje o JSON con la información actualizada del encuentro.

## En resumen para explicar:

*   **Crear Encuentro:** Un usuario logueado llena un formulario con los detalles del partido (tipo, deporte, fecha, lugar, cupos). La app verifica reglas (fecha, autorización para partidos formales) y crea un "evento" con un código único. Sirve para organizar partidos.
*   **Unirse a Encuentro:** Un usuario logueado usa el **código** de un encuentro para "apuntarse". La app revisa si el partido está abierto y no lleno, y luego lo agrega a la lista de participantes, actualizando el contador. Permite a la gente encontrarse y jugar juntos.
*   **Crear Equipo:** Un usuario logueado puede crear un equipo, del cual se convierte en capitán. Sirve para organizar partidos formales y tener una identidad de grupo.
*   **Gestión de Miembros:** El capitán puede invitar a usuarios a su equipo. Los usuarios pueden aceptar o rechazar esas invitaciones. Los usuarios pueden ver sus equipos. Esto permite formar equipos de forma controlada.
*   **Expulsión de Miembros:** El capitán puede expulsar a miembros de su equipo. El estado del miembro cambia a "expulsado".
*   **Edición de Equipo:** El capitán puede actualizar la información de su equipo (nombre, deporte).
*   **Registro de Resultados:** El creador del encuentro puede registrar los resultados finales del partido.
*   **Cancelación de Encuentros:** El creador del encuentro puede cancelar un partido antes de que comience.

Esta lógica permite una gestión ágil de partidos y equipos dentro de la aplicación.