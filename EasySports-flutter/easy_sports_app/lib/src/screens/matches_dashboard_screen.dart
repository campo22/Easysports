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
        setState(() {
          _allMatches = matchesList.map((matchJson) => Match.fromJson(matchJson)).toList();
        });
      } else {
        setState(() {
          _errorMessage = 'Error del servidor: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Match> get _filteredMatches {
    final selectedTab = _tabs[_tabController.index];
    if (selectedTab == 'ALL') return _allMatches;
    if (selectedTab == 'ACTIVE') {
      return _allMatches.where((m) => m.estado == 'ABIERTO' || m.estado == 'EN_CURSO').toList();
    }
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
            onPressed: () {},
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
                    : RefreshIndicator(
                        onRefresh: _fetchMatches,
                        color: AppTheme.primaryOrange,
                        child: TabBarView(
                          controller: _tabController,
                          children: _tabs.map((tab) => _buildMatchList()).toList(),
                        ),
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
        onTap: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildMatchList() {
    final matches = _filteredMatches;

    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 80, color: AppTheme.secondaryText.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'No matches found',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildMatchCard(matches[index]),
        );
      },
    );
  }

  Widget _buildMatchCard(Match match) {
    final dateFormat = DateFormat('dd MMM / HH:mm');
    final isActive = match.estado == 'ABIERTO' || match.estado == 'EN_CURSO';
    final isClosed = match.estado == 'FINALIZADO' || match.estado == 'CANCELADO';

    return SportCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchDetailScreen(match: match),
          ),
        ).then((_) => _fetchMatches());
      },
      child: Row(
        children: [
          // Team logos/icons
          Row(
            children: [
              _buildTeamIcon(match.deporte, true),
              const SizedBox(width: 8),
              _buildTeamIcon(match.deporte, false),
            ],
          ),
          const SizedBox(width: 16),
          // Match info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.tipo == 'FORMAL' ? 'Formal Match' : 'Casual Match',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: AppTheme.secondaryText),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(match.fechaProgramada),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Score or status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (match.estado == 'FINALIZADO' && match.golesLocal != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackgroundLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${match.golesLocal} - ${match.golesVisitante}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                )
              else
                StatusBadge(
                  text: isActive ? 'ACTIVE' : isClosed ? 'CLOSED' : match.estado,
                  color: isActive 
                      ? AppTheme.activeGreen 
                      : isClosed 
                          ? AppTheme.closedRed 
                          : AppTheme.goldAccent,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamIcon(String deporte, bool isHome) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isHome 
            ? AppTheme.primaryOrange.withOpacity(0.2) 
            : AppTheme.cardBackgroundLight,
        shape: BoxShape.circle,
        border: Border.all(
          color: isHome ? AppTheme.primaryOrange : AppTheme.cardBackgroundLight,
          width: 2,
        ),
      ),
      child: Icon(
        _getSportIcon(deporte),
        color: isHome ? AppTheme.primaryOrange : AppTheme.secondaryText,
        size: 20,
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
