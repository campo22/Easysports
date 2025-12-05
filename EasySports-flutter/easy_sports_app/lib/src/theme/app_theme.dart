import 'package:flutter/material.dart';

/// Sistema de diseño deportivo moderno para EasySports
/// Inspirado en diseño de apuestas deportivas con tonos oscuros y acentos naranjas/dorados
class AppTheme {
  // Paleta de colores principal
  static const Color primaryOrange = Color(0xFFFF8C42); // Naranja principal (botones, acentos)
  static const Color darkOrange = Color(0xFFE67E22);    // Naranja oscuro
  static const Color goldAccent = Color(0xFFFFB84D);    // Dorado para highlights
  
  // Fondos oscuros con gradiente marrón
  static const Color backgroundDark = Color(0xFF0D0D0D);      // Negro profundo
  static const Color backgroundBrown = Color(0xFF1A1410);     // Marrón muy oscuro
  static const Color cardBackground = Color(0xFF1F1B17);      // Marrón oscuro para cards
  static const Color cardBackgroundLight = Color(0xFF2A2520); // Marrón medio para hover
  
  // Textos
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFB0B0B0);
  static const Color tertiaryText = Color(0xFF707070);
  
  // Estados
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color activeGreen = Color(0xFF00E676);
  static const Color errorRed = Color(0xFFFF5252);
  static const Color closedRed = Color(0xFFD32F2F);
  
  // Gradientes
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [primaryOrange, darkOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [backgroundDark, backgroundBrown],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    primaryColor: primaryOrange,
    fontFamily: 'Poppins', // Fuente moderna y deportiva
    
    colorScheme: const ColorScheme.dark(
      primary: primaryOrange,
      secondary: goldAccent,
      surface: cardBackground,
      onSurface: primaryText,
      background: backgroundDark,
      error: errorRed,
    ),
    
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryText),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryText),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryText),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primaryText),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primaryText),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: primaryText),
      bodyLarge: TextStyle(fontSize: 16, color: primaryText),
      bodyMedium: TextStyle(fontSize: 14, color: secondaryText),
      bodySmall: TextStyle(fontSize: 12, color: tertiaryText),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: primaryText,
        fontFamily: 'Poppins',
      ),
      iconTheme: IconThemeData(color: primaryText),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardBackground,
      labelStyle: const TextStyle(color: secondaryText),
      hintStyle: const TextStyle(color: tertiaryText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: cardBackgroundLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: primaryOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: errorRed, width: 1),
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    ),
    
    cardTheme: CardTheme(
      color: cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardBackground,
      selectedItemColor: primaryOrange,
      unselectedItemColor: tertiaryText,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 0,
    ),
  );
}
