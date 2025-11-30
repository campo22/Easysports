# Lógica de la Aplicación: "Crear Encuentro" y "Unirse a Encuentro"

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
5.  **Respuesta:** Se devuelve un mensaje o JSON con la información del encuentro recién creado, incluyendo el código generado.

## 2. Unirse a Encuentro

### ¿Quién puede unirse a un encuentro?
Cualquier usuario registrado y logueado puede unirse a un encuentro *que esté abierto* y *que no esté lleno*.

### ¿Cómo se une un usuario a un encuentro?
El usuario necesita conocer el **código único** del encuentro que quiere unirse (el que se generó al crearlo). Luego, puede usar una función de "unirse" en la app.

### ¿Qué pasa cuando un usuario intenta unirse a un encuentro?
1.  **Autenticación:** La aplicación verifica que el usuario esté logueado y tenga permisos (rol 'USER') usando el token JWT.
2.  **Buscar Encuentro:** La aplicación busca en la base de datos el encuentro que corresponde al código proporcionado.
3.  **Validaciones:**
    *   **Estado:** Se comprueba que el estado del encuentro sea `ABIERTO`. Si está `FINALIZADO` o `CANCELADO`, no se puede unir.
    *   **Cupo:** Se verifica si el número de jugadores actuales (`jugadores_actuales`) ha alcanzado el `maxJugadores`. Si está lleno, no se puede unir.
    *   **Crear/Capitán:** Se verifica que el usuario no sea el mismo que creó el encuentro (el creador ya está contabilizado como un jugador).
4.  **Actualizar Contador:** Si todas las validaciones pasan, se incrementa en 1 la columna `jugadores_actuales` del encuentro en la base de datos.
5.  **Respuesta:** Se devuelve un mensaje o JSON con la información actualizada del encuentro (mostrando el nuevo número de jugadores).

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
*   **Gestión:** En el futuro, se podría añadir lógica para que el capitán invite o acepte miembros, registre estadísticas del equipo, etc. (Aunque por ahora, el proceso de unirse al equipo no está en los endpoints mostrados).

## En resumen para explicar:

*   **Crear Encuentro:** Un usuario logueado llena un formulario con los detalles del partido (tipo, deporte, fecha, lugar, cupos). La app verifica reglas (fecha, autorización para partidos formales) y crea un "evento" con un código único. Sirve para organizar partidos.
*   **Unirse a Encuentro:** Un usuario logueado usa el **código** de un encuentro para "apuntarse". La app revisa si el partido está abierto y no lleno, y luego lo agrega a la lista de participantes, actualizando el contador. Permite a la gente encontrarse y jugar juntos.
*   **Crear Equipo:** Un usuario logueado puede crear un equipo, del cual se convierte en capitán. Sirve para organizar partidos formales y tener una identidad de grupo.

Esta lógica permite una gestión ágil de partidos dentro de la aplicación.