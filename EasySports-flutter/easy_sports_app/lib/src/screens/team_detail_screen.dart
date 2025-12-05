import 'dart:convert';
import 'package:easy_sports_app/src/models/team.dart';
import 'package:easy_sports_app/src/models/team_member.dart';
import 'package:easy_sports_app/src/screens/edit_team_screen.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/services/auth_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TeamDetailScreen extends StatefulWidget {
  final Team team;

  const TeamDetailScreen({super.key, required this.team});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  late Team _currentTeam;
  List<TeamMember> _members = [];
  bool _isLoading = true;
  bool _isCaptain = false;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentTeam = widget.team;
    _fetchTeamDetails();
  }

  Future<void> _fetchTeamDetails({bool isRefresh = false}) async {
    if (!mounted) return;
    if (!isRefresh) {
      setState(() => _isLoading = true);
    }

    try {
      _currentUserId = await _authService.getUserId();
      _isCaptain = _currentTeam.capitanId == _currentUserId;

      final response = await _apiService.get('equipos/${_currentTeam.id}/miembros');
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = response.body.isEmpty ? [] : jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _members = jsonResponse.map((m) => TeamMember.fromJson(m)).toList();
          });
        }
      }
    } catch (e) {
      // Manejar error
    } finally {
      if (mounted && !isRefresh) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToEditTeam() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTeamScreen(team: _currentTeam)),
    );
    if (result == true) {
      _fetchTeamDetails(isRefresh: true);
    }
  }

  Future<void> _inviteMember(String email) {
    // ... (lógica existente)
    return Future.value();
  }

  void _showInviteDialog() {
    // ... (lógica existente)
  }

  Future<void> _expelMember(int memberId) {
    // ... (lógica existente)
    return Future.value();
  }

  void _showExpelDialog(TeamMember member) {
    // ... (lógica existente)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTeam.nombre),
        actions: [
          if (_isCaptain)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _navigateToEditTeam,
              tooltip: 'Editar Equipo',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Miembros del Equipo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      if (_isCaptain)
                        IconButton(
                          icon: const Icon(Icons.person_add, color: AppTheme.primaryColor),
                          onPressed: _showInviteDialog,
                          tooltip: 'Invitar Miembro',
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _fetchTeamDetails(isRefresh: true),
                    child: _members.isEmpty
                        ? const Center(child: Text('Este equipo aún no tiene miembros.'))
                        : ListView.builder(
                            itemCount: _members.length,
                            itemBuilder: (context, index) {
                              final member = _members[index];
                              final isThisMemberTheCaptain = member.rol == 'CAPITAN';

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.cardBackground,
                                  child: Text(member.nombreCompleto.isNotEmpty ? member.nombreCompleto.substring(0, 1) : '?'),
                                ),
                                title: Text(member.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(member.rol, style: TextStyle(color: isThisMemberTheCaptain ? AppTheme.primaryColor : AppTheme.secondaryText)),
                                trailing: _isCaptain && !isThisMemberTheCaptain
                                    ? IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                        onPressed: () => _showExpelDialog(member),
                                        tooltip: 'Expulsar Miembro',
                                      )
                                    : null,
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
