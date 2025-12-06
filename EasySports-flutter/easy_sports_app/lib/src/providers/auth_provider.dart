import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  String? _token;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _decodedToken;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  
  String? _localName;
  String? _localEmail;

  String? get userName => _localName ?? _decodedToken?['nombre'] ?? _decodedToken?['sub'];
  String? get userEmail => _localEmail ?? _decodedToken?['email'] ?? _decodedToken?['sub'];
  // Intentar obtener ID numérico o string
  dynamic get userId => _decodedToken?['id'] ?? _decodedToken?['userId'];

  void updateLocalUser({String? name, String? email}) {
    if (name != null) _localName = name;
    if (email != null) _localEmail = email;
    notifyListeners();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');

    if (_token != null && !JwtDecoder.isExpired(_token!)) {
      _isAuthenticated = true;
      _decodedToken = JwtDecoder.decode(_token!);
    } else {
      _isAuthenticated = false;
      _token = null;
      _decodedToken = null;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _authService.login(email, password);
      // El backend devuelve { "token": "..." }
      final token = response['token']; 
      await _saveToken(token);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(
    String nombreCompleto, 
    String email, 
    String password,
    String sexo,
    int edadAnios,
    int edadMeses,
  ) async {
    try {
      final response = await _authService.register(
        nombreCompleto, 
        email, 
        password,
        sexo,
        edadAnios,
        edadMeses,
      );
      // El backend devuelve { "token": "..." }
      final token = response['token'];
      await _saveToken(token);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    _token = token;
    _isAuthenticated = true;
    _decodedToken = JwtDecoder.decode(token);
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    _token = null;
    _isAuthenticated = false;
    _decodedToken = null;
    _localName = null;
    _localEmail = null;
    notifyListeners();
  }
}
