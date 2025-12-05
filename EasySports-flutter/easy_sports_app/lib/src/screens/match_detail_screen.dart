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
                        Card(
                          color: AppTheme.cardBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _currentMatch.tipo == 'FORMAL'
                                            ? '${_currentMatch.equipoLocalId != null ? 'Equipo Local' : 'Equipo'} vs ${_currentMatch.equipoVisitanteId != null ? 'Equipo Visitante' : 'Equipo'}'
                                            : 'Partido Casual',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _currentMatch.estado == 'FINALIZADO'
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.orange.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _currentMatch.estado,
                                        style: TextStyle(
                                          color: _currentMatch.estado == 'FINALIZADO'
                                              ? Colors.green
                                              : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildDetailRow(
                                  Icons.sports_soccer,
                                  'Deporte',
                                  _currentMatch.deporte,
                                ),
                                _buildDetailRow(
                                  Icons.calendar_today,
                                  'Fecha',
                                  _formatDate(_currentMatch.fechaProgramada),
                                ),
                                _buildDetailRow(
                                  Icons.location_on,
                                  'Ubicación',
                                  _currentMatch.nombreCanchaTexto ?? 'No especificada',
                                ),
                                _buildDetailRow(
                                  Icons.people,
                                  'Jugadores',
                                  '${_currentMatch.jugadoresActuales}/${_currentMatch.maxJugadores}',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Participantes',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 200, // Altura fija para la lista de participantes
                          child: _participants.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No hay participantes aún',
                                    style: TextStyle(color: AppTheme.secondaryText),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(), // Para evitar conflictos de scroll
                                  itemCount: _participants.length,
                                  itemBuilder: (context, index) {
                                    final participant = _participants[index];
                                    return ListTile(
                                      leading: const CircleAvatar(
                                        backgroundImage: NetworkImage('https://i.pravatar.cc/50'),
                                      ),
                                      title: Text(
                                        participant['nombreCompleto'] ?? 'Usuario ${index + 1}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      trailing: participant['esCreador'] == true
                                          ? const Icon(Icons.star, color: AppTheme.primaryColor)
                                          : null,
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: canRegisterResult
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterResultScreen(match: _currentMatch),
                  ),
                );
              },
              label: const Text('Registrar Resultado'),
              icon: const Icon(Icons.check),
            )
          : null,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(color: AppTheme.primaryText),
          ),
        ],
      ),
    );
  }
}
