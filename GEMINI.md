# **🧠 Memoria del Proyecto EasySports (v2.2 Definitiva)**

Este documento es la única fuente de verdad para el desarrollo del proyecto EasySports. Contiene el plan de ejecución, la arquitectura y las reglas de negocio. **Debo analizar este archivo antes de realizar cualquier tarea.**

---

## **📆 1. Plan de Ejecución y Cronograma (Roadmap)**

**Objetivo:** Entrega final el 9 de Diciembre de 2025.

```gantt
    title Cronograma de Desarrollo EasySports (15 Días)
    dateFormat  YYYY-MM-DD
    axisFormat  %d-%b

    section Hito 1: Cimientos
    Tarea 1.1: Arq. y BD (Config)  :done,    task1_1, 2025-11-24, 1d
    Tarea 1.2: Entidades y Repos   :done,    task1_2, after task1_1, 2d
    Tarea 1.3: Auth y API Base     :done,    task1_3, after task1_2, 3d
    Entrega 1 (30%)                :crit,    mil1, 2025-11-30, 0d

    section Hito 2: Estructura
    Tarea 2.1: Lógica Backend      :         task2_1, after mil1, 3d
    Tarea 2.2: Frontend Home y Menú :         task2_2, after task2_1, 2d
    Entrega 2 (40%)                :crit,    mil2, 2025-12-04, 0d

    section Hito 3: Final
    Tarea 3.1: Integración Visual  :         task3_1, after mil2, 3d
    Tarea 3.2: QA y Pruebas        :         task3_1, after task3_1, 2d
    Entrega Final (30%)            :crit,    mil3, 2025-12-09, 0d
```

---

## **🧩 2. Arquitectura de Software**

*   **Frontend (Móvil):** Flutter (Dart)
*   **Backend (API):** Java Spring Boot 3
*   **Base de Datos:** PostgreSQL
*   **Seguridad:** JWT (JSON Web Tokens) con BCrypt.
*   **Infraestructura:** Docker sobre Railway / AWS.

```flowchart
flowchart LR
  Mobile["App Móvil (Flutter)"] -->|HTTPS| API["API Gateway / REST (Spring Boot)"]
  API --> Auth["Servicio Auth (JWT)"]
  API --> Users["Servicio Usuarios"]
  API --> Matches["Servicio Encuentros"]
  API --> Teams["Servicio Equipos"]
  API --> Files["CDN / Storage (Cloudinary)"]
  API --> DB["PostgreSQL"]
  subgraph Infra[AWS / Railway / Render]
    API
    DB
    Files
  end
```

---

## **🏛️ 3. Modelo de Datos (ERD)**

```erDiagram
  USUARIO {
    int id PK
    string nombre
    string email
    string password_hash
    Role rol
  }
  EQUIPO {
    int id PK
    string nombre
    int deporte_id FK
  }
  JUGADOR {
    int id PK
    int usuario_id FK
    int equipo_id FK
    string posicion
  }
  ENCUENTRO {
    int id PK
    datetime fecha_inicio
    int equipo_local_id FK
    int equipo_visitante_id FK
    int cancha_id FK
    string estado
  }
  CANCHA {
    int id PK
    string nombre
    string ubicacion
  }
  LIGA {
    int id PK
    string nombre
    datetime fecha_inicio
  }
  TABLA_POSICIONES {
    int liga_id PK
    int equipo_id PK
    int puntos
    int jugados
    int ganados
  }

  USUARIO ||--o{ JUGADOR : "juega"
  EQUIPO ||--o{ JUGADOR : "tiene"
  EQUIPO ||--o{ ENCUENTRO : "local"
  EQUIPO ||--o{ ENCUENTRO : "visitante"
  CANCHA ||--o{ ENCUENTRO : "alberga"
  LIGA ||--o{ TABLA_POSICIONES : "contiene"
  EQUIPO ||--o{ TABLA_POSICIONES : "aparece en"
```

---

## **📦 4. Alcance del MVP y Fases Futuras**

### **✅ MVP (Fase Actual)**
1.  **Autenticación:** Login, Registro, Recuperación.
2.  **Home & Dashboard:** Visualización de encuentros.
3.  **Motor de Encuentros:** Creación de partidos.
4.  **Gestión de Equipos:** Creación y visualización.
5.  **Perfil de Usuario:** Datos básicos.
6.  **Navegación:** Menú y ruteo.

### **🎁 Plus (Incluido en MVP)**
*   Compartir Nativo (WhatsApp, etc.).
*   Filtros de Búsqueda Rápida.
*   Visualización de Ligas (estático).
*   Enlace a Google Maps/Waze.

### **🔒 Fases Futuras**
*   Chat en tiempo real.
*   Automatización de Ligas.
*   Búsqueda avanzada con mapa.
*   Notificaciones Push.
*   Panel Administrativo Web.

---

## **🚦 5. Flujo de Estados del Encuentro**

```stateDiagram-v2
    [*] --> ABIERTO: Creado
    ABIERTO --> LLENO: Cupos completados
    ABIERTO --> CANCELADO: Cancelado por creador
    LLENO --> ABIERTO: Jugador se retira
    LLENO --> EN_JUEGO: Hora del partido
    ABIERTO --> EN_JUEGO: Hora del partido
    EN_JUEGO --> FINALIZADO: Tiempo cumplido
    FINALIZADO --> [*]
```