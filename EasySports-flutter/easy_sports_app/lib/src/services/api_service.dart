import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String _baseUrl = "http://localhost:8080/api"; // Reemplazar con la URL del backend
  String? _token;

  Future<void> _loadToken() async {
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('jwt_token');
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    _token = token;
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    _token = null;
  }

  Future<Map<String, String>> _getHeaders() async {
    await _loadToken();
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$_baseUrl/$endpoint'), headers: headers);
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
