import 'package:easy_sports_app/src/providers/auth_provider.dart';
import 'package:easy_sports_app/src/services/api_service.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:easy_sports_app/src/widgets/sport_components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  String? _selectedGender;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _nameController = TextEditingController(text: authProvider.userName);
    _emailController = TextEditingController(text: authProvider.userEmail);
    _ageController = TextEditingController(); // Assuming age isn't easily available in AuthProvider yet
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final response = await _apiService.updateProfile({
        'nombreCompleto': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'sexo': _selectedGender ?? 'MASCULINO',
        'edadAnios': int.tryParse(_ageController.text) ?? 18,
        'edadMeses': 0,
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Update local provider
        context.read<AuthProvider>().updateLocalUser(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
        );
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: AppTheme.activeGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: ${response.statusCode}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Editar Perfil', style: TextStyle(color: AppTheme.primaryText)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppTheme.primaryText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Nombre Completo',
                icon: Icons.person,
                validator: (v) => v?.isEmpty == true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                enabled: false, // Email usually read-only or strictly validated
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ageController,
                label: 'Edad (Años)',
                icon: Icons.cake,
                keyboardType: TextInputType.number,
                 validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  final n = int.tryParse(v);
                  if (n == null || n < 5) return 'Edad inválida';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                dropdownColor: AppTheme.cardBackground,
                decoration: const InputDecoration(
                  labelText: 'Sexo',
                  prefixIcon: Icon(Icons.people, color: AppTheme.primaryOrange),
                  filled: true,
                  fillColor: AppTheme.cardBackground,
                  labelStyle: TextStyle(color: AppTheme.secondaryText),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent), borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                items: ['MASCULINO', 'FEMENINO', 'OTRO']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: const TextStyle(color: AppTheme.primaryText)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedGender = v),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Guardar Cambios',
                  isLoading: _isLoading,
                  onPressed: _updateProfile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.primaryText),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryOrange),
        filled: true,
        fillColor: AppTheme.cardBackground,
        labelStyle: const TextStyle(color: AppTheme.secondaryText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryOrange),
        ),
      ),
    );
  }
}
