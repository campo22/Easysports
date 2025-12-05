# Documentación de APIs - Backend EasySports

## Introducción
Este documento describe los endpoints disponibles en el backend de EasySports para su integración con la aplicación Flutter.

## Información General
- **URL Base**: `http://localhost:8080/api` (o la IP de tu servidor)
- **Prefijo de Versionado**: `/v1` (algunos endpoints usan prefijo `/v1`, otros no)
- **Formato de Datos**: JSON
- **Autenticación**: JWT Token en Header `Authorization: Bearer <token>`

## Autenticación

### Registro de Usuario
- **Endpoint**: `POST /api/auth/registro`
- **Descripción**: Registra un nuevo usuario en el sistema
- **Headers**:
  - `Content-Type: application/json`
- **Body**:
  ```json
  {
    "nombreCompleto": "string",
    "email": "string",
    "password": "string",
    "sexo": "string",
    "edadAnios": "number",
    "edadMeses": "number"
  }
  ```
- **Respuesta Exitosa** (201):
  ```json
  {
    "token": "string"
  }
  ```
- **Errores Comunes**:
  - `400`: Datos inválidos
  - `409`: Email ya registrado

### Inicio de Sesión
- **Endpoint**: `POST /api/auth/login`
- **Descripción**: Autentica un usuario existente
- **Headers**:
  - `Content-Type: application/json`
- **Body**:
  ```json
  {
    "email": "string",
    "password": "string"
  }
  ```
- **Respuesta Exitosa** (200):
  ```json
  {
    "token": "string"
  }
  ```
- **Errores Comunes**:
  - `400`: Datos inválidos
  - `401`: Credenciales incorrectas

### Actualizar Perfil
- **Endpoint**: `PUT /api/auth/profile`
- **Descripción**: Actualiza los datos del perfil del usuario autenticado
- **Headers**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`
- **Body**:
  ```json
  {
    "nombreCompleto": "string",
    "email": "string",
    "sexo": "string",
    "edadAnios": "number",
    "edadMeses": "number"
  }
  ```
- **Respuesta Exitosa** (200): `200 OK`

## Gestión de Equipos

### Crear Equipo
- **Endpoint**: `POST /api/v1/teams`
- **Descripción**: Crea un nuevo equipo (el usuario se convierte en capitán)
- **Headers**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`
- **Body**:
  ```json
  {
    "nombre": "string",
    "deporte": "string"
  }
  ```
- **Respuesta Exitosa** (201):
  ```json
  {
    "id": 0,
    "nombre": "string",
    "deporte": "string",
    "capitanId": 0,
    "fechaCreacion": "string"
  }
  ```

### Obtener Equipos del Usuario
- **Endpoint**: `GET /api/v1/teams/mios`
- **Descripción**: Obtiene los equipos del usuario autenticado (miembro o capitán)
- **Headers**:
  - `Authorization: Bearer <token>`
- **Respuesta Exitosa** (200):
  ```json
  [
    {
      "id": 0,
      "nombre": "string",
      "deporte": "string",
      "capitanId": 0,
      "fechaCreacion": "string"
    }
  ]
  ```

### Obtener Detalles de un Equipo
- **Endpoint**: `GET /api/v1/teams/{id}`
- **Descripción**: Obtiene los detalles de un equipo específico
- **Headers**:
  - `Authorization: Bearer <token>`
- **Parámetros de Ruta**:
  - `id`: ID del equipo
- **Respuesta Exitosa** (200):
  ```json
  {
    "id": 0,
    "nombre": "string",
    "deporte": "string",
    "capitanId": 0,
    "fechaCreacion": "string"
  }
  ```

### Actualizar Equipo
- **Endpoint**: `PUT /api/v1/teams/{id}`
- **Descripción**: Actualiza la información de un equipo (solo el capitán puede hacerlo)
- **Headers**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`
- **Parámetros de Ruta**:
  - `id`: ID del equipo
- **Body**:
  ```json
  {
    "nombre": "string",
    "deporte": "string"
  }
  ```
- **Respuesta Exitosa** (200):
  ```json
  {
    "id": 0,
    "nombre": "string",
    "deporte": "string",
    "capitanId": 0,
    "fechaCreacion": "string"
  }
  ```

### Invitar Miembro a Equipo
- **Endpoint**: `POST /api/v1/teams/{equipoId}/invitar`
- **Descripción**: Invita a un usuario (por email) a unirse a un equipo
- **Headers**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`
- **Parámetros de Ruta**:
  - `equipoId`: ID del equipo
