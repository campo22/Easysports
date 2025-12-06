import 'dart:convert';
import 'package:easy_sports_app/src/models/match.dart';
import 'package:easy_sports_app/src/screens/create_team_screen.dart';
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
    {'name': 'TODOS', 'icon': Icons.sports},
    {'name': 'FÚTBOL', 'icon': Icons.sports_soccer},
    {'name': 'TENIS', 'icon': Icons.sports_tennis},
    {'name': 'BALONCESTO', 'icon': Icons.sports_basketball},
    {'name': 'VOLEIBOL', 'icon': Icons.sports_volleyball},
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
                          _buildStandingsSection(),
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
            MaterialPageRoute(builder: (context) => const CreateTeamScreen()),
          );
        },
        backgroundColor: AppTheme.primaryOrange,
        icon: const Icon(Icons.group_add, color: Colors.white),
        label: const Text('Crear Equipo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  'Hola',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mejores en Fútbol',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Ver Todos',
                    style: TextStyle(
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tarjeta premium con gradiente y imagen de fondo
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A1410),
                    const Color(0xFF2A1810),
                    AppTheme.primaryOrange.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryOrange.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Imagen de fondo con overlay
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                              AppTheme.primaryOrange.withOpacity(0.4),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Contenido
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        // Lado izquierdo - Información
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryOrange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.primaryOrange,
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'Equipo Destacado',
                                  style: TextStyle(
                                    color: AppTheme.primaryOrange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Top Líderes\nen la Liga',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.1,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildMiniStat('12', 'Victorias'),
                                  _buildMiniStat('8', 'Goles'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Lado derecho - Botón de acción
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppTheme.orangeGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryOrange.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.emoji_events,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.orangeGradient,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryOrange.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Ver',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildMiniStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryOrange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryOrange,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.secondaryText,
            ),
          ),
        ],
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
              'Próximos Partidos',
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
                    'No hay partidos disponibles',
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
    final bool isFormal = match.tipo == 'FORMAL';
    final bool hasScore = match.golesLocal != null && match.golesVisitante != null;
    
    return SportCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchDetailScreen(match: match),
          ),
        );
      },
      child: Column(
        children: [
          // Header con tipo y estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isFormal ? AppTheme.primaryOrange.withOpacity(0.2) : AppTheme.cardBackgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isFormal ? 'FORMAL' : 'CASUAL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isFormal ? AppTheme.primaryOrange : AppTheme.secondaryText,
                  ),
                ),
              ),
              StatusBadge(
                text: match.estado,
                color: match.estado == 'ABIERTO' ? AppTheme.activeGreen : AppTheme.closedRed,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Equipos o deporte
          if (isFormal && (match.equipoLocalId != null || match.equipoVisitanteId != null))
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Equipo Local
                Expanded(
                  child: Column(
                    children: [
                      _buildTeamAvatar('LOCAL', match.equipoLocalId),
                      const SizedBox(height: 8),
                      Text(
                        'Equipo ${match.equipoLocalId ?? "?"}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Marcador o VS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: hasScore
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackgroundLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${match.golesLocal} : ${match.golesVisitante}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryOrange,
                            ),
                          ),
                        )
                      : const Text(
                          'VS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                ),
                // Equipo Visitante
                Expanded(
                  child: Column(
                    children: [
                      _buildTeamAvatar('VISIT', match.equipoVisitanteId),
                      const SizedBox(height: 8),
                      Text(
                        'Equipo ${match.equipoVisitanteId ?? "?"}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            // Partido casual - mostrar solo deporte
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppTheme.orangeGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getSportIcon(match.deporte),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Partido ${match.deporte}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${match.jugadoresActuales}/${match.maxJugadores} jugadores',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          // Footer con fecha y ubicación
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: AppTheme.secondaryText),
              const SizedBox(width: 4),
              Text(
                '${match.fechaProgramada.day}/${match.fechaProgramada.month}/${match.fechaProgramada.year}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.location_on, size: 14, color: AppTheme.secondaryText),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  match.nombreCanchaTexto ?? 'Por definir',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamAvatar(String prefix, int? teamId) {
    final colors = [
      AppTheme.primaryOrange,
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFF9C27B0),
      const Color(0xFFFF5722),
    ];
    final color = teamId != null ? colors[teamId % colors.length] : AppTheme.cardBackgroundLight;
    
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: teamId != null
            ? LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: teamId == null ? AppTheme.cardBackgroundLight : null,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (teamId != null ? color : Colors.black).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          teamId?.toString() ?? '?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: teamId != null ? Colors.white : AppTheme.secondaryText,
          ),
        ),
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