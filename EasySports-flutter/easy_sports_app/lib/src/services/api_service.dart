import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 1. Si usas el emulador de Android, `10.0.2.2` apunta al `localhost` de tu máquina.
  // 2. Si usas un dispositivo físico, reemplaza `10.0.2.2` con la IP de tu máquina.
  final String _baseUrl = "http://10.0.2.2:8080/api";

  // Guarda el token en el almacenamiento persistente.
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // Elimina el token del almacenamiento.
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // Método privado para construir las cabeceras con el token.
  // Lee el token directamente de SharedPreferences cada vez.
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Métodos específicos para los endpoints del backend
  // Autenticación
  Future<http.Response> login(Map<String, dynamic> data) => post('auth/login', data);
  Future<http.Response> register(Map<String, dynamic> data) => post('auth/registro', data);
  Future<http.Response> updateProfile(Map<String, dynamic> data) => put('auth/profile', data);

  // Equipos
  Future<http.Response> getMisEquipos() => get('v1/teams/mios');
  Future<http.Response> getAllTeams() => get('v1/teams');
  Future<http.Response> crearEquipo(Map<String, dynamic> data) => post('v1/teams', data);
  Future<http.Response> getEquipoPorId(int equipoId) => get('v1/teams/$equipoId');
  Future<http.Response> actualizarEquipo(int equipoId, Map<String, dynamic> data) => put('v1/teams/$equipoId', data);
  Future<http.Response> invitarMiembro(int equipoId, Map<String, dynamic> data) => post('v1/teams/$equipoId/invitar', data);
  Future<http.Response> aceptarInvitacion(int equipoId) => put('v1/teams/$equipoId/invitaciones/aceptar', {});
  Future<http.Response> rechazarInvitacion(int equipoId) => put('v1/teams/$equipoId/invitaciones/rechazar', {});
  Future<http.Response> expulsarMiembro(int equipoId, int usuarioId) => delete('v1/teams/$equipoId/miembro/$usuarioId');

  // Encuentros/Partidos
  Future<http.Response> getPartidos([Map<String, String>? queryParams]) => getWithParams('v1/matches', queryParams);
  Future<http.Response> getEquipoPorIdConEstado(int id) => get('v1/teams/$id');
  Future<http.Response> getEncuentroPorCodigo(String codigo) => get('v1/matches/$codigo');
  Future<http.Response> crearEncuentro(Map<String, dynamic> data) => post('v1/matches', data);
  Future<http.Response> unirseAEncuentro(String codigo) => post('v1/matches/$codigo/unirse', {});
  Future<http.Response> registrarResultado(String codigoEncuentro, Map<String, dynamic> data) => put('v1/matches/$codigoEncuentro/resultados', data);

  // Ligas
  Future<http.Response> getClasificacionLiga(int ligaId) => get('v1/ligas/$ligaId/clasificacion');

  // Perfil de usuario
  Future<http.Response> getPerfilUsuario() => get('v1/perfil');

  // Métodos genéricos para mantener compatibilidad
  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$_baseUrl/$endpoint'), headers: headers);
    return response;
  }

  Future<http.Response> getWithParams(String endpoint, Map<String, String>? params) async {
    final headers = await _getHeaders();
    final uri = params != null
        ? Uri.parse('$_baseUrl/$endpoint').replace(queryParameters: params)
        : Uri.parse('$_baseUrl/$endpoint');
    final response = await http.get(uri, headers: headers);
    return response;
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response;
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response;
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$_baseUrl/$endpoint'), headers: headers);
    return response;
  }
}
