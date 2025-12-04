# Lista de Tareas para la Aplicación Móvil EasySports (Flutter)

## Fase 1: Configuración del Proyecto y Estructura Inicial
1. [completed] Crear la estructura de carpetas para el proyecto Flutter (`EasySports-flutter`).
2. [completed] Inicializar el proyecto Flutter dentro de la nueva carpeta.
3. [completed] Configurar la estructura de directorios dentro de `lib` (ej. `screens`, `widgets`, `services`, `models`, `providers`).
4. [completed] Implementar una capa de servicio API básica para manejar solicitudes HTTP y JWT.

## Fase 2: Flujo de Autenticación
5. [completed] Diseñar la interfaz de usuario (UI) para la pantalla de Login.
6. [completed] Implementar la lógica de Login, conectando la UI con el servicio API y gestionando el almacenamiento del JWT.
7. [completed] Diseñar la interfaz de usuario (UI) para la pantalla de Registro.
8. [completed] Implementar la lógica de Registro, conectando la UI con el servicio API.

## Fase 3: Navegación Principal y Dashboard
9. [completed] Implementar la navegación principal de la aplicación (ej. `BottomNavigationBar`).
10. [completed] Diseñar la interfaz de usuario (UI) para el Dashboard de Partidos (lista de encuentros).
11. [completed] Implementar la lógica para obtener y mostrar la lista de partidos desde `GET /api/v1/matches`.

## Fase 4: Detalles y Creación de Partidos
12. [completed] Diseñar la interfaz de usuario (UI) para la pantalla de Detalle de Partido.
13. [completed] Implementar la lógica para obtener y mostrar los detalles de un partido desde `GET /api/v1/matches/{codigo}`.
14. [completed] Diseñar la interfaz de usuario (UI) para la pantalla de Crear Partido.
15. [completed] Implementar la lógica para enviar los datos de creación de partido a `POST /api/v1/matches`.

## Fase 5: Perfil de Usuario y Equipos (MVP Básico)
16. [completed] Diseñar la interfaz de usuario (UI) para la pantalla de Perfil de Usuario (básico).
17. [completed] Implementar la lógica para mostrar la información básica del usuario en la pantalla de Perfil.
18. [completed] Diseñar la interfaz de usuario (UI) para la pantalla de Lista de Equipos del usuario.
19. [completed] Implementar la lógica para obtener y mostrar la lista de equipos del usuario.

## Fase 6: Funcionalidades Adicionales Implementadas
20. [completed] Implementar la funcionalidad para unirse a partidos.
21. [completed] Implementar la funcionalidad para aceptar/rechazar invitaciones a equipos.
22. [completed] Implementar la funcionalidad para expulsar miembros de un equipo.
23. [completed] Implementar la funcionalidad para editar el perfil del equipo.
24. [completed] Implementar vistas para la gestión de ligas y tablas de posiciones.
25. [completed] Implementar la funcionalidad para registrar resultados de partidos.
26. [completed] Implementar la funcionalidad para cerrar/cancelar partidos.
27. [completed] Conectar todas las vistas con el backend de Spring Boot.
28. [completed] Implementar navegación entre vistas con parámetros.
29. [completed] Agregar validaciones de entrada en todos los formularios.

## Tareas Pendientes
30. [pending] Mejorar el manejo de errores y estados de carga en todas las vistas.
31. [pending] Agregar pruebas unitarias e integración para los componentes Flutter.
32. [pending] Implementar sistema de notificaciones push.
33. [pending] Agregar funcionalidad de chat dentro de los partidos o equipos.
34. [pending] Implementar funcionalidad para calificar jugadores después de un partido.
