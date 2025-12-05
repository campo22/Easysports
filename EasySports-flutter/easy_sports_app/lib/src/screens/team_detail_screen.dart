import 'dart:convert';
import 'package:easy_sports_app/src/models/team.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:easy_sports_app/src/widgets/sport_components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_sports_app/src/providers/auth_provider.dart';

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
    _loadTeamDetails();
  }

  Future<void> _loadTeamDetails() async {
    setState(() => _isLoading = true);
    
    try {
      // Obtener ID del usuario actual
      final authProvider = context.read<AuthProvider>();
      _currentUserId = authProvider.userId;
      
      // Cargar detalles actualizados del equipo
      final response = await _apiService.getEquipoPorId(_currentTeam.id);
      if (response.statusCode == 200) {
        final teamData = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _currentTeam = Team.fromJson(teamData);
            _isCaptain = _currentTeam.capitanId == _currentUserId;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading team details: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _inviteMember() async {
    final emailController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('Invitar Miembro', style: TextStyle(color: AppTheme.primaryText)),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email del usuario',
            hintText: 'usuario@example.com',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.secondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Invitar', style: TextStyle(color: AppTheme.primaryOrange)),
          ),
        ],
      ),
    );

    if (result == true && emailController.text.isNotEmpty) {
      try {
        final response = await _apiService.invitarMiembro(
          _currentTeam.id,
          {'email': emailController.text.trim()},
        );
        
        if (response.statusCode == 200 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invitación enviada'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
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
          await _loadTeamDetails();
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
              onPressed: _inviteMember,
              tooltip: 'Invitar Miembro',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
          : RefreshIndicator(
              onRefresh: _loadTeamDetails,
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
                      'Capitán: ${_currentTeam.capitanNombre ?? "Desconocido"}',
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
          if (_currentTeam.descripcion != null && _currentTeam.descripcion!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: AppTheme.cardBackgroundLight),
            const SizedBox(height: 16),
            Text(
              _currentTeam.descripcion!,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryText,
              ),
            ),
          ],
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
                onPressed: _inviteMember,
                icon: const Icon(Icons.add, color: AppTheme.primaryOrange, size: 20),
                label: const Text('Invitar', style: TextStyle(color: AppTheme.primaryOrange)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_currentTeam.miembros.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'No hay miembros aún',
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
