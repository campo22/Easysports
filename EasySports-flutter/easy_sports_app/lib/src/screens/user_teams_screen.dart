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

        if (!mounted) return;
        setState(() {
          _userTeams = teamsList.map((teamJson) => Team.fromJson(teamJson)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading teams: $e');
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
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mis Equipos',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppTheme.primaryOrange, size: 32),
                    onPressed: _navigateToCreateTeam,
                    tooltip: 'Crear Equipo',
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
                  : _userTeams.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shield, size: 80, color: AppTheme.secondaryText.withOpacity(0.3)),
                              const SizedBox(height: 16),
                              const Text(
                                'Aún no perteneces a ningún equipo',
                                style: TextStyle(fontSize: 16, color: AppTheme.secondaryText),
                              ),
                              const SizedBox(height: 24),
                              PrimaryButton(
                                text: 'Crear mi Primer Equipo',
                                onPressed: _navigateToCreateTeam,
                                icon: Icons.add,
                              ).constrained(width: 250),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchUserTeams,
                          color: AppTheme.primaryOrange,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            itemCount: _userTeams.length,
                            itemBuilder: (context, index) {
                              final team = _userTeams[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: SportCard(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TeamDetailScreen(team: team),
                                      ),
                                    ).then((_) => _fetchUserTeams());
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryOrange.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.shield,
                                          color: AppTheme.primaryOrange,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              team.nombre,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primaryText,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${team.miembros.length} miembros',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: AppTheme.secondaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        color: AppTheme.secondaryText,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
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

