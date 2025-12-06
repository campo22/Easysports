import 'dart:convert';
import 'package:easy_sports_app/src/models/team.dart';
import 'package:easy_sports_app/src/screens/invite_members_screen.dart';
import 'package:easy_sports_app/src/screens/invite_player_screen.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:easy_sports_app/src/widgets/sport_components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_sports_app/src/providers/auth_provider.dart';

import 'invite_player_screen.dart';

class TeamDetailScreen extends StatefulWidget {
  final Team team;

  const TeamDetailScreen({super.key, required this.team});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  final ApiService _apiService = ApiService();
  late Team _currentTeam;
  bool _isLoading = false;
  bool _isCaptain = false;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentTeam = widget.team;
  }

  Future<void> _loadUserDataAndTeamDetails() async {
    setState(() => _isLoading = true);

    try {
      // Obtener el ID numérico real del usuario desde el AuthProvider
      final authProvider = context.read<AuthProvider>();
      _currentUserId = await authProvider.fetchNumericUserId();

      if (_currentUserId == null) {
        // Si no podemos obtener el ID del usuario, intentamos usar el del token
        _currentUserId = authProvider.userId;
        if (_currentUserId is String && (_currentUserId as String).contains('@')) {
          // Si aún es email, obtenemos el perfil del usuario
          final perfilResponse = await _apiService.getPerfilUsuario();
          if (perfilResponse.statusCode == 200) {
            final perfilData = jsonDecode(perfilResponse.body);
            _currentUserId = perfilData['id'] as int?;
          }
        }
      }

      // Cargar detalles actualizados del equipo con estado de membresía del usuario
      final response = await _apiService.getEquipoPorIdConEstado(_currentTeam.id);
      if (response.statusCode == 200) {
        final teamData = jsonDecode(response.body);
        debugPrint('🔍 Team Detail Debug:');
        debugPrint('   Current User ID: $_currentUserId');
        debugPrint('   Team Data: $teamData');
        debugPrint('   Team Captain ID: ${teamData['capitanId']}');
        debugPrint('   User Member Status: ${teamData['estadoMiembro']}');

        bool isCaptain = false;

        // Ver si el estado de membresía indica que es el capitán del equipo
        final estadoMiembro = teamData['estadoMiembro'];
        if (estadoMiembro == 'ACEPTADO') {
          // Verificamos si además es el capitán comparando los IDs
          if (_currentUserId is int && teamData['capitanId'] is int) {
            // Ambos son enteros
            isCaptain = teamData['capitanId'] == _currentUserId;
          } else if (_currentUserId is String && teamData['capitanId'] is int) {
            // ID de usuario es string (posiblemente email) pero ID de capitán es int
            debugPrint('⚠️ ID de usuario es string pero capitanId es int - intentando obtener ID real');
            // En este punto, ya intentamos obtener el ID real desde getPerfilUsuario()
            // Si aún es string, significa que el email no coincide con un ID numérico
            isCaptain = false;
          } else if (_currentUserId is int && teamData['capitanId'] is String) {
            // ID de usuario es int pero ID de capitán es string
            isCaptain = int.tryParse(teamData['capitanId']) == _currentUserId;
          } else {
            // Ambos son strings
            isCaptain = teamData['capitanId']?.toString() == _currentUserId?.toString();
          }
        }

        debugPrint('   Is Captain?: $isCaptain');

        if (mounted) {
          setState(() {
            _currentTeam = Team.fromJson(teamData);
            _isCaptain = isCaptain;
            debugPrint('   _currentTeam.capitanId: ${_currentTeam.capitanId}');
            debugPrint('   _currentUserId: $_currentUserId');
            debugPrint('   _isCaptain final: $_isCaptain');
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading team details: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  Future<void> _expelMember(TeamMember member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('Expulsar Miembro', style: TextStyle(color: AppTheme.primaryText)),
        content: Text(
          '¿Estás seguro de expulsar a ${member.nombreCompleto}?',
          style: const TextStyle(color: AppTheme.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.secondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Expulsar', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await _apiService.expulsarMiembro(_currentTeam.id, member.id);
        if (response.statusCode == 204 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Miembro expulsado'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          await _loadUserDataAndTeamDetails();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: Text(_currentTeam.nombre),
        backgroundColor: Colors.transparent,
        actions: [
          if (_isCaptain)
            IconButton(
              icon: const Icon(Icons.person_add, color: AppTheme.primaryOrange),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InviteMembersScreen(
                      team: _currentTeam,
                      onInviteSuccess: () {
                        // Callback para actualizar detalles del equipo después de una invitación exitosa
                        _loadUserDataAndTeamDetails();
                      },
                    ),
                  ),
                );
              },
              tooltip: 'Invitar Miembro',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
          : RefreshIndicator(
              onRefresh: _loadUserDataAndTeamDetails,
              color: AppTheme.primaryOrange,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTeamHeader(),
                    const SizedBox(height: 24),
                    _buildMembersSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTeamHeader() {
    return SportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield,
                  color: AppTheme.primaryOrange,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentTeam.nombre,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${_currentTeam.id}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Separator instead of description
        ],
      ),
    );
  }

  Widget _buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Miembros (${_currentTeam.miembros.length})',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
            if (_isCaptain)
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InviteMembersScreen(
                        team: _currentTeam,
                        onInviteSuccess: () {
                          // Callback para actualizar detalles del equipo después de una invitación exitosa
                          _loadUserDataAndTeamDetails();
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: AppTheme.primaryOrange, size: 20),
                label: const Text('Invitar', style: TextStyle(color: AppTheme.primaryOrange)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isCaptain)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: 'Invitar Nuevo Miembro',
                icon: Icons.person_add,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InviteMembersScreen(
                        team: _currentTeam,
                        onInviteSuccess: () {
                          // Callback para actualizar detalles del equipo después de una invitación exitosa
                          _loadUserDataAndTeamDetails();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Nuevo botón para invitar jugadores con la interfaz moderna
          if (_isCaptain)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InvitePlayerScreen(team: _currentTeam),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.primaryOrange),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Buscar y Invitar Jugadores',
                    style: TextStyle(
                      color: AppTheme.primaryOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        if (_currentTeam.miembros.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'Lista de miembros no disponible o vacía.',
                style: TextStyle(color: AppTheme.secondaryText),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _currentTeam.miembros.length,
            itemBuilder: (context, index) {
              final member = _currentTeam.miembros[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SportCard(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: member.esCapitan
                              ? AppTheme.primaryOrange.withOpacity(0.2)
                              : AppTheme.cardBackgroundLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          member.esCapitan ? Icons.star : Icons.person,
                          color: member.esCapitan ? AppTheme.primaryOrange : AppTheme.secondaryText,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.nombreCompleto,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            if (member.email != null)
                              Text(
                                member.email!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (_isCaptain && !member.esCapitan)
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: AppTheme.errorRed, size: 20),
                          onPressed: () => _expelMember(member),
                          tooltip: 'Expulsar',
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
