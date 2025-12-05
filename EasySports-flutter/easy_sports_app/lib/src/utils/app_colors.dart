import 'package:flutter/material.dart';

class AppColors {
  // --- TEMÁTICA OSCURA REFINADA ---

  // Superficies
  static const Color background = Color(0xFF121212); // Negro casi puro para el fondo principal
  static const Color surface = Color(0xFF1E1E1E); // Gris oscuro para tarjetas y superficies primarias
  static const Color raisedSurface = Color(0xFF242424); // Gris para superficies elevadas como modales

  // Color de Acento y Gradientes
  static const Color accentBlue = Color(0xFF0052D4);
  static const Color accentCyan = Color(0xFF43C6AC);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentBlue, accentCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Texto
  static const Color textPrimary = Color(0xFFFFFFFF); // Blanco para texto principal y títulos
  static const Color textSecondary = Color(0xFFB0B0B0); // Gris claro para subtítulos y texto menos importante
  static const Color textHint = Color(0xFF757575); // Gris para texto de ayuda (hints)

  // Colores de Estado
  static const Color success = Color(0xFF4CAF50); // Verde para éxito
  static const Color error = Color(0xFFF44336); // Rojo para errores
  static const Color warning = Color(0xFFFF9800); // Naranja para advertencias

}
