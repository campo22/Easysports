import 'dart:convert';
import 'package:easy_sports_app/src/models/standings_entry.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LeagueStandingsScreen extends StatefulWidget {
  const LeagueStandingsScreen({super.key});

  @override
  State<LeagueStandingsScreen> createState() => _LeagueStandingsScreenState();
}

class _LeagueStandingsScreenState extends State<LeagueStandingsScreen> {
  final ApiService _apiService = ApiService();
  List<StandingsEntry> _standings = [];
  bool _isLoading = true;
  int? _selectedLeagueId;

  @override
  void initState() {
    super.initState();
    _fetchStandings();
  }

  Future<void> _fetchStandings() async {
    if (_selectedLeagueId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getClasificacionLiga(_selectedLeagueId!);
      if (response.statusCode == 200) {
        final responseBody = response.body;
        final jsonData = jsonDecode(responseBody);

        setState(() {
          _standings = jsonData.map((item) => StandingsEntry.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        final contentType = response.headers['content-type'];
        String errorMessage = 'Error al cargar la clasificación';
        
        if (contentType != null && contentType.contains('application/json')) {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'Error en la obtención de datos';
        } else {
          errorMessage = response.body.isNotEmpty 
            ? response.body 
            : 'Código de error: ${response.statusCode}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de red: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clasificación de Ligas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: AppTheme.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar Liga',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedLeagueId,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Liga Principal')),
                    DropdownMenuItem(value: 2, child: Text('Liga Amateur')),
                    DropdownMenuItem(value: 3, child: Text('Copa Local')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedLeagueId = value;
                    });
                    _fetchStandings();
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _standings.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.leaderboard_outlined, size: 64, color: AppTheme.secondaryText),
                            SizedBox(height: 16),
                            Text(
                              'No hay datos de clasificación',
                              style: TextStyle(fontSize: 16, color: AppTheme.secondaryText),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchStandings,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _standings.length,
                          itemBuilder: (context, index) {
                            final team = _standings[index];
                            return Card(
                              color: AppTheme.cardBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                leading: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Center(
                                    child: Text(
                                      (index + 1).toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  team.nombreEquipo,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Puntos: ${team.puntos}',
                                  style: const TextStyle(color: AppTheme.secondaryText),
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'PJ: ${team.partidosJugados}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      'PG: ${team.partidosGanados}',
                                      style: const TextStyle(fontSize: 12, color: Colors.green),
                                    ),
                                    Text(
                                      'PP: ${team.partidosPerdidos}',
                                      style: const TextStyle(fontSize: 12, color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}