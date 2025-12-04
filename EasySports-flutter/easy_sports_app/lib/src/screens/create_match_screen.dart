import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/models/match.dart'; // Import the Match model

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final TextEditingController _nombreController = TextEditingController();
  String? _selectedDeporte;
  String? _selectedTipo;
  final TextEditingController _fechaProgramdaController = TextEditingController();
  final TextEditingController _maxJugadoresController = TextEditingController();
  final TextEditingController _canchaIdController = TextEditingController();
  final TextEditingController _nombreCanchaTextoController = TextEditingController();
  final TextEditingController _equipoLocalIdController = TextEditingController();
  final TextEditingController _equipoVisitanteIdController = TextEditingController();

  bool _isLoading = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _nombreController.dispose();
    _fechaProgramdaController.dispose();
    _maxJugadoresController.dispose();
    _canchaIdController.dispose();
    _nombreCanchaTextoController.dispose();
    _equipoLocalIdController.dispose();
    _equipoVisitanteIdController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3)), // Max 3 days in future
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fechaProgramdaController.text =
            "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      // Validate minutes are multiples of 15
      if (picked.minute % 15 != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La hora debe ser en múltiplos de 15 minutos.')),
        );
        return;
      }
      setState(() {
        _selectedTime = picked;
        _fechaProgramdaController.text =
            "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} ${picked.format(context)}";
      });
    }
  }

  Future<void> _createMatch() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Construct fechaProgramada
      DateTime? dateTime;
      if (_selectedDate != null && _selectedTime != null) {
        dateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
      }

      final Map<String, dynamic> matchData = {
        'nombre': _nombreController.text,
        'tipo': _selectedTipo,
        'deporte': _selectedDeporte,
        'fechaProgramada': dateTime?.toIso8601String(),
        'maxJugadores': int.parse(_maxJugadoresController.text),
      };

      if (_canchaIdController.text.isNotEmpty) {
        matchData['canchaId'] = int.parse(_canchaIdController.text);
      } else if (_nombreCanchaTextoController.text.isNotEmpty) {
        matchData['nombreCanchaTexto'] = _nombreCanchaTextoController.text;
      }

      if (_selectedTipo == 'FORMAL') {
        if (_equipoLocalIdController.text.isNotEmpty) {
          matchData['equipoLocalId'] = int.parse(_equipoLocalIdController.text);
        }
        if (_equipoVisitanteIdController.text.isNotEmpty) {
          matchData['equipoVisitanteId'] = int.parse(_equipoVisitanteIdController.text);
        }
      }

      try {
        final response = await _apiService.post('/matches', matchData);

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          final Match newMatch = Match.fromJson(data);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Partido ${newMatch.codigo} creado exitosamente!')),
          );
          Navigator.pop(context); // Go back to dashboard
        } else {
          final errorData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear partido: ${errorData['reason'] ?? errorData['message'] ?? 'Error desconocido'}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Partido'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Partido',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un nombre para el partido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Deporte',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDeporte,
                items: ['FUTBOL', 'BALONCESTO', 'VOLEY', 'TENIS']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDeporte = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecciona un deporte';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Partido',
                  border: OutlineInputBorder(),
                ),
                value: _selectedTipo,
                items: ['CASUAL', 'FORMAL']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTipo = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecciona un tipo de partido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _fechaProgramdaController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Fecha y Hora Programada',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      await _selectDate(context);
                      if (_selectedDate != null) {
                        await _selectTime(context);
                      }
                    },
                  ),
                ),
                validator: (value) {
                  if (_selectedDate == null || _selectedTime == null) {
                    return 'Por favor, selecciona fecha y hora';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _maxJugadoresController,
                decoration: const InputDecoration(
                  labelText: 'Máximo de Jugadores',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Introduce un número válido de jugadores';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _canchaIdController,
                decoration: const InputDecoration(
                  labelText: 'ID de Cancha (opcional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _nombreCanchaTextoController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de Cancha (texto, opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_selectedTipo == 'FORMAL') ...[
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _equipoLocalIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID Equipo Local',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (_selectedTipo == 'FORMAL' && (value == null || value.isEmpty || int.tryParse(value) == null)) {
                      return 'Para partidos formales, el ID del equipo local es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _equipoVisitanteIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID Equipo Visitante (opcional)',
                    border: OutlineInputBorder(),
                    hintText: 'Dejar vacío si no hay equipo visitante',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 24.0),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _createMatch,
                      child: const Text('Crear Partido'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}