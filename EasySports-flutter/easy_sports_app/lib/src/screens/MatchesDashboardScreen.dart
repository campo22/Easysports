import 'dart:convert';
import 'package:easy_sports_app/src/models/match.dart';
import 'package:easy_sports_app/src/screens/match_detail_screen.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:easy_sports_app/src/widgets/sport_components.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchesDashboardScreen extends StatefulWidget {
  const MatchesDashboardScreen({super.key});

  @override
  State<MatchesDashboardScreen> createState() => _MatchesDashboardScreenState();
}

class _MatchesDashboardScreenState extends State<MatchesDashboardScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<Match> _allMatches = [];
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;

  final List<String> _tabs = ['ALL', 'ACTIVE', 'CLOSED'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      // Llama a setState solo cuando el índice del tab cambia
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _fetchMatches();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getPartidos();
      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> matchesList = jsonData['content'] ?? [];
        if (mounted) {
          setState(() {
            _allMatches = matchesList.map((matchJson) => Match.fromJson(matchJson)).toList();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error del servidor: ${response.statusCode}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error de conexión: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  List<Match> _getMatchesForTab(String tab) {
    if (tab == 'ALL') return _allMatches;
    if (tab == 'ACTIVE') {
      return _allMatches.where((m) => m.estado == 'ABIERTO' || m.estado == 'EN_CURSO').toList();
    }
    // 'CLOSED'
    return _allMatches.where((m) => m.estado == 'FINALIZADO' || m.estado == 'CANCELADO').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('MATCHES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.primaryText),
            onPressed: () {
              // TODO: Implementar búsqueda
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
                : _errorMessage != null
                    ? _buildErrorState()
                    : TabBarView(
                        controller: _tabController,
                        children: _tabs.map((tab) {
                          final matches = _getMatchesForTab(tab);
                          return _buildMatchList(matches);
                        }).toList(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primaryOrange,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.secondaryText,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildMatchList(List<Match> matches) {
    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports, size: 80, color: AppTheme.secondaryText.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'No hay partidos',
              style: TextStyle(fontSize: 18, color: AppTheme.primaryText, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'No se encontraron encuentros para esta categoría.',
              style: TextStyle(fontSize: 14, color: AppTheme.secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchMatches,
      color: AppTheme.primaryOrange,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          return _buildMatchCard(matches[index]);
        },
      ),
    );
  }

  String _buildMatchTitle(Match match) {
    if (match.tipo == 'FORMAL') {
      final local = match.equipoLocalNombre ?? 'Equipo Local';
      final visitante = match.equipoVisitanteNombre ?? 'Equipo Visitante';
      return '$local vs. $visitante';
    } else {
      return 'Partido de ${match.deporte}';
    }
  }

  Widget _buildMatchCard(Match match) {
    final dateFormat = DateFormat('dd MMM / HH:mm');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchDetailScreen(match: match),
          ),
        ).then((_) => _fetchMatches());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getSportIcon(match.deporte), color: AppTheme.primaryOrange, size: 18),
                const SizedBox(width: 8),
                Text(
                  match.deporte.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _buildMatchTitle(match),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, color: AppTheme.secondaryText, size: 16),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(match.fechaProgramada),
                  style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: AppTheme.secondaryText, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    match.nombreCanchaTexto ?? 'Ubicación por definir',
                    style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(
                text: match.estado,
                color: match.estado == 'ABIERTO' ? AppTheme.activeGreen : AppTheme.closedRed,
              ),
            ),
          ],
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
            text: 'Retry',
            onPressed: _fetchMatches,
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