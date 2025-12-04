import 'dart:convert';
import 'package:easy_sports_app/src/models/liga.dart';
import 'package:easy_sports_app/src/models/tabla_posiciones.dart';
import 'package:easy_sports_app/src/services/api_service.dart';

class LigaService {
  final ApiService _apiService = ApiService();

  Future<Liga> createLiga(Map<String, dynamic> data) async {
    final response = await _apiService.post('/ligas', data);
    if (response.statusCode == 201) {
      return Liga.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create liga: ${response.statusCode}');
    }
  }

  Future<List<Liga>> getLigas() async {
    final response = await _apiService.get('/ligas');
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Liga.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load ligas: ${response.statusCode}');
    }
  }

  Future<Liga> getLigaById(int id) async {
    final response = await _apiService.get('/ligas/$id');
    if (response.statusCode == 200) {
      return Liga.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load liga: ${response.statusCode}');
    }
  }

  Future<List<TablaPosiciones>> getTablaPosiciones(int ligaId) async {
    final response = await _apiService.get('/ligas/$ligaId/tabla-posiciones');
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => TablaPosiciones.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tabla posiciones: ${response.statusCode}');
    }
  }

  Future<void> joinLiga(int ligaId, Map<String, dynamic> data) async {
    final response = await _apiService.post('/ligas/$ligaId/unirse', data);
    if (response.statusCode != 200) {
      throw Exception('Failed to join liga: ${response.statusCode}');
    }
  }
}