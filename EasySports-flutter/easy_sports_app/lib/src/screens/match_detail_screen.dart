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

  @override
  Widget build(BuildContext context) {
    final bool canRegisterResult = _isCreator && _currentMatch.estado != 'FINALIZADO';

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: Text('Match #${_currentMatch.codigo}'),
        backgroundColor: Colors.transparent,
        actions: [
          if (canRegisterResult)
            IconButton(
              icon: const Icon(Icons.edit_note, color: AppTheme.primaryOrange),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterResultScreen(match: _currentMatch),
                  ),
                ).then((_) => _fetchMatchDetails());
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
          : _errorMessage != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _fetchMatchDetails,
                  color: AppTheme.primaryOrange,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMatchHeader(),
                        const SizedBox(height: 20),
                        _buildMatchInfo(),
                        const SizedBox(height: 20),
                        if (_currentMatch.estado == 'FINALIZADO' && 
                            _currentMatch.golesLocal != null)
                          _buildResultSection(),
                        const SizedBox(height: 20),
                        _buildDetailsSection(),
                      ],
                    ),
                  ),
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
}
