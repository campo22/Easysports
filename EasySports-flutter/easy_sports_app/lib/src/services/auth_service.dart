import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // TODO: Usar variable de entorno o configuración para la URL base
  // Para emulador Android usar 10.0.2.2, para iOS localhost
  static const String baseUrl = 'http://localhost:8080/api/auth';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al iniciar sesión: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register(String nombre, String email, String password) async {
    final url = Uri.parse('$baseUrl/registro');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'email': email,
        'password': password,
        // 'rol': 'USER' // Asumiendo que el backend asigna rol por defecto o se envía aquí
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al registrarse: ${response.body}');
    }
  }
}
