import 'dart:convert';
import 'dart:async';
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
  
  List<Map<String, dynamic>> _searchResults = [];
  
  bool _isLoading = false;
  bool _isInviting = false;
  String _searchMessage = 'Escribe para buscar jugadores por nombre o email.';
  Timer? _debounce;

  final Set<int> _selectedPlayerIds = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query.length >= 3) {
        _searchUsers(query);
      } else {
        setState(() {
          _searchResults = [];
          _searchMessage = 'Escribe al menos 3 letras para empezar a buscar.';
        });
      }
    });
  }

  Future<void> _searchUsers(String query) async {
    setState(() {
      _isLoading = true;
      _searchMessage = 'Buscando...';
      _searchResults = [];
    });

    try {
      final response = await _apiService.searchUsers(query, widget.team.id);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _searchResults = data.map((item) => item as Map<String, dynamic>).toList();
          _searchMessage = _searchResults.isEmpty ? 'No se encontraron jugadores.' : '';
        });
      } else {
        setState(() {
          _searchMessage = 'Error al buscar: ${response.body}';
        });
      }
    } catch (e) {
       if (!mounted) return;
      setState(() {
        _searchMessage = 'Error de red: $e';
      });
    } finally {
       if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _togglePlayerSelection(int playerId) {
    setState(() {
      if (_selectedPlayerIds.contains(playerId)) {
        _selectedPlayerIds.remove(playerId);
      } else {
        _selectedPlayerIds.add(playerId);
      }
    });
  }

  Future<void> _inviteSelectedPlayers() async {
    setState(() {
      _isInviting = true;
    });

    final List<Future<bool>> inviteFutures = [];
    for (final playerId in _selectedPlayerIds) {
      final player = _searchResults.firstWhere((p) => p['id'] == playerId);
      inviteFutures.add(
          _invitePlayer(playerId, player['nombreCompleto'], player['email'] ?? ''));
    }

    final results = await Future.wait(inviteFutures);
    final successfulInvites = results.where((success) => success).length;
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invitaciones enviadas: $successfulInvites con éxito.',
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );

      // Actualizar la UI para mostrar los jugadores como 'invitados'
      setState(() {
        for (final playerId in _selectedPlayerIds) {
            final index = _searchResults.indexWhere((p) => p['id'] == playerId);
            if (index != -1) {
              _searchResults[index]['estado'] = 'invitado';
            }
        }
        _selectedPlayerIds.clear();
        _isInviting = false;
      });
    }
  }

  Future<bool> _invitePlayer(int playerId, String playerName, String playerEmail) async {
    try {
      final response = await _apiService.invitarMiembro(widget.team.id, {
        'emailUsuario': playerEmail,
      });

      if (response.statusCode == 200) {
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
        title: const Text('Invitar Jugadores'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o email (min. 3 letras)',
                prefixIcon: _isLoading ? const Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: _isLoading && _searchResults.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Text(
                          _searchMessage,
                          style: const TextStyle(color: AppTheme.secondaryText),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final player = _searchResults[index];
                          return _buildPlayerCard(player);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _selectedPlayerIds.isNotEmpty && !_isInviting
          ? FloatingActionButton.extended(
              onPressed: _inviteSelectedPlayers,
              label: Text('Invitar (${_selectedPlayerIds.length})'),
              icon: const Icon(Icons.send),
              backgroundColor: AppTheme.primaryOrange,
            )
          : null,
    );
  }

  Widget _buildPlayerCard(Map<String, dynamic> player) {
    final bool isSelected = _selectedPlayerIds.contains(player['id']);
    final bool isAlreadyInvited = player['estado'] == 'invitado'; 

    return Card(
      color: isSelected ? AppTheme.primaryOrange.withOpacity(0.2) : AppTheme.cardBackground,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: isAlreadyInvited ? null : () => _togglePlayerSelection(player['id'] as int),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(player['avatarUrl'] ?? 'https://placehold.co/200x200/cccccc/FFFFFF/png?text=Sin+Foto'),
          onBackgroundImageError: (exception, stackTrace) {},
        ),
        title: Text(player['nombreCompleto'], style: const TextStyle(color: AppTheme.primaryText)),
        subtitle: Text(player['email'], style: const TextStyle(color: AppTheme.secondaryText)),
        trailing: isAlreadyInvited
            ? const Text('Invitado', style: TextStyle(color: AppTheme.secondaryText))
            : Checkbox(
                value: isSelected,
                onChanged: (value) {
                  _togglePlayerSelection(player['id'] as int);
                },
                activeColor: AppTheme.primaryOrange,
              ),
      ),
    );
  }
}