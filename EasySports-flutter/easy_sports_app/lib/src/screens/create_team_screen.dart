import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:easy_sports_app/src/widgets/sport_components.dart';
import 'package:flutter/material.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  final _nombreController = TextEditingController();
  // final _descripcionController = TextEditingController(); // Backend no soporta descripción
  String? _selectedDeporte;
  bool _isLoading = false;

  Future<void> _createTeam() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await _apiService.crearEquipo({
          'nombre': _nombreController.text.trim(),
          'tipoDeporte': _selectedDeporte,
        });

        if (response.statusCode == 201 || response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Equipo creado con éxito!'),
                backgroundColor: AppTheme.successGreen,
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${response.body}'),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Crear Equipo'),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Datos del Equipo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dale una identidad a tu equipo para empezar a competir.',
                style: TextStyle(fontSize: 16, color: AppTheme.secondaryText),
              ),
              const SizedBox(height: 32.0),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Equipo',
                  prefixIcon: Icon(Icons.shield, color: AppTheme.secondaryText),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Introduce un nombre' : null,
              ),
              const SizedBox(height: 16.0),
              // Selector de Deporte
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Deporte',
                  prefixIcon: Icon(Icons.sports_soccer, color: AppTheme.secondaryText),
                ),
                value: _selectedDeporte,
                items: ['FUTBOL', 'BASKET', 'VOLEY', 'AMERICANO']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDeporte = v),
                validator: (v) => v == null ? 'Selecciona un deporte' : null,
              ),
              const SizedBox(height: 16.0),
              /* Backend no soporta descripción
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  prefixIcon: Icon(Icons.description, color: AppTheme.secondaryText),
                ),
                maxLines: 3,
              ),*/
              const SizedBox(height: 32.0),
              PrimaryButton(
                text: 'Crear Equipo',
                onPressed: _createTeam,
                isLoading: _isLoading,
                icon: Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
