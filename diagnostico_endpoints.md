# Diagnóstico de endpoints del backend EasySports

## Endpoints que funcionan:
- POST /api/auth/login
- POST /api/auth/register
- POST /api/equipos (crear equipo)

## Endpoints que podrían tener problemas:
- GET /api/partidos (obtener partidos)
- GET /api/equipos/mis-equipos (obtener equipos del usuario)
- GET /api/encuentros/{id}/participantes (obtener participantes de encuentro)

## Pasos para diagnosticar el problema:

### 1. Verificar que el backend esté corriendo
- Asegúrate que el backend esté ejecutándose en el puerto 8080
- Verifica que puedes acceder a http://localhost:8080 desde tu navegador

### 2. Probar endpoints con herramienta como Postman o curl:
```bash
# Prueba de login (funciona según dices)
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"tu_email@ejemplo.com", "password":"tu_contrasena"}'

# Prueba de equipos del usuario (posible problema)
curl -X GET http://localhost:8080/api/equipos/mis-equipos \
  -H "Authorization: Bearer TU_TOKEN_JWT"

# Prueba de partidos (posible problema)
curl -X GET http://localhost:8080/api/partidos \
  -H "Authorization: Bearer TU_TOKEN_JWT"
```

### 3. Posibles causas del problema:

#### a) Endpoints inexistentes:
El frontend puede estar usando endpoints que aún no están implementados en el backend.

#### b) Problemas de autenticación:
Algunos endpoints requieren JWT válido, verifica que:
- El token esté correctamente almacenado en shared_preferences
- El token no haya expirado
- El header de autorización esté correctamente formateado

#### c) Diferencias en la estructura de datos:
El backend puede devolver datos con una estructura diferente a la esperada por el frontend.

#### d) Errores del servidor:
El servidor puede estar devolviendo errores HTTP 500 u otros errores internos.

### 4. Soluciones a intentar:

#### a) Verificar logs del backend:
Revisa los logs del servidor Spring Boot para ver si hay errores o excepciones cuando haces las peticiones.

#### b) Comparar documentación:
Asegúrate de que los endpoints usados en el frontend coincidan exactamente con los implementados en el backend.

#### c) Usar herramienta de API como Postman para probar manualmente cada endpoint.

### 5. Verificación específica de endpoints:

#### Endpoint que carga los partidos (matches_dashboard_screen.dart):
- Endpoint: GET /api/partidos
- Requiere: Token JWT en headers
- Debe devolver: Lista de partidos en formato JSON

#### Endpoint que carga equipos del usuario (user_teams_screen.dart):
- Endpoint: GET /api/equipos/mis-equipos
- Requiere: Token JWT en headers
- Debe devolver: Lista de equipos en formato JSON

#### Endpoint que carga participantes (match_detail_screen.dart):
- Endpoint: GET /api/encuentros/{id}/participantes
- Requiere: Token JWT en headers
- Debe devolver: Lista de participantes en formato JSON