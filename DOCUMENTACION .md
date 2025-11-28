# **📘 EASYSPORTS \- PLANO TÉCNICO MAESTRO (BLUEPRINT)**

Versión: 2.0 (FINAL)  
Fecha: 24 de Noviembre, 2025  
Objetivo: Guía unificada de desarrollo, infraestructura y reglas de negocio.

## **1\. Stack Tecnológico & Entorno**

### **Backend (API REST)**

* **Lenguaje:** Java 17+  
* **Framework:** Spring Boot 3.1+  
* **Build Tool:** Maven  
* **Seguridad:** Spring Security \+ JWT (Stateless)  
* **Documentación:** Swagger / OpenAPI (Opcional pero recomendado)

### **Frontend (Móvil)**

* **Framework:** Flutter 3.13+ (Stable Channel)  
* **Lenguaje:** Dart 3.0+  
* **Gestión de Estado:** Riverpod (Recomendado) o Provider.  
* **Router:** GoRouter.

### **Base de Datos**

* **Motor:** PostgreSQL 15  
* **ORM:** Spring Data JPA (Hibernate)

## **2\. Estructura de Carpetas (Project Structure)**

### **2.1 Backend (/backend)**

Estructura de paquetes estándar en Spring Boot. Root: com.easysports.api

src/main/java/com/easysports/api/  
├── config/                 \# Config (Security, CORS, Swagger)  
│   ├── SecurityConfig.java  
│   └── CorsConfig.java  
├── controller/             \# Endpoints (Reciben JSON, retornan JSON)  
│   ├── AuthController.java  
│   ├── MatchController.java  
│   └── TeamController.java  
├── service/                \# Lógica de Negocio y Validaciones  
│   ├── AuthService.java  
│   ├── MatchService.java   \# Reglas de partidos Casual vs Formal  
│   └── impl/  
├── repository/             \# Interfaces JPA (SQL Queries)  
│   ├── UserRepository.java  
│   └── MatchRepository.java  
├── model/                  \# Entidades (@Entity \- Tablas BD)  
│   ├── User.java  
│   ├── Team.java  
│   └── Match.java  
├── dto/                    \# Objetos de Transferencia (Sin lógica)  
│   ├── request/            \# LoginRequest, CreateMatchRequest  
│   └── response/           \# MatchResponse, AuthResponse  
├── enums/                  \# Constantes (MatchStatus, SportType)  
└── exception/              \# Manejador Global de Errores  
    └── GlobalExceptionHandler.java

### **2.2 Frontend (/mobile/lib)**

Arquitectura **"Feature-First"** (Agrupado por funcionalidad, no por capa).

lib/  
├── main.dart               \# Entry Point  
├── config/                 \# Temas, Rutas, Constantes  
│   ├── theme.dart  
│   └── router.dart  
├── core/                   \# Utilidades compartidas (API Client, Validadores)  
│   ├── api\_client.dart     \# Interceptor para inyectar Token JWT  
│   └── storage.dart        \# Guardar Token en local  
├── features/               \# Módulos de la App  
│   ├── auth/               \# Login/Registro  
│   │   ├── data/           \# AuthRepository  
│   │   ├── presentation/   \# LoginScreen, RegisterScreen  
│   │   └── logic/          \# AuthProvider  
│   ├── home/               \# Dashboard Principal  
│   │   └── presentation/   \# HomeScreen (Tabs)  
│   ├── matches/            \# Crear y Ver Partidos  
│   │   ├── presentation/   \# CreateMatchScreen (Pasos)  
│   │   └── logic/          \# MatchController  
│   └── teams/              \# Mis Equipos  
│       └── presentation/   \# MyTeamsScreen  
└── assets/                 \# Imágenes y Logos

## **3\. Modelo de Datos (Schema PostgreSQL)**

Ejecutar este diseño para soportar el MVP y la visualización de Ligas.

### **Convenciones**

