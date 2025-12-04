import 'dart:convert';
import 'package:easy_sports_app/src/models/match.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:flutter/material.dart';

class MatchDetailScreen extends StatefulWidget {
  final String matchCode;

  const MatchDetailScreen({super.key, required this.matchCode});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  final ApiService _apiService = ApiService();
  Match? _match;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMatchDetails();
  }

  Future<void> _fetchMatchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.get('v1/matches/${widget.matchCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _match = Match.fromJson(data);
        });
      } else {
        setState(() {
          _errorMessage = 'Error al cargar detalles del partido: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _joinMatch() async {
    setState(() {
      _isLoading = true; // Para deshabilitar el botón y mostrar progreso
    });
    try {
      final response = await _apiService.post('v1/matches/${widget.matchCode}/join', {});

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Te has unido al partido exitosamente!')),
        );
        _fetchMatchDetails(); // Refrescar los detalles del partido
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al unirse: ${errorData['reason'] ?? errorData['message'] ?? 'Error desconocido'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_match?.codigo ?? 'Detalle del Partido'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      ElevatedButton(
                        onPressed: _fetchMatchDetails,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _match == null
                  ? const Center(child: Text('Partido no encontrado.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Código:', _match!.codigo),
                          _buildDetailRow('Deporte:', _match!.deporte),
                          _buildDetailRow('Tipo:', _match!.tipo),
                          _buildDetailRow('Estado:', _match!.estado),
                          _buildDetailRow('Fecha Programada:',
                              _match!.fechaProgramada.toLocal().toString().split('.')[0]),
                          _buildDetailRow('Creador ID:', _match!.creadorId.toString()),
                          _buildDetailRow('Jugadores:', '${_match!.jugadoresActuales}/${_match!.maxJugadores}'),
                          if (_match!.nombreCanchaTexto != null && _match!.nombreCanchaTexto!.isNotEmpty)
                            _buildDetailRow('Cancha:', _match!.nombreCanchaTexto!),
                          if (_match!.canchaId != null)
                            _buildDetailRow('ID Cancha:', _match!.canchaId.toString()),
                          if (_match!.equipoLocalId != null)
                            _buildDetailRow('ID Equipo Local:', _match!.equipoLocalId.toString()),
                          if (_match!.equipoVisitanteId != null)
                            _buildDetailRow('ID Equipo Visitante:', _match!.equipoVisitanteId.toString()),
                          const SizedBox(height: 32.0),
                          _match!.estado == 'ABIERTO' && _match!.jugadoresActuales < _match!.maxJugadores
                              ? Center(
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _joinMatch,
                                    child: _isLoading
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : const Text('Unirse al Partido'),
                                  ),
                                )
                              : Container(), // No mostrar botón si el partido no está abierto o está lleno
                        ],
                      ),
                    ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}