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
    // ... (Lógica de carga existente)
  }

  void _navigateToEditTeam() {
    // ... (Lógica de navegación existente)
  }

  Future<void> _inviteMember(String email) {
    // ... (Lógica de invitación existente)
    return Future.value();
  }

  void _showInviteDialog() {
    // ... (Lógica de diálogo existente)
  }

  Future<void> _expelMember(int memberId) {
    // ... (Lógica de expulsión existente)
    return Future.value();
  }

  void _showExpelDialog(TeamMember member) {
    // ... (Lógica de diálogo existente)
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
                          icon: const Icon(Icons.person_add, color: AppTheme.primaryOrange, size: 30),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: _members.length,
                            itemBuilder: (context, index) {
                              final member = _members[index];
                              return _MemberCard(
                                member: member,
                                isCaptainView: _isCaptain,
                                onExpel: () => _showExpelDialog(member),
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

// --- NUEVO WIDGET DE TARJETA DE MIEMBRO ---
class _MemberCard extends StatelessWidget {
  final TeamMember member;
  final bool isCaptainView;
  final VoidCallback onExpel;

  const _MemberCard({
    required this.member,
    required this.isCaptainView,
    required this.onExpel,
  });

  @override
  Widget build(BuildContext context) {
    final isThisMemberTheCaptain = member.rol == 'CAPITAN';

    return Card(
      color: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isThisMemberTheCaptain ? AppTheme.primaryOrange.withOpacity(0.2) : AppTheme.backgroundDark,
                  child: Text(
                    member.nombreCompleto.isNotEmpty ? member.nombreCompleto.substring(0, 1) : '?',
                    style: TextStyle(fontWeight: FontWeight.bold, color: isThisMemberTheCaptain ? AppTheme.primaryOrange : AppTheme.primaryText),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      member.rol,
                      style: TextStyle(color: isThisMemberTheCaptain ? AppTheme.primaryOrange : AppTheme.secondaryText, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            if (isCaptainView && !isThisMemberTheCaptain)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: onExpel,
                tooltip: 'Expulsar Miembro',
              ),
          ],
        ),
      ),
    );
  }
}
