import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<Map<String, dynamic>?> _getDecodedToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token != null && !JwtDecoder.isExpired(token)) {
      return JwtDecoder.decode(token);
    }
    return null;
  }

  Future<int?> getUserId() async {
    final tokenData = await _getDecodedToken();
    if (tokenData != null) {
      // La clave 'sub' es el estándar para el ID de usuario en JWT.
      final userId = tokenData['sub'] ?? tokenData['id'];
      return userId is int ? userId : int.tryParse(userId.toString());
    }
    return null;
  }

  Future<String?> getUserName() async {
    final tokenData = await _getDecodedToken();
    // Asumo que el nombre viene en la clave 'nombreCompleto' o 'name'.
    return tokenData?['nombreCompleto'] ?? tokenData?['name'] ?? 'Usuario';
  }

  Future<String?> getUserEmail() async {
    final tokenData = await _getDecodedToken();
    // La clave 'email' es bastante estándar.
    return tokenData?['email'] ?? 'email@example.com';
  }
}
