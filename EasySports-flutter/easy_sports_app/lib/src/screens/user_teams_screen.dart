import 'dart:convert';
import 'package:easy_sports_app/src/models/team.dart';
import 'package:easy_sports_app/src/screens/create_team_screen.dart';
import 'package:easy_sports_app/src/screens/team_detail_screen.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:easy_sports_app/src/widgets/sport_components.dart';
import 'package:flutter/material.dart';

class UserTeamsScreen extends StatefulWidget {
  const UserTeamsScreen({super.key});

  @override
  State<UserTeamsScreen> createState() => UserTeamsScreenState();
}

class UserTeamsScreenState extends State<UserTeamsScreen> {
  final ApiService _apiService = ApiService();
  List<Team> _userTeams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserTeams();
  }

  Future<void> _fetchUserTeams() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getMisEquipos();
      if (response.statusCode == 200) {
        final responseBody = response.body;
        List<dynamic> teamsList = [];

        if (responseBody.isNotEmpty) {
          final jsonData = jsonDecode(responseBody);
          if (jsonData is Map && jsonData.containsKey('content')) {
            teamsList = jsonData['content'] ?? [];
          } else if (jsonData is List) {
            teamsList = jsonData;
          }
        }

        if (mounted) {
          setState(() {
            _userTeams = teamsList.map((teamJson) => Team.fromJson(teamJson)).toList();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error cargando equipos: ${response.statusCode}'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading teams: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _navigateToCreateTeam() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTeamScreen()),
    );
    if (result == true) {
      _fetchUserTeams();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark, // #1C140F
      body: Stack(
        children: [
          // Content
          Column(
            children: [
              // Custom Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                color: AppTheme.backgroundDark.withOpacity(0.9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mis Equipos',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                        fontFamily: 'Lexend', // Assuming Lexend or default
                        letterSpacing: -1.0,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A211B), // Card color
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white70),
                        onPressed: () {}, // Future settings
                      ),
                    ),
                  ],
                ),
              ),
              // List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
                    : _userTeams.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _fetchUserTeams,
                            color: AppTheme.primaryOrange,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                              itemCount: _userTeams.length,
                              itemBuilder: (context, index) {
                                return _buildTeamCard(_userTeams[index]);
                              },
                            ),
                          ),
              ),
            ],
          ),
          
          // Floating Action Button Styled
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: _navigateToCreateTeam,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryOrange.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: AppTheme.backgroundDark, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Nuevo Equipo',
                      style: TextStyle(
                        color: AppTheme.backgroundDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 80, color: AppTheme.secondaryText.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'No tienes equipos aún',
            style: TextStyle(fontSize: 18, color: AppTheme.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(Team team) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeamDetailScreen(team: team),
          ),
        ).then((_) => _fetchUserTeams());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A211B), // Card color from HTML
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Top Section: Info & Logo
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Deporte: ${team.tipoDeporte}',
                        style: TextStyle(
                          color: AppTheme.primaryOrange.withOpacity(0.8), // Amber 200/60ish
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Place holder Logo
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.2),
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: NetworkImage("https://ui-avatars.com/api/?background=random&color=fff&size=128"), // Placeholder
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      team.nombre.isNotEmpty ? team.nombre[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.1), height: 1),
            const SizedBox(height: 16),
            // Bottom Section: Stats
            Row(
              children: [
                const Icon(Icons.event_available, size: 20, color: AppTheme.primaryOrange),
                const SizedBox(width: 8),
                const Text(
                  'Próx: --', // Placeholder
                  style: TextStyle(color: AppTheme.secondaryText, fontSize: 13),
                ),
                const SizedBox(width: 24),
                const Icon(Icons.equalizer, size: 20, color: AppTheme.primaryOrange),
                const SizedBox(width: 8),
                Text(
                  'Ganados: ${team.partidosGanados}',
                  style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension WidgetExtensions on Widget {
  Widget constrained({double? width, double? height}) {
    return SizedBox(width: width, height: height, child: this);
  }
}

