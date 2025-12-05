import 'dart:convert';

import 'package:easy_sports_app/src/models/team.dart';
import 'package:easy_sports_app/src/screens/create_team_screen.dart';
import 'package:easy_sports_app/src/screens/team_detail_screen.dart'; // Importa la nueva pantalla
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
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
      final response = await _apiService.get('equipos/mis-equipos');
      if (response.statusCode == 200) {
        // Manejo de cuerpo vacío
        final responseBody = response.body;
        final List<dynamic> jsonResponse = responseBody.isEmpty ? [] : jsonDecode(responseBody);
        if (!mounted) return;
        setState(() {
          _userTeams = jsonResponse.map((teamJson) => Team.fromJson(teamJson)).toList();
        });
      }
    } catch (e) {
      // Manejar error en un futuro
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mis Equipos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor, size: 30),
                onPressed: _navigateToCreateTeam,
                tooltip: 'Crear Equipo',
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _userTeams.isEmpty
                  ? const Center(child: Text('Aún no perteneces a ningún equipo.'))
                  : RefreshIndicator(
                      onRefresh: _fetchUserTeams,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _userTeams.length,
                        itemBuilder: (context, index) {
                          final team = _userTeams[index];
                          return Card(
                            color: AppTheme.cardBackground,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: const Icon(Icons.shield, color: AppTheme.primaryColor, size: 40),
                              title: Text(team.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Deporte: ${team.deporte}', style: const TextStyle(color: AppTheme.secondaryText)),
                              trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.secondaryText),
                              onTap: () {
                                // Navega a la pantalla de detalle del equipo
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TeamDetailScreen(team: team),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
