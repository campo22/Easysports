import 'dart:convert';
import 'package:easy_sports_app/src/models/team.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:flutter/material.dart';

class InvitePlayerScreen extends StatefulWidget {
  final Team team;

  const InvitePlayerScreen({super.key, required this.team});

  @override
  State<InvitePlayerScreen> createState() => _InvitePlayerScreenState();
}

class _InvitePlayerScreenState extends State<InvitePlayerScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allPlayers = [];
  List<Map<String, dynamic>> _filteredPlayers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simular carga de jugadores - en una implementación real, esto vendría de una API
      await Future.delayed(const Duration(seconds: 1)); // Simular tiempo de carga
      
      // Datos de ejemplo que simulan respuesta del backend
      final samplePlayers = [
        {
          'id': 1,
          'nombreCompleto': 'Alex Morgan',
          'posicion': 'Delantero',
          'avatarUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd723b12d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
          'estado': 'disponible' // puede ser 'disponible', 'invitado', 'ocupado'
        },
        {
          'id': 2,
          'nombreCompleto': 'Megan Rapinoe',
          'posicion': 'Centrocampista',
          'avatarUrl': 'https://images.unsplash.com/photo-1494790108377-be550ed6d120?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
          'estado': 'invitado'
        },
        {
          'id': 3,
          'nombreCompleto': 'Cristiano Ronaldo',
          'posicion': 'Delantero',
          'avatarUrl': 'https://images.unsplash.com/photo-1552058544-f2b08422138a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
          'estado': 'disponible'
        },
        {
          'id': 4,
          'nombreCompleto': 'Sam Kerr',
          'posicion': 'Delantera',
          'avatarUrl': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
          'estado': 'disponible'
        },
        {
          'id': 5,
          'nombreCompleto': 'Kevin De Bruyne',
          'posicion': 'Centrocampista',
          'avatarUrl': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
          'estado': 'disponible'
        },
      ];
      
      if (mounted) {
        setState(() {
          _allPlayers = samplePlayers;
          _filteredPlayers = samplePlayers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar jugadores: $e')),
        );
      }
    }
  }

  void _filterPlayers(String query) {
    final filtered = _allPlayers.where((player) {
      final playerName = player['nombreCompleto'].toLowerCase();
      final playerPosition = player['posicion'].toLowerCase();
      final playerEmail = player['email']?.toLowerCase() ?? '';
      
      return playerName.contains(query.toLowerCase()) ||
             playerPosition.contains(query.toLowerCase()) ||
             playerEmail.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredPlayers = filtered;
    });
  }

  Future<void> _invitePlayer(int playerId, String playerName) async {
    try {
      final response = await _apiService.invitarMiembro(widget.team.id, {
        'email': '' // En una implementación real, usaríamos el email del jugador
      });

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Invitación enviada exitosamente!'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          
          // Actualizar estado del jugador
          setState(() {
            final playerIndex = _filteredPlayers.indexWhere((p) => p['id'] == playerId);
            if (playerIndex != -1) {
              _filteredPlayers[playerIndex]['estado'] = 'invitado';
            }
          });
        }
      } else {
        final contentType = response.headers['content-type'];
        String errorMessage = 'Error al enviar invitación';

        if (contentType != null && contentType.contains('application/json')) {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'Error en el proceso de invitación';
        } else {
          errorMessage = response.body.isNotEmpty 
            ? response.body 
            : 'Código de error: ${response.statusCode}';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de red: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryText),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              'Invitar a ${widget.team.nombre}',
              style: const TextStyle(
                color: AppTheme.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.inputDark,
                borderRadius: BorderRadius.circular(30), // Borde redondeado como en el diseño
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre o email',
                  prefixIcon: Icon(Icons.search, color: AppTheme.secondaryText),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  hintStyle: TextStyle(color: AppTheme.secondaryText),
                ),
                style: const TextStyle(color: AppTheme.primaryText),
                onChanged: _filterPlayers,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
                : RefreshIndicator(
                    onRefresh: _loadPlayers,
                    color: AppTheme.primaryOrange,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _filteredPlayers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final player = _filteredPlayers[index];
                        return _buildPlayerCard(player);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(Map<String, dynamic> player) {
    final String estado = player['estado'];
    final bool isInvited = estado == 'invitado';
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark, // Color de card como en el diseño
        borderRadius: BorderRadius.circular(16), // Bordes redondeados
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(player['avatarUrl']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player['nombreCompleto'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  Text(
                    player['posicion'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (!isInvited)
              ElevatedButton(
                onPressed: () => _invitePlayer(player['id'], player['nombreCompleto']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Botón redondeado
                  ),
                ),
                child: const Text(
                  'Invitar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.inputDark, // Color gris similar al diseño
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Invitado',
                  style: TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}