* **Tablas:** snake\_case (plural).  
* **PK:** id (BIGSERIAL).

#### **A. Usuarios y Seguridad**

CREATE TABLE usuarios (  
    id BIGSERIAL PRIMARY KEY,  
    email VARCHAR(150) UNIQUE NOT NULL,  
    password\_hash VARCHAR(255) NOT NULL,  
    nombre\_completo VARCHAR(100) NOT NULL,  
    posicion\_preferida VARCHAR(50), \-- Ej: "Portero"  
    puntuacion DECIMAL(3,1) DEFAULT 5.0,  
    avatar\_url TEXT  
);

#### **B. Equipos**

CREATE TABLE equipos (  
    id BIGSERIAL PRIMARY KEY,  
    nombre VARCHAR(100) NOT NULL,  
    tipo\_deporte VARCHAR(20) NOT NULL, \-- FUTBOL, BASKET, ETC  
    capitan\_id BIGINT REFERENCES usuarios(id),  
    partidos\_ganados INT DEFAULT 0  
);

\-- Tabla Pivote (Muchos a Muchos)  
CREATE TABLE miembros\_equipos (  
    equipo\_id BIGINT REFERENCES equipos(id),  
    usuario\_id BIGINT REFERENCES usuarios(id),  
    fecha\_ingreso TIMESTAMP DEFAULT NOW(),  
    PRIMARY KEY (equipo\_id, usuario\_id)  
);

#### **C. Encuentros (Core del Negocio)**

Esta tabla maneja tanto partidos Casuales como Formales mediante la columna tipo.

CREATE TABLE encuentros (  
    id BIGSERIAL PRIMARY KEY,  
    codigo\_encuentro VARCHAR(10) UNIQUE NOT NULL, \-- Ej: \#A8J9  
    tipo VARCHAR(20) NOT NULL, \-- 'CASUAL' o 'FORMAL'  
    deporte VARCHAR(20) NOT NULL,  
    estado VARCHAR(20) DEFAULT 'ABIERTO', \-- ABIERTO, FINALIZADO, CANCELADO  
    fecha\_programada TIMESTAMP NOT NULL,  
    nombre\_cancha VARCHAR(150) NOT NULL,  
    ubicacion\_cancha VARCHAR(255), \-- Link a Maps o Coordenadas  
      
    \-- Relaciones  
    creador\_id BIGINT REFERENCES usuarios(id),  
    equipo\_local\_id BIGINT REFERENCES equipos(id), \-- NULL si es Casual  
    equipo\_visitante\_id BIGINT REFERENCES equipos(id), \-- NULL si es Casual  
      
    \-- Control de Cupos  
    max\_jugadores INT NOT NULL,  
    jugadores\_actuales INT DEFAULT 1  
);

\-- Participantes individuales (para partidos Casuales)  
CREATE TABLE participantes\_encuentro (  
    encuentro\_id BIGINT REFERENCES encuentros(id),  
    usuario\_id BIGINT REFERENCES usuarios(id),  
    estado VARCHAR(20) DEFAULT 'CONFIRMADO',  
    PRIMARY KEY (encuentro\_id, usuario\_id)  
);

#### **D. Visualización de Ligas (Solo Lectura/Carga Manual)**

CREATE TABLE ligas (  
    id BIGSERIAL PRIMARY KEY,  
    nombre VARCHAR(100) NOT NULL, \-- Ej: "Torneo Invierno 2025"  
    deporte VARCHAR(20) NOT NULL  
);

CREATE TABLE tabla\_posiciones (  
    id BIGSERIAL PRIMARY KEY,  
    liga\_id BIGINT REFERENCES ligas(id),  
    equipo\_id BIGINT REFERENCES equipos(id),  
    puntos INT DEFAULT 0,  
    pj INT DEFAULT 0, \-- Partidos Jugados  
    pg INT DEFAULT 0, \-- Ganados  
    pp INT DEFAULT 0, \-- Perdidos  
    pe INT DEFAULT 0  \-- Empatados  
);

