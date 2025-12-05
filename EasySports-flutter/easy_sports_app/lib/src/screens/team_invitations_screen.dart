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
    _fetchPendingInvitations();
  }

  Future<void> _fetchPendingInvitations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Este endpoint no existe en la implementación actual del backend
      // El backend tiene endpoints para aceptar/rechazar pero no para obtener las invitaciones pendientes
      // Por ahora, usaremos getMisEquipos y filtraremos por estado
      
      final response = await _apiService.getMisEquipos();
      if (response.statusCode == 200) {
        final responseBody = response.body;
        final List<dynamic> jsonData = responseBody.isNotEmpty ? jsonDecode(responseBody) : [];
        
        setState(() {
          // Filtrar solo equipos donde el estado es 'INVITADO_PENDIENTE' (esto es hipotético)
          // En la implementación actual, el backend no devuelve el estado de membresía
          _pendingInvitations = jsonData.map((teamJson) => Team.fromJson(teamJson)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar invitaciones: $e')),
      );
    }
  }

  Future<void> _acceptInvitation(int equipoId) async {
    try {
      final response = await _apiService.aceptarInvitacion(equipoId);
      if (response.statusCode == 200) {
        setState(() {
          _pendingInvitations.removeWhere((team) => team.id == equipoId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invitación aceptada correctamente')),
        );
        _fetchPendingInvitations(); // Refrescar la lista
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al aceptar invitación: $e')),
      );
    }
  }

  Future<void> _rejectInvitation(int equipoId) async {
    try {
      final response = await _apiService.rechazarInvitacion(equipoId);
      if (response.statusCode == 200) {
        setState(() {
          _pendingInvitations.removeWhere((team) => team.id == equipoId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invitación rechazada')),
        );
        _fetchPendingInvitations(); // Refrescar la lista
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al rechazar invitación: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitaciones a Equipos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingInvitations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: AppTheme.secondaryText),
                      SizedBox(height: 16),
                      Text(
                        'No tienes invitaciones pendientes',
                        style: TextStyle(fontSize: 16, color: AppTheme.secondaryText),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchPendingInvitations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _pendingInvitations.length,
                    itemBuilder: (context, index) {
                      final invitation = _pendingInvitations[index];
                      return Card(
                        color: AppTheme.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Icon(Icons.group, color: AppTheme.primaryOrange, size: 40),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      invitation.nombre,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Deporte: ${invitation.deporte}',
                                      style: const TextStyle(
                                        color: AppTheme.secondaryText,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => _acceptInvitation(invitation.id),
                                    icon: const Icon(Icons.check, color: Colors.green),
                                    tooltip: 'Aceptar',
                                  ),
                                  IconButton(
                                    onPressed: () => _rejectInvitation(invitation.id),
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    tooltip: 'Rechazar',
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