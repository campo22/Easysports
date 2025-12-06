import 'package:easy_sports_app/src/screens/home_screen.dart';
import 'package:easy_sports_app/src/screens/login_screen.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_sports_app/src/providers/auth_provider.dart';

class AuthWrapperScreen extends StatelessWidget {
  const AuthWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    // Usar un AnimatedSwitcher para evitar problemas de estado entre widgets
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: authProvider.isAuthenticated
            ? const HomeScreen(key: ValueKey('home'))
            : const LoginScreen(key: ValueKey('login')),
      ),
    );
  }
}