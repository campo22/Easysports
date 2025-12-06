import 'dart:convert';
import 'package:easy_sports_app/src/models/match.dart';
import 'package:easy_sports_app/src/screens/register_result_screen.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/providers/auth_provider.dart';
import 'package:easy_sports_app/src/widgets/sport_components.dart';
import 'package:provider/provider.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchDetailScreen extends StatefulWidget {
  final Match match;

  const MatchDetailScreen({super.key, required this.match});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  final ApiService _apiService = ApiService();
  late Match _currentMatch;
  bool _isLoading = true;
  bool _isCreator = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentMatch = widget.match;
    _fetchMatchDetails();
  }

  Future<void> _fetchMatchDetails() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userIdDynamic = authProvider.userId;
      int? currentUserId;
      
      if (userIdDynamic is int) {
        currentUserId = userIdDynamic;
      } else if (userIdDynamic is String) {
        currentUserId = int.tryParse(userIdDynamic);
      }
      
      _isCreator = _currentMatch.creadorId == currentUserId;

      final response = await _apiService.getEncuentroPorCodigo(_currentMatch.codigo);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _currentMatch = Match.fromJson(jsonData);
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _joinMatch() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _apiService.unirseAEncuentro(_currentMatch.codigo);
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Te has unido al partido!'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          await _fetchMatchDetails(); // Recargar detalles
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${response.body}'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
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
  Widget build(BuildContext context) {
    final bool canRegisterResult = _isCreator && _currentMatch.estado != 'FINALIZADO';
    final bool canJoin = !_isCreator && 
                         _currentMatch.estado == 'ABIERTO' && 
                         _currentMatch.jugadoresActuales < _currentMatch.maxJugadores;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalles del Partido',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
          : _errorMessage != null
              ? _buildErrorState()
              : Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPremiumHeader(),
                          const SizedBox(height: 16),
                          _buildLocationSection(),
                          const SizedBox(height: 16),
                          _buildPlayersSection(),
                          const SizedBox(height: 100), // Espacio para botones fijos
                        ],
                      ),
                    ),
                    _buildBottomButtons(canJoin, canRegisterResult),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 60),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: const TextStyle(color: AppTheme.secondaryText)),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Reintentar',
            onPressed: _fetchMatchDetails,
          ),
        ],
      ),
    );
  }

  Widget _buildMatchHeader() {
    return SportCard(
      child: Column(
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
                child: Icon(
                  _getSportIcon(_currentMatch.deporte),
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
                      _currentMatch.tipo == 'FORMAL' ? 'Partido Formal' : 'Partido Casual',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentMatch.deporte.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                text: _currentMatch.estado,
                color: _currentMatch.estado == 'ABIERTO' 
                    ? AppTheme.activeGreen 
                    : _currentMatch.estado == 'FINALIZADO'
                        ? AppTheme.closedRed
                        : AppTheme.goldAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchInfo() {
    final dateFormat = DateFormat('dd/MM/yyyy - HH:mm');
    
    return SportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del Partido',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.calendar_today, 'Fecha', 
              dateFormat.format(_currentMatch.fechaProgramada)),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on, 'Ubicación', 
              _currentMatch.nombreCanchaTexto ?? 'Por definir'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.people, 'Jugadores', 
              '${_currentMatch.jugadoresActuales}/${_currentMatch.maxJugadores}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryOrange, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.secondaryText,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection() {
    return SportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resultado Final',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildScoreBox('Local', _currentMatch.golesLocal ?? 0),
              const SizedBox(width: 20),
              const Text(
                '-',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryOrange,
                ),
              ),
              const SizedBox(width: 20),
              _buildScoreBox('Visitante', _currentMatch.golesVisitante ?? 0),
            ],
          ),
          if (_currentMatch.comentarios != null) ...[
            const SizedBox(height: 16),
            const Divider(color: AppTheme.cardBackgroundLight),
            const SizedBox(height: 16),
            const Text(
              'Comentarios:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentMatch.comentarios!,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.primaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreBox(String team, int score) {
    return Column(
      children: [
        Text(
          team,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.secondaryText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryOrange, width: 2),
          ),
          child: Center(
            child: Text(
              score.toString(),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryOrange,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return SportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalles Adicionales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Código', _currentMatch.codigo),
          _buildDetailRow('Tipo', _currentMatch.tipo),
          _buildDetailRow('Estado', _currentMatch.estado),
          if (_isCreator)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, color: AppTheme.goldAccent, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Eres el creador de este partido',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.bold,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryText,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSportIcon(String deporte) {
    final sport = deporte.toUpperCase();
    if (sport.contains('FUTBOL') || sport.contains('SOCCER')) {
      return Icons.sports_soccer;
    } else if (sport.contains('BASKET')) {
      return Icons.sports_basketball;
    } else if (sport.contains('TENIS')) {
      return Icons.sports_tennis;
    } else if (sport.contains('VOLEY')) {
      return Icons.sports_volleyball;
    }
    return Icons.sports;
  }

  // Nuevos métodos premium
  Widget _buildPremiumHeader() {
    final dateFormat = DateFormat('EEE, MMM dd • h:mm a', 'es');
    
    return Container(
      height: 300,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const NetworkImage('https://images.unsplash.com/photo-1459865264687-595d652de67e?w=800'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Equipo Local
                  Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: AppTheme.orangeGradient,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Center(
                          child: Text('A', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Equipo A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  // Contador/Marcador
                  Column(
                    children: [
                      Text(
                        _currentMatch.estado == 'FINALIZADO' ? 'FINALIZADO' : 'INICIA EN',
                        style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentMatch.estado == 'FINALIZADO' 
                            ? '${_currentMatch.golesLocal ?? 0} - ${_currentMatch.golesVisitante ?? 0}'
                            : '2d 15h',
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // Equipo Visitante
                  Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.blue, Colors.blue.shade700]),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Center(
                          child: Text('B', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Equipo B', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sports_soccer, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _currentMatch.deporte.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.event, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(_currentMatch.fechaProgramada),
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ubicación y Detalles',
            style: TextStyle(color: AppTheme.primaryText, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardBackgroundLight.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_on, color: AppTheme.primaryOrange, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentMatch.nombreCanchaTexto ?? 'Cancha Deportiva',
                        style: const TextStyle(color: AppTheme.primaryText, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '123 Victory Lane, Sportsville',
                        style: TextStyle(color: AppTheme.secondaryText, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.secondaryText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jugadores Confirmados (${_currentMatch.jugadoresActuales}/${_currentMatch.maxJugadores})',
            style: const TextStyle(color: AppTheme.primaryText, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardBackgroundLight.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Wrap(
                  spacing: -8,
                  children: List.generate(
                    _currentMatch.jugadoresActuales.clamp(0, 6),
                    (index) => Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppTheme.orangeGradient,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.cardBackground, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_currentMatch.jugadoresActuales > 6)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '+${_currentMatch.jugadoresActuales - 6} más',
                      style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 12),
                const Divider(color: AppTheme.cardBackgroundLight, height: 1),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Ver todos los jugadores',
                    style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(bool canJoin, bool canRegisterResult) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundDark.withOpacity(0.95),
          border: Border(top: BorderSide(color: AppTheme.cardBackgroundLight.withOpacity(0.3))),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.primaryOrange, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: const Text(
                  'Chat',
                  style: TextStyle(color: AppTheme.primaryOrange, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: canJoin ? _joinMatch : (canRegisterResult ? () {} : null),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppTheme.primaryOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: Text(
                  canJoin ? 'Unirse' : (canRegisterResult ? 'Registrar' : 'Confirmar'),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
