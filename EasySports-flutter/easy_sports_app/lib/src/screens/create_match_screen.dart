import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
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

  // Controllers
  final _nombreController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _cupoController = TextEditingController();

  // State variables
  TipoEncuentro _tipoEncuentro = TipoEncuentro.CASUAL;
  String? _selectedDeporte;
  DateTime? _selectedDate;
  bool _isLoading = false;

  // TODO: Cargar los equipos del usuario y los equipos rivales desde la API
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
        'tipoEncuentro': _tipoEncuentro.name,
        'deporte': _selectedDeporte,
        'fechaProgramada': _selectedDate!.toIso8601String(),
        'ubicacion': _ubicacionController.text,
        'maxJugadores': int.tryParse(_cupoController.text) ?? 2,
        'estado': 'PROGRAMADO',
      };

      if (_tipoEncuentro == TipoEncuentro.FORMAL) {
        body['equipoLocalId'] = _selectedEquipoLocalId;
        body['equipoVisitanteId'] = _selectedEquipoVisitanteId;
      }

      try {
        await _apiService.crearEncuentro(body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Encuentro creado con éxito!')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear el encuentro: $e')),
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
      lastDate: DateTime.now().add(const Duration(days: 3)), // Regla de negocio: max 3 días
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (time == null) return;

    // Regla de negocio: ajustar minutos a intervalos de 15
    final int minute = (time.minute / 15).round() * 15 % 60;

    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day, time.hour, minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Encuentro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tipo de Encuentro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildTypeSelector(),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del Partido (Opcional)'),
              ),
              const SizedBox(height: 16),
              if (_tipoEncuentro == TipoEncuentro.FORMAL)
                _buildFormalMatchFields(),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Deporte'),
                value: _selectedDeporte,
                items: ['FUTBOL', 'BALONCESTO', 'VOLEY', 'TENIS', 'OTRO'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setState(() => _selectedDeporte = v),
                validator: (v) => v == null ? 'Selecciona un deporte' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ubicacionController,
                      decoration: const InputDecoration(labelText: 'Ubicación'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Introduce una ubicación' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cupoController,
                      decoration: const InputDecoration(labelText: 'Cupo'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if ((int.tryParse(v) ?? 0) < 2) return '>= 2';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDateTime,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Fecha y Hora'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null ? 'No seleccionada' : DateFormat('dd/MM/yy - hh:mm a').format(_selectedDate!),
                      ),
                      const Icon(Icons.calendar_today, color: AppTheme.secondaryText),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _createMatch,
                      child: const Text('Crear Encuentro'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return SegmentedButton<TipoEncuentro>(
      segments: const [
        ButtonSegment(value: TipoEncuentro.CASUAL, label: Text('Casual'), icon: Icon(Icons.person_add_alt_1)),
        ButtonSegment(value: TipoEncuentro.FORMAL, label: Text('Formal'), icon: Icon(Icons.groups)),
      ],
      selected: {_tipoEncuentro},
      onSelectionChanged: (Set<TipoEncuentro> newSelection) {
        setState(() {
          _tipoEncuentro = newSelection.first;
        });
      },
      // Código corregido para ser compatible con versiones anteriores de Flutter
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return AppTheme.background;
            }
            return AppTheme.cardBackground;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return AppTheme.primaryColor;
            }
            return AppTheme.primaryText;
          },
        ),
      ),
    );
  }

  Widget _buildFormalMatchFields() {
    // TODO: Reemplazar con datos reales de la API
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Equipo Local'),
          items: const [
            DropdownMenuItem(value: '1', child: Text('Mi Equipo 1')),
            DropdownMenuItem(value: '2', child: Text('Mi Equipo 2')),
          ],
          onChanged: (v) => setState(() => _selectedEquipoLocalId = v),
          validator: (v) => v == null ? 'Selecciona equipo local' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Equipo Visitante'),
          items: const [
            DropdownMenuItem(value: '3', child: Text('Equipo Rival 1')),
            DropdownMenuItem(value: '4', child: Text('Equipo Rival 2')),
          ],
          onChanged: (v) => setState(() => _selectedEquipoVisitanteId = v),
          validator: (v) => v == null ? 'Selecciona equipo visitante' : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
