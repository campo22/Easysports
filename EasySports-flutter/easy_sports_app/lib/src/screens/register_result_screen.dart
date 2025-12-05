import 'dart:convert';
import 'package:easy_sports_app/src/models/match.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterResultScreen extends StatefulWidget {
  final Match match;

  const RegisterResultScreen({
    super.key,
    required this.match,
  });

  @override
  State<RegisterResultScreen> createState() => _RegisterResultScreenState();
}

class _RegisterResultScreenState extends State<RegisterResultScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _localScoreController = TextEditingController();
  final TextEditingController _visitanteScoreController = TextEditingController();
  bool _isLoading = false;

  Future<void> _registerResult() async {
    final localScore = int.tryParse(_localScoreController.text) ?? 0;
    final visitanteScore = int.tryParse(_visitanteScoreController.text) ?? 0;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.registrarResultado(
        widget.match.id,
        {
          'equipoLocalId': widget.match.equipoLocalId,
          'equipoVisitanteId': widget.match.equipoVisitanteId,
          'resultadoLocal': localScore,
          'resultadoVisitante': visitanteScore,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Resultado registrado exitosamente!')),
        );
        Navigator.pop(context, {'local': localScore, 'visitante': visitanteScore});
      } else {
        final contentType = response.headers['content-type'];
        String errorMessage = 'Error al registrar resultado';

        if (contentType != null && contentType.contains('application/json')) {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? 'Error en el proceso de registro';
        } else {
          errorMessage = response.body.isNotEmpty
            ? response.body
            : 'Código de error: ${response.statusCode}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar resultado: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _localScoreController.dispose();
    _visitanteScoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Resultado'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: AppTheme.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      widget.match.tipo == 'FORMAL' 
                          ? '${widget.match.equipoLocalId != null ? 'Equipo Local' : 'Equipo'} vs ${widget.match.equipoVisitanteId != null ? 'Equipo Visitante' : 'Equipo'}' 
                          : 'Partido Casual',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Deporte: ${widget.match.deporte}',
                      style: const TextStyle(color: AppTheme.secondaryText),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fecha: ${DateTime.parse(widget.match.fechaProgramada.toString()).toString().split('.')[0]}',
                      style: const TextStyle(color: AppTheme.secondaryText),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Ingresa el resultado final',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        widget.match.equipoLocalId != null ? 'Local' : 'Equipo 1',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _localScoreController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          hintText: '0',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                const Text(
                  '-',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        widget.match.equipoVisitanteId != null ? 'Visitante' : 'Equipo 2',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _visitanteScoreController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          hintText: '0',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _registerResult,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Registrar Resultado',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
            const SizedBox(height: 16),
            Text(
              'El resultado se registrará y el estado del encuentro cambiará a FINALIZADO.',
              style: TextStyle(color: AppTheme.secondaryText, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}