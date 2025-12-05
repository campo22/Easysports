import 'dart:convert';
import 'package:easy_sports_app/src/models/match.dart';
import 'package:easy_sports_app/src/screens/create_match_screen.dart';
import 'package:easy_sports_app/src/screens/join_match_screen.dart';
import 'package:easy_sports_app/src/screens/match_detail_screen.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:flutter/material.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final ApiService _apiService = ApiService();
  List<Match> _matches = [];
  bool _isLoading = true;
  List<String> _sports = ['All', 'Fútbol', 'Padel', 'Baloncesto', 'Tenis'];
  int _selectedSportIndex = 0;
  String? _errorMessage;

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
        // El backend devuelve una respuesta paginada con la estructura { content: [...] }
        final List<dynamic> matchesList = jsonData['content'] ?? [];
        setState(() {
          _matches = matchesList.map((matchJson) => Match.fromJson(matchJson)).toList();
        });
      } else {
        setState(() {
          _errorMessage = 'Error del servidor: ${response.statusCode}. ${response.body}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
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
                          onPressed: _fetchMatches,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchMatches,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 80), // Espacio para FAB
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título principal
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ready to Play?',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryText,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Botones principales
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const CreateMatchScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 3,
                                      shadowColor: AppTheme.primaryColor.withOpacity(0.3),
                                    ),
                                    child: const Text(
                                      'Create a Match',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/join-match');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: AppTheme.cardBackground,
                                      foregroundColor: AppTheme.primaryColor,
                                      side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.5)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Join a Match',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Filtros de deportes
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (int i = 0; i < _sports.length; i++)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: FilterChip(
                                        label: Text(_sports[i]),
                                        selected: _selectedSportIndex == i,
                                        selectedColor: AppTheme.primaryColor,
                                        backgroundColor: AppTheme.cardBackground,
                                        checkmarkColor: Colors.white,
                                        labelStyle: TextStyle(
                                          color: _selectedSportIndex == i 
                                              ? Colors.white 
                                              : AppTheme.primaryText,
                                        ),
                                        onSelected: (selected) {
                                          setState(() {
                                            _selectedSportIndex = selected ? i : 0;
                                          });
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Título "Your Next Matches"
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Text(
                              'Your Next Matches',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryText,
                              ),
                            ),
                          ),
                          
                          // Lista de partidos
                          _matches.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text(
                                      'No matches available',
                                      style: TextStyle(color: AppTheme.secondaryText),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _matches.length,
                                  itemBuilder: (context, index) {
                                    final match = _matches[index];
                                    return _buildMatchCard(match);
                                  },
                                ),
                          
                          // Player Spotlight (solo un ejemplo visual)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Player Spotlight',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    image: const DecorationImage(
                                      image: NetworkImage('https://i.pravatar.cc/600?img=3'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.7),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Positioned(
                                        bottom: 16,
                                        left: 16,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Alex Morgan',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '12 Goals • 8 Assists',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // League Standings (ejemplo)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'League Standings',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryText,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/league-standings');
                                      },
                                      child: const Text(
                                        'View Full Table',
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardBackground,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: const [
                                      _StandingsRow(position: '1', team: 'FC Barcelona', points: '78'),
                                      Divider(height: 1, color: AppTheme.background),
                                      _StandingsRow(position: '2', team: 'Real Madrid', points: '75'),
                                      Divider(height: 1, color: AppTheme.background),
                                      _StandingsRow(position: '3', team: 'Atletico Madrid', points: '72'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildMatchCard(Match match) {
    String sportIcon = 'sports_soccer';
    if (match.deporte.toLowerCase().contains('baloncesto') || match.deporte.toLowerCase().contains('basket')) {
      sportIcon = 'sports_basketball';
    } else if (match.deporte.toLowerCase().contains('tenis')) {
      sportIcon = 'sports_tennis';
    } else if (match.deporte.toLowerCase().contains('voley')) {
      sportIcon = 'sports_volleyball';
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchDetailScreen(match: match),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  _getSportIcon(sportIcon),
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.tipo == 'FORMAL' 
                          ? (match.equipoLocalId != null && match.equipoVisitanteId != null 
                              ? 'Equipo ${match.equipoLocalId} vs Equipo ${match.equipoVisitanteId}'
                              : 'Partido Formal')
                          : 'Partido Casual',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      Text(
                        '${match.fechaProgramada.day}/${match.fechaProgramada.month}, ${match.fechaProgramada.hour}:${match.fechaProgramada.minute.toString().padLeft(2, '0')} - ${match.nombreCanchaTexto ?? 'Ubicación no especificada'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.secondaryText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getSportIcon(String sportIcon) {
    switch (sportIcon) {
      case 'sports_basketball':
        return Icons.sports_basketball;
      case 'sports_tennis':
        return Icons.sports_tennis;
      case 'sports_volleyball':
        return Icons.sports_volleyball;
      default:
        return Icons.sports_soccer;
    }
  }
}

class _StandingsRow extends StatelessWidget {
  final String position;
  final String team;
  final String points;

  const _StandingsRow({
    required this.position,
    required this.team,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        children: [
          Text(
            position,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              team,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
          ),
          Text(
            points,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}