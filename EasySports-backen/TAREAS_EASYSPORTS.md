# Tareas Backend EasySports

## TAREAS REALIZADAS:

1.  **Análisis Inicial del Proyecto:**
    *   Revisado: Estructura de directorios, archivos principales (README.md, DOCUMENTACION .md), tecnologías.
2.  **Revisión del Documento Técnico Maestro:**
    *   Revisado: Stack tecnológico, arquitectura, modelos de datos, reglas de negocio, endpoints.
3.  **Exploración del Código:**
    *   Revisado: Paquetes (`model`, `repository`, `service`, `controller`, etc.).
    *   Revisado: Implementaciones existentes (`AuthController`, `MatchController`, `TeamController`, `AuthService`, `MatchService`, `TeamService`, modelos, DTOs).
4.  **Implementación de `GlobalExceptionHandler`:**
    *   **Hecho:** `src/main/java/com/easysports/exception/GlobalExceptionHandler.java` creado.
5.  **Implementación de Gestión de Miembros del Equipo:**
    *   **Hecho:** Enums `EstadoMiembro`, `RolMiembro` creados.
    *   **Hecho:** Entidad `MiembroEquipo` creada.
    *   **Hecho:** Repositorio `MiembroEquipoRepository` creado.
    *   **Hecho:** DTOs `InvitarMiembroRequest`, `MiembroEquipoResponse` creados.
    *   **Hecho:** Lógica en `TeamService` e `impl/TeamServiceImpl` actualizada para `invitar`, `aceptar`, `rechazar`, `listar`.
    *   **Hecho:** Endpoints en `TeamController` actualizados para `invitar`, `aceptar`, `rechazar`, `listar`.
    *   **Hecho:** Modelos `Team` y `User` actualizados para manejar la relación `MiembroEquipo`.
    *   **Hecho:** `TeamResponse` actualizado para incluir información de membresía (opcional).
    *   **Hecho:** Documentación en `LOGICA_ENCARGOS.md` actualizada con `Gestión de Miembros`.
6.  **Actualización de Lógica de Encuentros (`Match`):**
    *   **Hecho:** Entidad `Participant` creada.
    *   **Hecho:** Repositorio `ParticipantRepository` creado.
    *   **Hecho:** `MatchRepository` actualizado con `existsByCanchaAndFechaProgramada`.
    *   **Hecho:** `MatchServiceImpl` actualizado para usar `Participant` y manejar inscripciones correctamente (`createMatch`, `joinMatch` ahora registran en `Participant`).
    *   **Hecho:** `MatchService` actualizado (ya tenía los métodos).
    *   **Hecho:** `LOGICA_ENCARGOS.md` actualizado con la nueva lógica de `Unirse a Encuentro`.
7.  **Configuración de Seguridad y Autenticación:**
    *   **Hecho:** Revisada `SecurityConfig.java` (correctamente configura `/api/auth/**` como público).
    *   **Hecho:** Revisado `JwtAuthenticationFilter.java` (funcionamiento estándar).
    *   **Hecho:** Corregido error de `ExpiredJwtException` en `login`: Se determinó que era causado por enviar un encabezado `Authorization` incorrecto (vencido) a la solicitud de `login` en Postman, no un fallo en la lógica del código backend.
8.  **Documentación:**
    *   **Hecho:** Creado y mantenido `LOGICA_ENCARGOS.md` con lógica de negocio detallada.
9.  **Pruebas Iniciales en Postman:**
    *   **Hecho:** Definidos pasos y endpoints para probar APIs desde cero en Postman, incluyendo manejo de tokens y códigos de encuentro/equipo.
10. **Listado de Equipos del Usuario (`GET /api/v1/teams/mios`):**
    *   **Hecho:** Implementado en `TeamController`, `TeamService`, `TeamServiceImpl`. **Suponiendo que la funcionalidad está implementada según el análisis de código.**

---

## TAREAS PENDIENTES (FALTAN POR IMPLEMENTAR):

1.  **Listado de Encuentros con Filtros y Paginación:**
    *   **Endpoint:** `GET /api/v1/matches`
    *   **Agregar soporte para Query Params:** `deporte`, `fechaDesde`, `fechaHasta`, `estado`, `pagina`, `tamano`.
    *   **Actualizar `MatchController`, `MatchService`, `MatchRepository` (posiblemente con `Pageable`).**
2.  **Obtención de Detalles de Encuentro/Equipo Específico:**
    *   **Endpoint:** `GET /api/v1/matches/{codigo}`.
    *   **Endpoint:** `GET /api/v1/teams/{id}`.
    *   **Agregar métodos en `MatchService`, `TeamService` y endpoints en sus respectivos `Controller`.**
3.  **Expulsión de Miembro de un Equipo:**
    *   **Endpoint:** `DELETE /api/v1/teams/{id}/miembro/{usuarioId}` (requiere autorización del capitán).
    *   **Agregar método en `TeamService`, `TeamServiceImpl`, `TeamController`, `MiembroEquipoRepository`.**
4.  **Edición de Perfil del Equipo:**
    *   **Endpoint:** `PUT /api/v1/teams/{id}` (requiere autorización del capitán).
    *   **Agregar DTO para actualización (`UpdateTeamRequest`), métodos en `TeamService`, `TeamServiceImpl`, `TeamController`.**
