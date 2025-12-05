import 'dart:convert';
import 'package:easy_sports_app/src/models/match.dart';
import 'package:easy_sports_app/src/screens/match_detail_screen.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchesDashboardScreen extends StatefulWidget {
  const MatchesDashboardScreen({Key? key}) : super(key: key);

  @override
  MatchesDashboardScreenState createState() => MatchesDashboardScreenState();
}

class MatchesDashboardScreenState extends State<MatchesDashboardScreen> {
  final ApiService _apiService = ApiService();
  List<Match> _matches = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.get('partidos');
      if (!mounted) return;
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _matches = jsonResponse.map((matchJson) => Match.fromJson(matchJson)).toList();
        });
      } else {
        setState(() {
          _errorMessage = 'Error del servidor: ${response.statusCode}. ${response.body}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        // --- MENSAJE DE ERROR MEJORADO ---
        _errorMessage = 'No se pudo conectar al servidor. Asegúrate de que el backend esté funcionando en localhost:8080. Error: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _joinMatch(String code) {
    // ... (código existente)
    return Future.value();
  }

  void _showJoinMatchDialog() {
    // ... (código existente)
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildMatchesView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            const Text('¡Oops! Algo salió mal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(_errorMessage!, style: const TextStyle(fontSize: 16, color: AppTheme.secondaryText), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: fetchMatches, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchesView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        Expanded(
          child: _matches.isEmpty
              ? const Center(child: Text('No hay partidos disponibles.'))
              : RefreshIndicator(
                  onRefresh: fetchMatches,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _matches.length,
                    itemBuilder: (context, index) {
                      final match = _matches[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MatchDetailScreen(match: match),
                            ),
                          );
                        },
                        child: _MatchCard(match: match),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Partidos Disponibles',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.input), onPressed: _showJoinMatchDialog, tooltip: 'Unirse por código'),
              IconButton(icon: const Icon(Icons.refresh), onPressed: fetchMatches, tooltip: 'Refrescar'),
            ],
          )
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final Match match;
  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMMM / h:mm a').format(match.fechaProgramada);

    return Card(
      color: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ... (código de la tarjeta)
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    // ... (código del chip)
    return Container();
  }
}
