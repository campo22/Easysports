import 'dart:convert';
import 'package:http/http.dart' as http;

import 'dart:io';

class AuthService {
  
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api/auth';
    }
    return 'http://localhost:8080/api/auth';
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
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
        throw Exception('Error al iniciar sesión (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión a $url: $e');
    }
  }

  Future<Map<String, dynamic>> register(
    String nombreCompleto, 
    String email, 
    String password,
    String sexo,
    int edadAnios,
    int edadMeses,
  ) async {
    final url = Uri.parse('$baseUrl/registro');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombreCompleto': nombreCompleto,
          'email': email,
          'password': password,
          'sexo': sexo,
          'edadAnios': edadAnios,
          'edadMeses': edadMeses,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al registrarse (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión a $url: $e');
    }
  }
}
