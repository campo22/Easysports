import 'dart:convert';
import 'package:easy_sports_app/src/models/match.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:flutter/material.dart';

class MatchesDashboardScreen extends StatefulWidget {
  const MatchesDashboardScreen({super.key});

  @override
  State<MatchesDashboardScreen> createState() => _MatchesDashboardScreenState();
}

class _MatchesDashboardScreenState extends State<MatchesDashboardScreen> {
  final ApiService _apiService = ApiService();
  List<Match> _matches = [];
  bool _isLoading = true;
  String? _errorMessage;

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
      final response = await _apiService.get('/matches'); // Endpoint para obtener partidos

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          _matches = jsonResponse.map((matchJson) => Match.fromJson(matchJson)).toList();
        });
      } else {
        setState(() {
          _errorMessage = 'Error al cargar partidos: ${response.statusCode}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partidos Disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMatches,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Lógica para abrir filtros
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      ElevatedButton(
                        onPressed: _fetchMatches,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _matches.isEmpty
                  ? const Center(child: Text('No hay partidos disponibles.'))
                  : ListView.builder(
                      itemCount: _matches.length,
                      itemBuilder: (context, index) {
                        final match = _matches[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: ListTile(
                            title: Text(match.codigo),
                            subtitle: Text('${match.deporte} - ${match.estado} - ${match.fechaProgramada.toLocal().toString().split('.')[0]}'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/match-detail',
                                arguments: match.codigo,
                              );
                            },
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/create-match',
          ).then((value) => _fetchMatches()); // Refrescar la lista al volver
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}