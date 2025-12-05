import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales inspirados en el diseño
  static const Color primaryColor = Color(0xFFF37F1D); // Naranja vibrante
  static const Color accentColor = Color(0xFFFFA500);   // Naranja más claro para brillos
  static const Color primaryText = Colors.white;
  static const Color secondaryText = Colors.grey; 
  static const Color background = Color(0xFF1A1A1A);   // Fondo oscuro principal
  static const Color cardBackground = Color(0xFF2C2C2C); // Fondo para tarjetas

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: cardBackground,
      onSurface: primaryText,
      background: background,
      error: Colors.redAccent,
    ),
    // Usando el tema de texto por defecto temporalmente
    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: primaryText,
      displayColor: primaryText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryText),
      iconTheme: IconThemeData(color: primaryText),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardBackground,
      labelStyle: const TextStyle(color: secondaryText),
      hintStyle: const TextStyle(color: secondaryText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: cardBackground.withOpacity(0.8), // Fondo semi-transparente
      selectedItemColor: primaryColor,
      unselectedItemColor: secondaryText,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
  );
}
