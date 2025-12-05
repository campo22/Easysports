import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LigasScreen extends StatelessWidget {
  const LigasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Ligas',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 80,
                      color: AppTheme.secondaryText.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Funcionalidad de Ligas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Próximamente disponible',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Aquí podrás ver las clasificaciones de las ligas y competir con otros equipos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.tertiaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
