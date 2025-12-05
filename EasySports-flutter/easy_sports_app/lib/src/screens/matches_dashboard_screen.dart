import 'dart:convert';
import 'package:easy_sports_app/src/models/match.dart';
import 'package:easy_sports_app/src/screens/match_detail_screen.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchesDashboardScreen extends StatefulWidget {
  const MatchesDashboardScreen({Key? key}) : super(key: key);

  @override
  MatchesDashboardScreenState createState() => MatchesDashboardScreenState();
}

class MatchesDashboardScreenState extends State<MatchesDashboardScreen> {
  final ApiService _apiService = ApiService();
  List<Match> _matches = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getPartidos();
      if (!mounted) return;
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        // El backend devuelve una respuesta paginada con la estructura { content: [...] }
        final List<dynamic> matchesList = jsonData['content'] ?? [];
        setState(() {
          _matches = matchesList.map((matchJson) => Match.fromJson(matchJson)).toList();
        });
      } else {
        setState(() {
          _errorMessage = 'Error del servidor: ${response.statusCode}. ${response.body}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No se pudo conectar al servidor. Asegúrate de que el backend esté funcionando. Error: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
            ? _buildErrorView(_errorMessage!, fetchMatches)
            : _buildDashboard();
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategories(),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Top Leaders in Soccer'),
          const SizedBox(height: 16),
          _buildTopLeadersCard(),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Upcoming Matches'),
          const SizedBox(height: 16),
          _matches.isEmpty
              ? const Center(child: Text('No hay partidos disponibles.'))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _matches.length,
                  itemBuilder: (context, index) {
                    return _BetMatchCard(match: _matches[index]);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    // Placeholder for categories
    final categories = ['Football', 'Tennis', 'Basketball', 'Cricket', 'Soccer'];
    final icons = [Icons.sports_soccer, Icons.sports_tennis, Icons.sports_basketball, Icons.sports_cricket, Icons.sports_volleyball];
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                CircleAvatar(radius: 25, backgroundColor: AppTheme.cardBackground, child: Icon(icons[index], color: AppTheme.primaryColor)),
                const SizedBox(height: 8),
                Text(categories[index], style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopLeadersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage('https://i.pravatar.cc/400?img=3'), // Placeholder
          fit: BoxFit.cover,
          opacity: 0.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Watch Now', style: TextStyle(color: AppTheme.primaryColor)),
          const SizedBox(height: 8),
          const Text('Top players battling it out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () {}, child: const Text('Watch Now →')),
        ],
      ),
    );
  }
}

class _BetMatchCard extends StatelessWidget {
  final Match match;
  const _BetMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMMM / hh:mm a').format(match.fechaProgramada);

    return Card(
      color: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=1')), // Placeholder
                    SizedBox(width: 12),
                    Text('FCB / FC BM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                _StatusChip(status: match.estado),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('\$440 / 2.2', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryText)),
                Text(formattedDate, style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final bool isActive = status.toUpperCase() == 'PROGRAMADO';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'CLOSED',
        style: TextStyle(color: isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }
}

Widget _buildErrorView(String message, VoidCallback onRetry) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          const Text('¡Oops! Algo salió mal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(fontSize: 16, color: AppTheme.secondaryText), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    ),
  );
}
