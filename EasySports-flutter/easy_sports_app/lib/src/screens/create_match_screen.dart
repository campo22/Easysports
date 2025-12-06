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
        title: const Text('Create Match'),
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
            title: 'What kind of\nmatch is it?',
            subtitle: 'Choose a type to set up your game details.',
          ),
          const SizedBox(height: 32),
          SelectionCard(
            icon: Icons.people,
            title: 'Casual',
            description: 'A friendly game for fun.',
            isSelected: _tipoEncuentro == TipoEncuentro.CASUAL,
            onTap: () => setState(() => _tipoEncuentro = TipoEncuentro.CASUAL),
          ),
          const SizedBox(height: 16),
          SelectionCard(
            icon: Icons.emoji_events,
            title: 'Formal',
            description: 'A competitive match.',
            isSelected: _tipoEncuentro == TipoEncuentro.FORMAL,
            onTap: () => setState(() => _tipoEncuentro = TipoEncuentro.FORMAL),
          ),
          const Spacer(),
          PrimaryButton(
            text: 'Continue',
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
              title: 'Match Details',
              subtitle: 'Fill in the information for your match.',
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Match Name (Optional)',
                prefixIcon: Icon(Icons.sports_soccer, color: AppTheme.secondaryText),
              ),
            ),
            const SizedBox(height: 16),
            if (_tipoEncuentro == TipoEncuentro.FORMAL) _buildFormalMatchFields(),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Sport',
                prefixIcon: Icon(Icons.sports, color: AppTheme.secondaryText),
              ),
              value: _selectedDeporte,
              items: ['FUTBOL', 'BASKET', 'VOLEY', 'AMERICANO']
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedDeporte = v),
              validator: (v) => v == null ? 'Select a sport' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ubicacionController,
              decoration: const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(Icons.location_on, color: AppTheme.secondaryText),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Enter a location' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cupoController,
              decoration: const InputDecoration(
                labelText: 'Max Players',
                prefixIcon: Icon(Icons.group, color: AppTheme.secondaryText),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if ((int.tryParse(v) ?? 0) < 2) return 'Min 2 players';
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDateTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date & Time',
                  prefixIcon: Icon(Icons.calendar_today, color: AppTheme.secondaryText),
                ),
                child: Text(
                  _selectedDate == null
                      ? 'Not selected'
                      : DateFormat('MMM dd, yyyy - hh:mm a').format(_selectedDate!),
                  style: TextStyle(
                    color: _selectedDate == null ? AppTheme.secondaryText : AppTheme.primaryText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Create Match',
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
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Home Team',
            prefixIcon: Icon(Icons.shield, color: AppTheme.secondaryText),
          ),
          items: const [
            DropdownMenuItem(value: '1', child: Text('My Team 1')),
            DropdownMenuItem(value: '2', child: Text('My Team 2')),
          ],
          onChanged: (v) => setState(() => _selectedEquipoLocalId = v),
          validator: (v) => v == null ? 'Select home team' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Away Team',
            prefixIcon: Icon(Icons.shield_outlined, color: AppTheme.secondaryText),
          ),
          items: const [
            DropdownMenuItem(value: '3', child: Text('Rival Team 1')),
            DropdownMenuItem(value: '4', child: Text('Rival Team 2')),
          ],
          onChanged: (v) => setState(() => _selectedEquipoVisitanteId = v),
          validator: (v) => v == null ? 'Select away team' : null,
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
