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

/// Gestiona el estado y la lógica de la pantalla de invitación de jugadores.
///
/// Esta pantalla permite a un capitán de equipo buscar jugadores en la plataforma
/// y enviarles invitaciones para unirse a su equipo. Soporta la selección
/// múltiple para invitar a varios jugadores a la vez.
class _InvitePlayerScreenState extends State<InvitePlayerScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allPlayers = [];
  List<Map<String, dynamic>> _filteredPlayers = [];
  bool _isLoading = true;
  bool _isInviting = false;

  /// Almacena los IDs de los jugadores seleccionados para la invitación múltiple.
  ///
  /// Se utiliza un [Set] para garantizar que no haya IDs duplicados y para
  /// tener una alta eficiencia al añadir, eliminar y comprobar la existencia de un jugador.
  final Set<int> _selectedPlayerIds = {};

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
          'avatarUrl': 'https://placehold.co/200x200/E67E22/FFFFFF/png',
          'estado': 'disponible' // puede ser 'disponible', 'invitado', 'ocupado'
        },
        {
          'id': 2,
          'nombreCompleto': 'Megan Rapinoe',
          'posicion': 'Centrocampista',
          'avatarUrl': 'https://placehold.co/200x200/FFB84D/FFFFFF/png',
          'estado': 'invitado'
        },
        {
          'id': 3,
          'nombreCompleto': 'Cristiano Ronaldo',
          'posicion': 'Delantero',
          'avatarUrl': 'https://placehold.co/200x200/4CAF50/FFFFFF/png',
          'estado': 'disponible'
        },
        {
          'id': 4,
          'nombreCompleto': 'Sam Kerr',
          'posicion': 'Delantera',
          'avatarUrl': 'https://placehold.co/200x200/FF5252/FFFFFF/png',
          'estado': 'disponible'
        },
        {
          'id': 5,
          'nombreCompleto': 'Kevin De Bruyne',
          'posicion': 'Centrocampista',
          'avatarUrl': 'https://placehold.co/200x200/00E676/FFFFFF/png',
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

  /// Alterna la selección de un jugador para la invitación múltiple.
  ///
  /// Si el [playerId] ya está en el conjunto de seleccionados, lo elimina.
  /// Si no, lo añade. Se llama a [setState] para reconstruir la UI y reflejar
  /// el cambio visual en la selección.
  void _togglePlayerSelection(int playerId) {
    setState(() {
      if (_selectedPlayerIds.contains(playerId)) {
        _selectedPlayerIds.remove(playerId);
      } else {
        _selectedPlayerIds.add(playerId);
      }
    });
  }

  /// Envía invitaciones a todos los jugadores seleccionados.
  ///
  /// Itera sobre los IDs en [_selectedPlayerIds] y crea una lista de futuros
  /// llamando a [_invitePlayer] para cada uno. Utiliza [Future.wait] para
  /// ejecutar todas las invitaciones en paralelo, mejorando el rendimiento.
  ///
  /// Al finalizar, muestra una [SnackBar] con un resumen de los resultados
  /// y limpia la selección.
  Future<void> _inviteSelectedPlayers() async {
    if (_selectedPlayerIds.isEmpty || _isInviting) return;

    setState(() {
      _isInviting = true;
    });

    final List<Future<bool>> inviteFutures = [];
    for (final playerId in _selectedPlayerIds) {
      final player = _allPlayers.firstWhere((p) => p['id'] == playerId);
      inviteFutures.add(_invitePlayer(playerId, player['nombreCompleto']));
    }

    final results = await Future.wait(inviteFutures);
    final successfulInvites = results.where((success) => success).length;
    final failedInvites = results.length - successfulInvites;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invitaciones enviadas: $successfulInvites con éxito, $failedInvites fallidas.',
          ),
          backgroundColor:
              failedInvites > 0 ? AppTheme.errorRed : AppTheme.successGreen,
        ),
      );

      // Limpiar selección y actualizar estado
      setState(() {
        _selectedPlayerIds.clear();
        _isInviting = false;
      });
    }
  }

  /// Envía una invitación a un solo jugador y actualiza su estado local.
  ///
  /// Llama al servicio de API para invitar a un jugador por su [playerId].
  /// Si la invitación es exitosa (código 200), actualiza el estado del jugador
  /// a 'invitado' en la lista local de jugadores y refresca la lista filtrada.
  ///
  /// Devuelve `true` si la invitación fue exitosa, `false` en caso contrario.
  Future<bool> _invitePlayer(int playerId, String playerName) async {
    try {
      final response = await _apiService.invitarMiembro(widget.team.id, {
        'email': '' // En una implementación real, usaríamos el email del jugador
      });

      if (response.statusCode == 200) {
        if (mounted) {
          // Actualizar estado del jugador
          setState(() {
            final playerIndex =
                _allPlayers.indexWhere((p) => p['id'] == playerId);
            if (playerIndex != -1) {
              _allPlayers[playerIndex]['estado'] = 'invitado';
            }
            _filterPlayers(_searchController.text);
          });
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
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
                color: AppTheme.cardBackground,
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
      // Muestra un botón de acción flotante solo si hay jugadores seleccionados.
      // Este botón permite al usuario confirmar y enviar las invitaciones.
      floatingActionButton: _selectedPlayerIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _inviteSelectedPlayers,
              label: _isInviting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('Invitar (${_selectedPlayerIds.length})'),
              icon: const Icon(Icons.send),
              backgroundColor: AppTheme.primaryOrange,
            )
          : null,
    );
  }

  /// Construye el widget de tarjeta para un jugador individual.
  ///
  /// La tarjeta muestra el avatar, nombre y posición del jugador. Es interactiva
  /// y permite la selección a través de un [GestureDetector]. El estado de
  /// selección se indica con un borde de color y un [Checkbox].
  ///
  /// Si un jugador ya ha sido invitado, se muestra un texto 'Invitado' y
  /// la tarjeta se deshabilita.
  Widget _buildPlayerCard(Map<String, dynamic> player) {
    final String estado = player['estado'];
    final bool isInvited = estado == 'invitado';
    final bool isSelected = _selectedPlayerIds.contains(player['id']);

    return GestureDetector(
      onTap: isInvited ? null : () => _togglePlayerSelection(player['id']),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.cardBackgroundLight
              : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppTheme.primaryOrange, width: 2)
              : null,
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
              if (isInvited)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground, // Color gris similar al diseño
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
                )
              else
                Checkbox(
                  value: isSelected,
                  onChanged: (bool? value) {
                    _togglePlayerSelection(player['id']);
                  },
                  activeColor: AppTheme.primaryOrange,
                  checkColor: Colors.white,
                  side: const BorderSide(color: AppTheme.secondaryText, width: 2),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