- **Body**:
  ```json
  {
    "email": "string"
  }
  ```
- **Respuesta Exitosa** (200): `200 OK`

### Aceptar Invitación a Equipo
- **Endpoint**: `PUT /api/v1/teams/{equipoId}/invitaciones/aceptar`
- **Descripción**: Acepta una invitación pendiente a unirse a un equipo
- **Headers**:
  - `Authorization: Bearer <token>`
- **Parámetros de Ruta**:
  - `equipoId`: ID del equipo
- **Respuesta Exitosa** (200): `200 OK`

### Rechazar Invitación a Equipo
- **Endpoint**: `PUT /api/v1/teams/{equipoId}/invitaciones/rechazar`
- **Descripción**: Rechaza una invitación pendiente a unirse a un equipo
- **Headers**:
  - `Authorization: Bearer <token>`
- **Parámetros de Ruta**:
  - `equipoId`: ID del equipo
- **Respuesta Exitosa** (200): `200 OK`

### Expulsar Miembro de Equipo
- **Endpoint**: `DELETE /api/v1/teams/{equipoId}/miembro/{usuarioId}`
- **Descripción**: Expulsa a un miembro del equipo (solo el capitán puede hacerlo)
- **Headers**:
  - `Authorization: Bearer <token>`
- **Parámetros de Ruta**:
  - `equipoId`: ID del equipo
  - `usuarioId`: ID del usuario a expulsar
- **Respuesta Exitosa** (204): `204 No Content`

## Gestión de Encuentros/Partidos

### Listar Encuentros
- **Endpoint**: `GET /api/v1/matches`
- **Descripción**: Obtiene una lista paginada de encuentros con posibles filtros
- **Headers**:
  - `Authorization: Bearer <token>`
- **Parámetros de Consulta** (opcionales):
  - `deporte`: Filtro por deporte (ej: "FUTBOL")
  - `estado`: Filtro por estado (ej: "ABIERTO")
  - `fechaDesde`: Filtro por fecha de inicio (ISO: "2025-12-01T10:00:00")
  - `fechaHasta`: Filtro por fecha de fin (ISO: "2025-12-31T23:59:59")
  - `page`: Número de página (por defecto: 0)
  - `size`: Tamaño de página (por defecto: 20)
  - `sort`: Criterio de ordenamiento (por defecto: "fechaProgramada,desc")
- **Respuesta Exitosa** (200):
  ```json
  {
    "content": [
      {
        "id": 0,
        "codigo": "string",
        "tipo": "string",
        "deporte": "string",
        "estado": "string",
        "fechaProgramada": "string",
        "canchaId": 0,
        "nombreCanchaTexto": "string",
        "creadorId": 0,
        "equipoLocalId": 0,
        "equipoVisitanteId": 0,
        "maxJugadores": 0,
        "jugadoresActuales": 0
      }
    ],
    "pageable": { },
    "totalElements": 0,
    "totalPages": 0,
    "size": 0,
    "number": 0,
    "sort": { },
    "first": false,
    "last": false,
    "numberOfElements": 0,
    "empty": false
  }
  ```

### Obtener Detalles de un Encuentro
- **Endpoint**: `GET /api/v1/matches/{codigo}`
- **Descripción**: Obtiene los detalles de un encuentro específico usando su código
- **Headers**:
  - `Authorization: Bearer <token>`
- **Parámetros de Ruta**:
  - `codigo`: Código único del encuentro
- **Respuesta Exitosa** (200):
  ```json
  {
    "id": 0,
    "codigo": "string",
    "tipo": "string",
    "deporte": "string",
    "estado": "string",
    "fechaProgramada": "string",
    "canchaId": 0,
    "nombreCanchaTexto": "string",
    "creadorId": 0,
    "equipoLocalId": 0,
    "equipoVisitanteId": 0,
    "maxJugadores": 0,
    "jugadoresActuales": 0
  }
  ```

