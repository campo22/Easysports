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
  // Variable para almacenar el ID numérico del usuario si no está en el token
  int? _numericUserId;

  // Intentar obtener ID numérico o string - ahora buscamos también en campos comunes
  dynamic get userId {
    // Primero intentamos obtenerlo del token JWT
    final rawUserId = _decodedToken?['id'] ??
                      _decodedToken?['userId'] ??
                      _decodedToken?['sub']; // 'sub' es el subject del JWT, usualmente el ID o email

    // Si ya tenemos el ID numérico almacenado en caché, lo devolvemos
    if (_numericUserId != null) {
      return _numericUserId;
    }

    // Intentar convertir a int si es posible
    if (rawUserId is String) {
      if (rawUserId.contains('@')) {
        // Este es un email, no un ID numérico
        // En lugar de solo mostrar un warning, intentamos obtener el ID real del backend
        debugPrint('⚠️ ADVERTENCIA: El token JWT contiene email, intentando obtener ID real desde el backend...');
        // El ID real se obtendrá a través del endpoint de perfil cuando sea necesario
        return rawUserId;
      } else {
        // Podría ser un ID en formato string, intentamos convertirlo
        try {
          final parsedId = int.parse(rawUserId);
          _numericUserId = parsedId; // Almacenamos en caché
          return parsedId;
        } catch (e) {
          // Si no se puede parsear a entero, lo dejamos como string
          debugPrint('❌ No se pudo convertir a entero: $rawUserId');
          return rawUserId;
        }
      }
    }

    return rawUserId;
  }

  // Método para obtener el ID numérico real del usuario desde el backend
  Future<int?> fetchNumericUserId() async {
    if (_numericUserId != null) {
      return _numericUserId;
    }

    try {
      // Creamos temporalmente una instancia de ApiService para obtener el perfil
      final apiService = ApiService();
      final response = await apiService.get('v1/perfil');

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        final numericId = userData['id'] as int?;
        _numericUserId = numericId;
        debugPrint('✅ ID numérico del usuario obtenido desde el backend: $numericId');
        return numericId;
      } else {
        debugPrint('❌ Error al obtener ID del usuario desde el backend: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error al intentar obtener ID del usuario desde el backend: $e');
      return null;
    }
  }

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
