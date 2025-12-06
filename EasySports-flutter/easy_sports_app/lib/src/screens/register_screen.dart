import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easy_sports_app/src/providers/auth_provider.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:easy_sports_app/src/widgets/sport_components.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreCompletoController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String? _selectedSexo;
  late TextEditingController _edadAniosController;
  late TextEditingController _edadMesesController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreCompletoController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _edadAniosController = TextEditingController();
    _edadMesesController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreCompletoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _edadAniosController.dispose();
    _edadMesesController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await context.read<AuthProvider>().register(
              _nombreCompletoController.text.trim(),
              _emailController.text.trim(),
              _passwordController.text,
              _selectedSexo!,
              int.parse(_edadAniosController.text),
              int.parse(_edadMesesController.text),
            );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Registro exitoso! Bienvenido'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          Navigator.pushReplacementNamed(context, '/login'); 
        }

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
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
                'Únete a la comunidad',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Completa tus datos para empezar',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 32.0),
              TextFormField(
                controller: _nombreCompletoController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  prefixIcon: Icon(Icons.person_outline, color: AppTheme.secondaryText),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduce tu nombre completo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.secondaryText),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Introduce un email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock_outline, color: AppTheme.secondaryText),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedSexo,
                decoration: const InputDecoration(
                  labelText: 'Sexo',
                  prefixIcon: Icon(Icons.wc, color: AppTheme.secondaryText),
                ),
                dropdownColor: AppTheme.cardBackground,
                items: ['HOMBRE', 'MUJER'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(color: AppTheme.primaryText)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedSexo = newValue;
                  });
                },
                validator: (value) => value == null ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _edadAniosController,
                      decoration: const InputDecoration(
                        labelText: 'Años',
                        prefixIcon: Icon(Icons.cake_outlined, color: AppTheme.secondaryText),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Requerido';
                        if (int.tryParse(value) == null || int.parse(value) < 0) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: _edadMesesController,
                      decoration: const InputDecoration(
                        labelText: 'Meses',
                        prefixIcon: Icon(Icons.calendar_month, color: AppTheme.secondaryText),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Requerido';
                        final meses = int.tryParse(value);
                        if (meses == null || meses < 0 || meses > 11) return '0-11';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              PrimaryButton(
                text: 'Crear mi Cuenta',
                onPressed: _register,
                isLoading: _isLoading,
                icon: Icons.arrow_forward,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '¿Ya tienes cuenta? Inicia sesión',
                    style: TextStyle(color: AppTheme.primaryOrange),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
