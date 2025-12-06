import 'dart:convert';
import 'package:easy_sports_app/src/models/team.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:easy_sports_app/src/widgets/sport_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

enum TipoEncuentro { CASUAL, FORMAL }

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  // Wizard state
  int _currentStep = 0;

  // Controllers
  final _nombreController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _cupoController = TextEditingController();

  // State variables
  TipoEncuentro? _tipoEncuentro;
  String? _selectedDeporte;
  DateTime? _selectedDate;
  bool _isLoading = false;

  String? _selectedEquipoLocalId;
  String? _selectedEquipoVisitanteId;

  List<Team> _myTeams = [];
  List<Team> _allTeams = [];

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      final myTeamsResponse = await _apiService.getMisEquipos();
      final allTeamsResponse = await _apiService.getAllTeams();

      if (myTeamsResponse.statusCode == 200 && allTeamsResponse.statusCode == 200) {
        final myTeamsList = (jsonDecode(myTeamsResponse.body) as List)
            .map((t) => Team.fromJson(t))
            .toList();
        final allTeamsList = (jsonDecode(allTeamsResponse.body) as List)
            .map((t) => Team.fromJson(t))
            .toList();

        if (mounted) {
          setState(() {
            _myTeams = myTeamsList;
            _allTeams = allTeamsList;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading teams: $e');
    }
  }

  Future<void> _createMatch() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona una fecha y hora')),
        );
        return;
      }

      setState(() => _isLoading = true);

      final Map<String, dynamic> body = {
        'tipo': _tipoEncuentro!.name.toUpperCase(), // Backend expects UPPERCASE
        'deporte': _selectedDeporte,
        'fechaProgramada': _selectedDate!.toIso8601String(),
        'nombreCanchaTexto': _ubicacionController.text,
        'maxJugadores': int.tryParse(_cupoController.text) ?? 2,
      };

      // --- ERROR CORREGIDO AQUÍ ---
      if (_tipoEncuentro == TipoEncuentro.FORMAL) {
        body['equipoLocalId'] = _selectedEquipoLocalId;
        body['equipoVisitanteId'] = _selectedEquipoVisitanteId;
      }

      print('Sending body: $body'); // DEBUG: Print payload
      try {
        final response = await _apiService.crearEncuentro(body);
        print('Response status: ${response.statusCode}'); // DEBUG
        print('Response body: ${response.body}'); // DEBUG

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Encuentro creado con éxito!'),
                backgroundColor: AppTheme.successGreen,
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          // Handle API error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error API (${response.statusCode}): ${response.body}'),
                backgroundColor: AppTheme.errorRed,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } catch (e, stack) {
        print('Exception creating match: $e'); // DEBUG
        print('Stack trace: $stack'); // DEBUG
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error excepción: $e'),
              backgroundColor: AppTheme.errorRed,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _nextStep() {
    if (_currentStep == 0 && _tipoEncuentro != null) {
      setState(() => _currentStep = 1);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Crear Partido'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentStep == 0 ? () => Navigator.pop(context) : _previousStep,
        ),
      ),
      body: _currentStep == 0 ? _buildStepOne() : _buildStepTwo(),
    );
  }

  // PASO 1: Selección de tipo
  Widget _buildStepOne() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: '¿Qué tipo de\npartido es?',
            subtitle: 'Elige un tipo para configurar los detalles.',
          ),
          const SizedBox(height: 32),
          SelectionCard(
            icon: Icons.people,
            title: 'Casual',
            description: 'Un partido amistoso para divertirse.',
            isSelected: _tipoEncuentro == TipoEncuentro.CASUAL,
            onTap: () => setState(() => _tipoEncuentro = TipoEncuentro.CASUAL),
          ),
          const SizedBox(height: 16),
          SelectionCard(
            icon: Icons.emoji_events,
            title: 'Formal',
            description: 'Un partido competitivo.',
            isSelected: _tipoEncuentro == TipoEncuentro.FORMAL,
            onTap: () => setState(() => _tipoEncuentro = TipoEncuentro.FORMAL),
          ),
          const Spacer(),
          PrimaryButton(
            text: 'Continuar',
            onPressed: _tipoEncuentro != null ? _nextStep : () {},
            icon: Icons.arrow_forward,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // PASO 2: Formulario de detalles
  Widget _buildStepTwo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Detalles del Partido',
              subtitle: 'Completa la información de tu partido.',
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Partido (Opcional)',
                prefixIcon: Icon(Icons.sports_soccer, color: AppTheme.secondaryText),
              ),
            ),
            const SizedBox(height: 16),
            if (_tipoEncuentro == TipoEncuentro.FORMAL) _buildFormalMatchFields(),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Deporte',
                prefixIcon: Icon(Icons.sports, color: AppTheme.secondaryText),
              ),
              value: _selectedDeporte,
              items: ['FUTBOL', 'BASKET', 'VOLEY', 'AMERICANO']
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedDeporte = v),
              validator: (v) => v == null ? 'Selecciona un deporte' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ubicacionController,
              decoration: const InputDecoration(
                labelText: 'Ubicación',
                prefixIcon: Icon(Icons.location_on, color: AppTheme.secondaryText),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Ingresa una ubicación' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cupoController,
              decoration: const InputDecoration(
                labelText: 'Jugadores Máximos',
                prefixIcon: Icon(Icons.group, color: AppTheme.secondaryText),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requerido';
                if ((int.tryParse(v) ?? 0) < 2) return 'Mínimo 2 jugadores';
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDateTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha y Hora',
                  prefixIcon: Icon(Icons.calendar_today, color: AppTheme.secondaryText),
                ),
                child: Text(
                  _selectedDate == null
                      ? 'No seleccionada'
                      : DateFormat('MMM dd, yyyy - hh:mm a').format(_selectedDate!),
                  style: TextStyle(
                    color: _selectedDate == null ? AppTheme.secondaryText : AppTheme.primaryText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Crear Partido',
              onPressed: _createMatch,
              isLoading: _isLoading,
              icon: Icons.check,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFormalMatchFields() {
    // Filter out the selected local team from the visitor list
    final availableRivals = _allTeams.where((t) => t.id.toString() != _selectedEquipoLocalId).toList();

    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Equipo Local',
            prefixIcon: Icon(Icons.shield, color: AppTheme.secondaryText),
          ),
          value: _selectedEquipoLocalId,
          items: _myTeams.map((team) {
            return DropdownMenuItem(
              value: team.id.toString(),
              child: Text(team.nombre),
            );
          }).toList(),
          onChanged: (v) {
            setState(() {
              _selectedEquipoLocalId = v;
              // Reset visitor if it clashes
              if (_selectedEquipoVisitanteId == v) {
                _selectedEquipoVisitanteId = null;
              }
            });
          },
          validator: (v) => v == null ? 'Selecciona equipo local' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Equipo Visitante',
            prefixIcon: Icon(Icons.shield_outlined, color: AppTheme.secondaryText),
          ),
          value: _selectedEquipoVisitanteId,
          items: availableRivals.map((team) {
            return DropdownMenuItem(
              value: team.id.toString(),
              child: Text(team.nombre),
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedEquipoVisitanteId = v),
          validator: (v) => v == null ? 'Selecciona equipo visitante' : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _ubicacionController.dispose();
    _cupoController.dispose();
    super.dispose();
  }
}