### Crear Encuentro
- **Endpoint**: `POST /api/v1/matches`
- **Descripción**: Crea un nuevo encuentro (partido)
- **Headers**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>`
- **Body**:
  ```json
  {
    "tipoEncuentro": "string",
    "deporte": "string",
    "fechaProgramada": "string",
    "ubicacion": "string",
    "maxJugadores": 0,
    "estado": "string",
    "equipoLocalId": 0,
    "equipoVisitanteId": 0
  }
  ```
- **Respuesta Exitosa** (201):
  ```json
  {
    "id": 0,
    "codigo": "string",
    "tipo": "string",
    "deporte": "string",
    "estado": "string",
    "fechaProgramada": "string",
    "canchaId": 0,
    "nombreCanchaTexto": "string",
    "creadorId": 0,
    "equipoLocalId": 0,
    "equipoVisitanteId": 0,
    "maxJugadores": 0,
    "jugadoresActuales": 0
  }
  ```

### Unirse a Encuentro
- **Endpoint**: `POST /api/v1/matches/{codigo}/unirse`
- **Descripción**: Permite a un usuario unirse a un encuentro existente
- **Headers**:
  - `Authorization: Bearer <token>`
- **Parámetros de Ruta**:
  - `codigo`: Código único del encuentro
- **Respuesta Exitosa** (200):
  ```json
  {
    "id": 0,
    "codigo": "string",
    "tipo": "string",
    "deporte": "string",
    "estado": "string",
    "fechaProgramada": "string",
    "canchaId": 0,
    "nombreCanchaTexto": "string",
    "creadorId": 0,
    "equipoLocalId": 0,
    "equipoVisitanteId": 0,
    "maxJugadores": 0,
    "jugadoresActuales": 0
  }
  ```

## Gestión de Ligas

### Obtener Clasificación de una Liga
- **Endpoint**: `GET /api/v1/ligas/{ligaId}/clasificacion`
- **Descripción**: Obtiene la tabla de posiciones de una liga específica
- **Headers**:
  - `Authorization: Bearer <token>`
- **Parámetros de Ruta**:
  - `ligaId`: ID de la liga
- **Respuesta Exitosa** (200):
  ```json
  [
    {
      "equipoId": 0,
      "nombreEquipo": "string",
      "puntos": 0,
      "partidosJugados": 0,
      "partidosGanados": 0,
      "partidosEmpatados": 0,
      "partidosPerdidos": 0
    }
  ]
  ```

## Errores Comunes

### Errores de Autenticación
- `401 Unauthorized`: Token JWT inválido o expirado
- `403 Forbidden`: Permiso insuficiente para realizar la operación

### Errores de Validación
- `400 Bad Request`: Datos de entrada inválidos

### Errores de Recurso
- `404 Not Found`: Recurso no encontrado (equipo, encuentro, etc.)
- `409 Conflict`: Recurso duplicado (email ya registrado, etc.)

## Notas Importantes

1. **Versión de la API**: La mayoría de los endpoints (excepto autenticación) usan el prefijo `/v1` en la URL
2. **JWT Token**: Todos los endpoints protegidos requieren el JWT token en el header `Authorization: Bearer <token>`
3. **Codificación de Fechas**: Las fechas deben seguir el formato ISO 8601 (por ejemplo, "2025-12-04T15:30:00")
4. **Roles de Usuario**: Muchos endpoints requieren el rol `USER` para acceder

## Ejemplos de Uso en Flutter

### Ejemplo de petición GET con token:
```dart
final response = await http.get(
  Uri.parse('http://localhost:8080/api/v1/matches'),
  headers: {
    'Authorization': 'Bearer $jwtToken',
    'Content-Type': 'application/json',
  },
);
```

### Ejemplo de petición POST con token:
```dart
final response = await http.post(
  Uri.parse('http://localhost:8080/api/v1/teams'),
  headers: {
    'Authorization': 'Bearer $jwtToken',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'nombre': 'Equipo A',
    'deporte': 'FUTBOL',
  }),
);
```

## Actualización de Frontend

Para que el frontend funcione correctamente, se deben actualizar las URLs en el archivo `api_service.dart` con las rutas correctas:

```dart
class ApiService {
  final String _baseUrl = "http://10.0.2.2:8080/api";
  
  // Autenticación
  Future<http.Response> login(Map<String, dynamic> data) => post('auth/login', data);
  Future<http.Response> register(Map<String, dynamic> data) => post('auth/registro', data);
  
  // Equipos
  Future<http.Response> getMisEquipos() => get('v1/teams/mios');
  Future<http.Response> crearEquipo(Map<String, dynamic> data) => post('v1/teams', data);
  
  // Partidos/Encuentros
  Future<http.Response> getPartidos() => get('v1/matches');
  Future<http.Response> crearEncuentro(Map<String, dynamic> data) => post('v1/matches', data);
}
```