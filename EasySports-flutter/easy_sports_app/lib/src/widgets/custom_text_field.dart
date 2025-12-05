import 'package:flutter/material.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart'; // Importa el tema de la aplicación para los estilos.
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? icon;
  final List<TextInputFormatter>? inputFormatters; // Definido para formatear la entrada.

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.icon,
    this.inputFormatters, // Añadido al constructor.
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  void _toggleVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscured,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters, // Pasado al TextFormField.
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.primaryText),
      decoration: InputDecoration(
        labelText: widget.labelText,
        // Usando el tema de la app para el estilo.
        prefixIcon: widget.icon != null ? Icon(widget.icon, color: AppTheme.secondaryText) : null,
        // Añade un botón para mostrar/ocultar la contraseña si el campo es de tipo `obscureText`.
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.secondaryText,
                ),
                onPressed: _toggleVisibility,
              )
            : null,
      ),
    );
  }
}
