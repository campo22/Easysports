import 'dart:convert';
import 'package:easy_sports_app/src/models/match.dart';
import 'package:easy_sports_app/src/screens/match_detail_screen.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:easy_sports_app/src/widgets/sport_components.dart';
import 'package:flutter/material.dart';

class AllMatchesScreen extends StatefulWidget {
  const AllMatchesScreen({super.key});

  @override
  State<AllMatchesScreen> createState() => _AllMatchesScreenState();
}

class _AllMatchesScreenState extends State<AllMatchesScreen> {
  final ApiService _apiService = ApiService();
  List<Match> _matches = [];
  bool _isLoading = true;
  int _selectedSportIndex = 0;
  String? _errorMessage;

  // Se mantiene la misma lista de deportes para consistencia
  final List<Map<String, dynamic>> _sports = [
    {'name': 'TODOS', 'icon': Icons.sports},
    {'name': 'FUTBOL', 'icon': Icons.sports_soccer},
    {'name': 'BASKET', 'icon': Icons.sports_basketball},
    {'name': 'VOLEY', 'icon': Icons.sports_volleyball},
  ];

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getPartidos();
      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> matchesList = jsonData['content'] ?? [];
        if (mounted) {
          setState(() {
            _matches = matchesList.map((matchJson) => Match.fromJson(matchJson)).toList();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error del servidor: ${response.statusCode}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error de conexión: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  List<Match> get _filteredMatches {
    if (_selectedSportIndex == 0) return _matches;
    final sportName = _sports[_selectedSportIndex]['name'] as String;
    return _matches.where((m) => m.deporte.toUpperCase() == sportName).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Todos los Partidos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
          : _errorMessage != null
              ? _buildErrorState()
              : Column(
                  children: [
                    _buildCategories(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchMatches,
                        color: AppTheme.primaryOrange,
                        child: _filteredMatches.isEmpty
                            ? const Center(child: Text('No hay partidos para el filtro seleccionado.'))
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredMatches.length,
                                itemBuilder: (context, index) {
                                  return _buildMatchCard(_filteredMatches[index]);
                                },
                              ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 60),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: const TextStyle(fontSize: 16, color: AppTheme.secondaryText)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchMatches,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _sports.length,
        itemBuilder: (context, index) {
          final sport = _sports[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SportCategoryIcon(
              icon: sport['icon'] as IconData,
              label: sport['name'] as String,
              isSelected: _selectedSportIndex == index,
              onTap: () {
                setState(() {
                  _selectedSportIndex = index;
                });
              },
            ),
          );
        },
      ),
    );
  }

  String _buildMatchTitle(Match match) {
    if (match.tipo == 'FORMAL') {
      final local = match.equipoLocalNombre ?? 'Equipo Local';
      final visitante = match.equipoVisitanteNombre ?? 'Equipo Visitante';
      return '$local vs. $visitante';
    } else {
      return 'Partido de ${match.deporte}';
    }
  }

  Widget _buildMatchCard(Match match) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchDetailScreen(match: match),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getSportIcon(match.deporte), color: AppTheme.primaryOrange, size: 18),
                const SizedBox(width: 8),
                Text(
                  match.deporte.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _buildMatchTitle(match),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, color: AppTheme.secondaryText, size: 16),
                const SizedBox(width: 8),
                Text(
                  TimeOfDay.fromDateTime(match.fechaProgramada).format(context),
                  style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: AppTheme.secondaryText, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    match.nombreCanchaTexto ?? 'Ubicación por definir',
                    style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(
                text: match.estado,
                color: match.estado == 'ABIERTO' ? AppTheme.activeGreen : AppTheme.closedRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getSportIcon(String deporte) {
    final sport = deporte.toUpperCase();
    if (sport.contains('FUTBOL') || sport.contains('SOCCER')) {
      return Icons.sports_soccer;
    } else if (sport.contains('BASKET')) {
      return Icons.sports_basketball;
    } else if (sport.contains('TENIS')) {
      return Icons.sports_tennis;
    } else if (sport.contains('VOLEY')) {
      return Icons.sports_volleyball;
    }
    return Icons.sports;
  }
}