## **4\. Contrato de API (Endpoints Clave)**

El Frontend debe consumir estos endpoints exactos.

### **Autenticación**

* POST /api/auth/registro: Crea usuario y devuelve Token.  
* POST /api/auth/login: Valida credenciales y devuelve Token.

### **Encuentros (MatchController)**

* GET /api/encuentros: Lista partidos filtrados por fecha (más recientes primero).  
  * *Query Param opcional:* ?deporte=FUTBOL  
* POST /api/encuentros: Crea un partido.  
  * **Payload Casual:** { "tipo": "CASUAL", "deporte": "FUTBOL", "fecha": "...", "nombreCancha": "...", "maxJugadores": 10 }  
  * **Payload Formal:** { "tipo": "FORMAL", ..., "equipoLocalId": 5 }  
* POST /api/encuentros/{codigo}/unirse: El usuario logueado se suma al partido.

### **Equipos**

* GET /api/equipos/mis-equipos: Devuelve los equipos donde el usuario es miembro o capitán.  
* POST /api/equipos: Crea un nuevo equipo.

## **5\. Reglas de Negocio (Lógica Backend)**

Estas validaciones deben estar en la capa Service de Java para evitar datos corruptos.

1. **Validación de Capitán (Partidos Formales):**  
   * Al recibir un POST /api/encuentros con tipo="FORMAL", el sistema debe verificar que el usuario\_id (del Token JWT) sea el capitan\_id del equipo enviado en el JSON. Si no lo es, lanzar 403 Forbidden.  
2. **Generación de Código:**  
   * El codigo\_encuentro debe generarse en el Backend (no en el móvil) usando una librería de Random String (6 caracteres alfanuméricos en mayúsculas).  
3. **Control de Cupos:**  
   * Al intentar unirse (/unirse), verificar if (jugadores\_actuales \>= max\_jugadores). Si es verdad, lanzar 409 Conflict ("Partido Lleno").  
4. **Fechas:**  
   * No permitir crear partidos en fechas pasadas.

## **6\. Mapeo Visual (PDF \-\> Código)**

Guía rápida para construir las pantallas de Flutter basadas en el diseño EASYSPORTS.pdf.

| Página PDF | Pantalla Flutter | Acción Principal |
| :---- | :---- | :---- |
| **Pg 1** | LoginScreen | Request a /auth/login. Guardar Token. |
| **Pg 2** | RegisterScreen | Request a /auth/registro. |
| **Pg 4 (Home)** | HomeScreen | ListView horizontal de Deportes. ListView vertical de Partidos (GET /encuentros). |
| **Pg 10-12** | CreateMatchWizard | Formulario multipasos. Paso 1: Tipo. Paso 2: Deporte. |
| **Pg 21** | SelectCourtScreen | Dropdown o Input Texto para nombre de cancha. |
| **Pg 30** | MatchSummary | Muestra resumen antes de enviar el POST final. |
| **Pg 55** | MyTeamsScreen | Grid de tarjetas de equipos (GET /equipos/mis-equipos). |
| **Pg 52** | LeagueTableWidget | Widget reutilizable que consume GET /ligas/{id}/posiciones. |

## **7\. Instrucciones de Despliegue (Docker)**

Para desplegar en Railway o AWS, usar este Dockerfile en la raíz del proyecto Backend.

\# Build Stage  
FROM maven:3.8.5-openjdk-17 AS build  
COPY src /home/app/src  
COPY pom.xml /home/app  
RUN mvn \-f /home/app/pom.xml clean package \-DskipTests

\# Run Stage  
FROM openjdk:17-jdk-alpine  
COPY \--from=build /home/app/target/\*.jar app.jar  
EXPOSE 8080  
ENTRYPOINT \["java","-jar","/app.jar"\]  
