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

      final response = await _apiService.get('encuentros/${_currentMatch.id}/participantes');
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = response.body.isEmpty ? [] : jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _participants = jsonResponse;
          });
        }
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
