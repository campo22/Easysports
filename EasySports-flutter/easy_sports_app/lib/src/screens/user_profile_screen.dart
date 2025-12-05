import 'package:easy_sports_app/src/models/invitation.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // Necesario para jsonDecode

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ApiService _apiService = ApiService();
  // final AuthService _authService = AuthService(); // Eliminado
  List<Invitation> _invitations = [];
  bool _isLoading = true;

  String _userName = 'Cargando...';
  String _userEmail = '...';

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Cargar datos del usuario desde el AuthProvider
      final authProvider = context.read<AuthProvider>();
      final name = authProvider.userName;
      final email = authProvider.userEmail;
      
      if (mounted) {
        setState(() {
          _userName = name ?? 'Usuario';
          _userEmail = email ?? 'email@example.com';
        });
      }

      // Cargar invitaciones pendientes
      // TODO: Mover esto a un InvitationService o TeamService
      final invResponse = await _apiService.get('invitaciones/pendientes');
      if (invResponse.statusCode == 200) {
        final List<dynamic> jsonInv = invResponse.body.isEmpty ? [] : jsonDecode(invResponse.body);
        if (mounted) {
          setState(() {
            _invitations = jsonInv.map((i) => Invitation.fromJson(i)).toList();
          });
        }
      }
    } catch (e) {
      // Manejar error
      debugPrint('Error cargando perfil: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleInvitation(int invitationId, bool accept) async {
    try {
      final endpoint = 'invitaciones/$invitationId/${accept ? 'aceptar' : 'rechazar'}';
      await _apiService.post(endpoint, {});
      _fetchProfileData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al ${accept ? 'aceptar' : 'rechazar'} la invitación')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetchProfileData,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildProfileHeader(),
                if (_invitations.isNotEmpty) _buildInvitationsSection(),
              ],
            ),
          );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
        const SizedBox(height: 16),
        Text(_userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(_userEmail, style: const TextStyle(fontSize: 16, color: AppTheme.secondaryText)),
        const SizedBox(height: 24),
        const Divider(color: AppTheme.secondaryText),
      ],
    );
  }

  Widget _buildInvitationsSection() {
    // ... (código existente)
    return Container();
  }
}
