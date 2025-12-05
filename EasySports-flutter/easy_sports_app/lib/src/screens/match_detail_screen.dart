import 'dart:convert';
import 'package:easy_sports_app/src/models/match.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/services/auth_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MatchDetailScreen extends StatefulWidget {
  final Match match;

  const MatchDetailScreen({super.key, required this.match});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  late Match _currentMatch;
  List<dynamic> _participants = [];
  bool _isLoading = true;
  bool _isCreator = false;
  int? _currentUserId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentMatch = widget.match;
    _fetchMatchDetails();
  }

  Future<void> _fetchMatchDetails() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      _currentUserId = await _authService.getUserId();
      _isCreator = _currentMatch.creadorId == _currentUserId;

      // Nota: Este endpoint no existe en el backend actual (v1.0)
      // El backend no tiene un endpoint específico para obtener participantes por ID de encuentro
      // Se podría obtener el encuentro con sus detalles usando getEncuentroPorCodigo
      final response = await _apiService.getEncuentroPorCodigo(_currentMatch.codigo);
      if (response.statusCode == 200) {
        // Procesar la respuesta del encuentro
        final contentType = response.headers['content-type'];
        if (contentType != null && contentType.contains('application/json')) {
          final jsonData = jsonDecode(response.body);
          // Actualizar el encuentro actual con los datos nuevos
          setState(() {
            _currentMatch = Match.fromJson(jsonData);
          });
        } else {
          setState(() {
            _errorMessage = 'Formato de respuesta inesperado';
          });
        }
      } else {
        // Manejar respuestas de error
        final contentType = response.headers['content-type'];
        String errorMessage = 'Error al cargar los detalles del encuentro';

        if (contentType != null && contentType.contains('application/json')) {
          // Si es JSON, extraer el mensaje de error
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'Error en la obtención de datos';
        } else {
          // Si es texto plano, usar el cuerpo de la respuesta
          errorMessage = response.body.isNotEmpty
            ? response.body
            : 'Código de error: ${response.statusCode}';
        }

        setState(() {
          _errorMessage = errorMessage;
        });
      }
    } catch (e) {
      // Manejar error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _registerResult(Map<String, dynamic> resultData) async {
    // ... (lógica existente)
  }

  void _showRegisterResultDialog() {
    // ... (lógica existente)
  }

  void _showFormalResultDialog() {
    // ... (lógica existente)
  }

  void _showCasualResultDialog() {
    // ... (lógica existente)
  }

  @override
  Widget build(BuildContext context) {
    final bool canRegisterResult = _isCreator && _currentMatch.estado != 'FINALIZADO';

    return Scaffold(
      appBar: AppBar(title: Text(_currentMatch.codigo)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchMatchDetails,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchMatchDetails,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ... (código de detalles existente)
                      ],
                    ),
                  ),
                ),
      floatingActionButton: canRegisterResult
          ? FloatingActionButton.extended(
              onPressed: _showRegisterResultDialog,
              label: const Text('Registrar Resultado'),
              icon: const Icon(Icons.check),
            )
          : null,
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    // ... (código de detalles existente)
    return Container();
  }
}
