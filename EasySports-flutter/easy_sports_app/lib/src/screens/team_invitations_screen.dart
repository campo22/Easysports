import 'dart:convert';
import 'package:easy_sports_app/src/models/team.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
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
      debugPrint('🔍 Respuesta getMisEquipos: ${response.statusCode}');
      
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

        debugPrint('📋 Total equipos recibidos: ${teamsList.length}');

        if (mounted) {
          setState(() {
            // Mostrar todos los equipos en los que el usuario está involucrado
            // Puede ser como miembro activo o con invitación pendiente
            final allTeams = teamsList.map((teamJson) => Team.fromJson(teamJson)).toList();

            debugPrint('🔍 Equipos antes de filtrar:');
            for (var team in allTeams) {
              debugPrint('  - ${team.nombre}: estadoMiembro=${team.estadoMiembro}');
            }

            // Mostrar todos los equipos, no solo las invitaciones pendientes
            _pendingInvitations = allTeams;

            debugPrint('✅ Equipos totales mostrados: ${_pendingInvitations.length}');
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading invitations: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _respondToInvitation(int teamId, bool accept) async {
    debugPrint('🔔 Intentando ${accept ? "aceptar" : "rechazar"} invitación para equipo ID: $teamId');
    
    try {
      final response = accept
          ? await _apiService.aceptarInvitacion(teamId)
          : await _apiService.rechazarInvitacion(teamId);

      debugPrint('📡 Respuesta del servidor: ${response.statusCode}');
      debugPrint('📡 Body: ${response.body}');

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(accept ? '✅ Invitación aceptada' : '❌ Invitación rechazada'),
            backgroundColor: accept ? AppTheme.successGreen : AppTheme.secondaryText,
          ),
        );
        await _loadInvitations();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Código ${response.statusCode} - ${response.body}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al responder invitación: $e');
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
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: AppTheme.primaryText, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
          : _pendingInvitations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 80, color: AppTheme.secondaryText.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      const Text(
                        'No tienes notificaciones',
                        style: TextStyle(fontSize: 18, color: AppTheme.primaryText, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Las invitaciones a equipos aparecerán aquí',
                        style: TextStyle(fontSize: 14, color: AppTheme.secondaryText),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadInvitations,
                  color: AppTheme.primaryOrange,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _pendingInvitations.length,
                    itemBuilder: (context, index) {
                      final team = _pendingInvitations[index];
                      return _buildInvitationCard(team);
                    },
                  ),
                ),
    );
  }

  Widget _buildInvitationCard(Team team) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.cardBackground,
            AppTheme.cardBackground.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryOrange.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppTheme.orangeGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryOrange.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      team.nombre.isNotEmpty ? team.nombre[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Invitación a equipo',
                        style: TextStyle(
                          color: AppTheme.secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        team.nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          team.tipoDeporte.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primaryOrange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (team.estadoMiembro == 'INVITADO_PENDIENTE')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _respondToInvitation(team.id, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: AppTheme.errorRed.withOpacity(0.5), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Rechazar',
                        style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _respondToInvitation(team.id, true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppTheme.successGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Aceptar',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: null, // Deshabilitado temporalmente
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppTheme.cardBackground, // Gris para indicar deshabilitado
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ver equipo',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}