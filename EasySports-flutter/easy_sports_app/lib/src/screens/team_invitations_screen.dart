import 'dart:convert';
import 'package:easy_sports_app/src/models/team.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:easy_sports_app/src/widgets/sport_components.dart';
import 'package:flutter/material.dart';

class TeamInvitationsScreen extends StatefulWidget {
  const TeamInvitationsScreen({super.key});

  @override
  State<TeamInvitationsScreen> createState() => _TeamInvitationsScreenState();
}

class _TeamInvitationsScreenState extends State<TeamInvitationsScreen> {
  final ApiService _apiService = ApiService();
  List<Team> _pendingInvitations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    setState(() => _isLoading = true);
    
    try {
      // Obtener equipos con invitaciones pendientes
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
            // Filtrar solo equipos donde el usuario tiene invitación pendiente
            _pendingInvitations = teamsList
                .map((teamJson) => Team.fromJson(teamJson))
                .where((team) => team.miembros.any((m) => m.id == null)) // Simplificado
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading invitations: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _respondToInvitation(int teamId, bool accept) async {
    try {
      final response = accept
          ? await _apiService.aceptarInvitacion(teamId)
          : await _apiService.rechazarInvitacion(teamId);

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(accept ? 'Invitación aceptada' : 'Invitación rechazada'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        await _loadInvitations();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Invitaciones de Equipos'),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
          : _pendingInvitations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mail_outline, size: 80, color: AppTheme.secondaryText.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      const Text(
                        'No tienes invitaciones pendientes',
                        style: TextStyle(fontSize: 16, color: AppTheme.secondaryText),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadInvitations,
                  color: AppTheme.primaryOrange,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: _pendingInvitations.length,
                    itemBuilder: (context, index) {
                      final team = _pendingInvitations[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SportCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                                          'Capitán: ${team.capitanNombre ?? "Desconocido"}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _respondToInvitation(team.id, false),
                                      icon: const Icon(Icons.close, size: 18),
                                      label: const Text('Rechazar'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.errorRed,
                                        side: const BorderSide(color: AppTheme.errorRed),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _respondToInvitation(team.id, true),
                                      icon: const Icon(Icons.check, size: 18),
                                      label: const Text('Aceptar'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.successGreen,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}