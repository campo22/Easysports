import 'dart:convert';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:flutter/material.dart';

class InviteMemberScreen extends StatefulWidget {
  final int equipoId;
  final String equipoNombre;

  const InviteMemberScreen({
    super.key,
    required this.equipoId,
    required this.equipoNombre,
  });

  @override
  State<InviteMemberScreen> createState() => _InviteMemberScreenState();
}

class _InviteMemberScreenState extends State<InviteMemberScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  final Set<String> _invitedEmails = {};

  // Jugadores sugeridos (datos de ejemplo - en producción vendrían del backend)
  final List<Map<String, String>> _suggestedPlayers = [
    {'name': 'Alex Morgan', 'position': 'Delantero', 'email': 'alex.morgan@example.com'},
    {'name': 'Megan Rapinoe', 'position': 'Mediocampista', 'email': 'megan.rapinoe@example.com'},
    {'name': 'Cristiano Ronaldo', 'position': 'Delantero', 'email': 'cristiano@example.com'},
    {'name': 'Sam Kerr', 'position': 'Delantero', 'email': 'sam.kerr@example.com'},
    {'name': 'Kevin De Bruyne', 'position': 'Mediocampista', 'email': 'kevin.db@example.com'},
  ];

  Future<void> _inviteMember(String email, String name) async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.invitarMiembro(
        widget.equipoId,
        {'email': email},
      );
      
      if (response.statusCode == 200 && mounted) {
        setState(() => _invitedEmails.add(email));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitación enviada a $name'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al invitar a $name'),
            backgroundColor: AppTheme.errorRed,
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'Invitar Jugador',
          style: TextStyle(
            color: AppTheme.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.cardBackgroundLight,
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppTheme.primaryText),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o email',
                  hintStyle: const TextStyle(color: AppTheme.secondaryText),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.secondaryText),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {}); // Actualizar filtro
                },
              ),
            ),
          ),

          // Lista de jugadores sugeridos
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Jugadores Sugeridos',
                      style: TextStyle(
                        color: AppTheme.primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: _suggestedPlayers
                          .where((player) {
                            if (_searchController.text.isEmpty) return true;
                            final search = _searchController.text.toLowerCase();
                            return player['name']!.toLowerCase().contains(search) ||
                                   player['email']!.toLowerCase().contains(search);
                          })
                          .map((player) => _buildPlayerCard(player))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(Map<String, String> player) {
    final isInvited = _invitedEmails.contains(player['email']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppTheme.orangeGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                player['name']![0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player['name']!,
                  style: const TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  player['position']!,
                  style: const TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Botón
          ElevatedButton(
            onPressed: isInvited || _isLoading
                ? null
                : () => _inviteMember(player['email']!, player['name']!),
            style: ElevatedButton.styleFrom(
              backgroundColor: isInvited ? AppTheme.cardBackgroundLight : AppTheme.primaryOrange,
              foregroundColor: isInvited ? AppTheme.secondaryText : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Text(
              isInvited ? 'Invitado' : 'Invitar',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}