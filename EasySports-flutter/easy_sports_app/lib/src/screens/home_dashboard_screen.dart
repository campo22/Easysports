import 'dart:convert';
import 'package:easy_sports_app/src/models/match.dart';
import 'package:easy_sports_app/src/screens/create_match_screen.dart';
import 'package:easy_sports_app/src/screens/match_detail_screen.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:easy_sports_app/src/widgets/sport_components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_sports_app/src/providers/auth_provider.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final ApiService _apiService = ApiService();
  List<Match> _matches = [];
  bool _isLoading = true;
  int _selectedSportIndex = 0;
  String? _errorMessage;

  final List<Map<String, dynamic>> _sports = [
    {'name': 'ALL', 'icon': Icons.sports},
    {'name': 'FOOTBALL', 'icon': Icons.sports_soccer},
    {'name': 'TENNIS', 'icon': Icons.sports_tennis},
    {'name': 'BASKETBALL', 'icon': Icons.sports_basketball},
    {'name': 'VOLLEYBALL', 'icon': Icons.sports_volleyball},
  ];

  @override
  void initState() {
    super.initState();
    _fetchMatches();
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
          _matches = matchesList.map((matchJson) => Match.fromJson(matchJson)).toList();
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
    if (_selectedSportIndex == 0) return _matches;
    final sportName = _sports[_selectedSportIndex]['name'].toString();
    return _matches.where((m) => m.deporte.toUpperCase().contains(sportName)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<AuthProvider>().userName ?? 'Usuario';
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.darkGradient,
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
              : _errorMessage != null
                  ? _buildErrorState()
                  : RefreshIndicator(
                      onRefresh: _fetchMatches,
                      color: AppTheme.primaryOrange,
                      child: CustomScrollView(
                        slivers: [
                          _buildHeader(userName),
                          _buildCategories(),
                          _buildTopLeadersSection(),
                          _buildMatchesSection(),
                        ],
                      ),
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateMatchScreen()),
          );
        },
        backgroundColor: AppTheme.primaryOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Match', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          Text(_errorMessage!, style: const TextStyle(fontSize: 16, color: AppTheme.secondaryText)),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Reintentar',
            onPressed: _fetchMatches,
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildHeader(String userName) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hey',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondaryText,
                  ),
                ),
                Text(
                  userName,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppTheme.primaryText),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildCategories() {
    return SliverToBoxAdapter(
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _sports.length,
          itemBuilder: (context, index) {
            final sport = _sports[index];
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SportCategoryIcon(
                icon: sport['icon'] as IconData,
                label: sport['name'] as String,
                isSelected: _selectedSportIndex == index,
                onTap: () {
                  setState(() {
                    _selectedSportIndex = index;
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildTopLeadersSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Leaders in Soccer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            SportCard(
              onTap: () {},
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: NetworkImage('https://i.pravatar.cc/150?img=12'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Top Scorer',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Alex Morgan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatChip('12 Goals'),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatChip('8 Assists'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: PrimaryButton(
                      text: 'Watch',
                      onPressed: () {},
                      icon: Icons.play_arrow,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryOrange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.primaryOrange,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildMatchesSection() {
    final matches = _filteredMatches;
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Next Matches',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            if (matches.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'No matches available',
                    style: TextStyle(color: AppTheme.secondaryText),
                  ),
                ),
              )
            else
              ...matches.map((match) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMatchCard(match),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(Match match) {
    return SportCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchDetailScreen(match: match),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getSportIcon(match.deporte),
              color: AppTheme.primaryOrange,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.tipo == 'FORMAL' ? 'Partido Formal' : 'Partido Casual',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${match.fechaProgramada.day}/${match.fechaProgramada.month} - ${match.nombreCanchaTexto ?? 'TBD'}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(
            text: match.estado,
            color: match.estado == 'ABIERTO' ? AppTheme.activeGreen : AppTheme.closedRed,
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

extension WidgetExtensions on Widget {
  Widget constrained({double? width, double? height}) {
    return SizedBox(width: width, height: height, child: this);
  }
}