5.  **Cierre/Cancelación de un Encuentro:**
    *   **Endpoint:** `PUT /api/v1/matches/{codigo}/cancelar` (requiere autorización del creador o capitanes).
    *   **Agregar método en `MatchService`, `MatchServiceImpl`, `MatchController`. Actualizar lógica de `MatchStatus`.**
6.  **Registro de Resultados de un Encuentro:**
    *   **Endpoint:** `POST /api/v1/matches/{codigo}/resultados` (requiere autorización específica).
    *   **Agregar DTO (`SubmitResultRequest`), métodos en `MatchService`, `MatchServiceImpl`, `MatchController`. Actualizar `Match` para almacenar resultados.**
    *   **Agregar lógica para actualizar estadísticas de equipo/jugador (ver paso 8).**
7.  **Visualización de Tablas de Posiciones (Ligas):**
    *   **Endpoint:** `GET /api/v1/ligas/{ligaId}/clasificacion`.
    *   **Crear modelos `Liga`, `TablaPosiciones`.**
    *   **Crear servicios/repositorios/lógica para calcular clasificaciones basadas en resultados.**
8.  **Pruebas Unitarias e Integración:**
    *   **Agregar pruebas para `MatchService`, `TeamService`, `AuthService`, controladores, utilidades (`JwtUtil`, etc.).**
9. **Documentación de la API (OpenAPI / Swagger):**
    *   **Agregar anotaciones `@Operation`, `@Parameter`, `@ApiResponse` a los controladores. Configurar Swagger UI.**
10. **Mejoras de Seguridad (Validación de Entrada):**
    *   **Asegurar que todos los DTOs tengan anotaciones de validación (`@Valid`, `@NotBlank`, `@Email`, etc.).**
11. **Manejo Mejorado de Errores:**
    *   **Revisar `GlobalExceptionHandler` para cubrir más casos.**
12. **Logging Adecuado:**
    *   **Agregar logs informativos/advertencia/error en servicios/controladores.**
13. **Preparación para despliegue (Docker, CI/CD):**
    *   **Crear `Dockerfile`, `docker-compose.yml`, pipeline de CI/CD.**

**Resumen:**

*   **Funcionalidades Básicas:** Creadas (auth, matches, teams, membresías), incluyendo "Listado de Equipos del Usuario".
*   **Lógica de Dominio:** Implementada y documentada (`LOGICA_ENCARGOS.md`).
*   **Falta:** **Complementar funcionalidades clave** (listados, detalles, edición, cancelación, resultados, ligas), **profundizar en Pruebas, Seguridad, Documentación, y Logging**.

## TAREAS PRIORITARIAS:

1.  **Listado de Encuentros con Filtros y Paginación:** (Ver Tareas Pendientes #1)
    *   **Prioridad:** Muy Alta. Es fundamental para que los usuarios naveguen y encuentren partidos.
2.  **Obtención de Detalles de Encuentro Específico:** (Ver Tareas Pendientes #2)
    *   **Prioridad:** Alta. Necesario para ver información completa antes de unirse o para revisión.
3.  **Obtención de Detalles de Equipo Específico:** (Ver Tareas Pendientes #2)
    *   **Prioridad:** Alta. Necesario para ver la composición del equipo.
4.  **Registro de Resultados de un Encuentro:** (Ver Tareas Pendientes #6)
    *   **Prioridad:** Muy Alta. Clave para el cierre del ciclo de un partido y para alimentar estadísticas futuras.
5.  **Visualización de Tablas de Posiciones (Ligas):** (Ver Tareas Pendientes #7)
    *   **Prioridad:** Muy Alta. Uno de los objetivos centrales del MVP Plus ("Ligas"). Requiere resultados.
6.  **Pruebas Unitarias e Integración:** (Ver Tareas Pendientes #8)
    *   **Prioridad:** Alta. Garantiza calidad y estabilidad.
7.  **Documentación de la API (OpenAPI / Swagger):** (Ver Tareas Pendientes #9)
    *   **Prioridad:** Media-Alta. Facilita el trabajo del equipo frontend y otros desarrolladores.
8.  **Cierre/Cancelación de un Encuentro:** (Ver Tareas Pendientes #5)
    *   **Prioridad:** Media. Añade robustez al manejo de partidos.
9.  **Expulsión de Miembro de un Equipo:** (Ver Tareas Pendientes #3)
    *   **Prioridad:** Media. Añade robustez al manejo de equipos.
10. **Edición de Perfil del Equipo:** (Ver Tareas Pendientes #4)
    *   **Prioridad:** Media. Añade funcionalidad de administración.
11. **Mejoras de Seguridad y Validación de Entradas:** (Ver Tareas Pendientes #10)
    *   **Prioridad:** Media. Refuerza la seguridad de la aplicación.
12. **Manejo Mejorado de Errores y Logging:** (Ver Tareas Pendientes #11, #12)
    *   **Prioridad:** Media. Facilita la detección y resolución de problemas.
13. **Preparación para despliegue (Docker, CI/CD):** (Ver Tareas Pendientes #13)
    *   **Prioridad:** Depende del estado del MVP. Crucial para pasar a producción.