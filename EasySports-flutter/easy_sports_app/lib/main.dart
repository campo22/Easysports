import 'package:easy_sports_app/src/screens/create_match_screen.dart';
import 'package:easy_sports_app/src/screens/create_team_screen.dart';
import 'package:easy_sports_app/src/screens/home_screen.dart';
import 'package:easy_sports_app/src/screens/login_screen.dart';
import 'package:easy_sports_app/src/screens/register_screen.dart';
import 'package:easy_sports_app/src/screens/edit_profile_screen.dart';
import 'package:easy_sports_app/src/screens/team_invitations_screen.dart';
import 'package:easy_sports_app/src/screens/user_teams_screen.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:easy_sports_app/src/widgets/auth_wrapper_screen.dart';
import 'package:flutter/material.dart';

import 'package:easy_sports_app/src/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final authProvider = AuthProvider();
  await authProvider.loadToken();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasySports',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapperScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/create-match': (context) => const CreateMatchScreen(),
        '/create-team': (context) => const CreateTeamScreen(),
        '/user-teams': (context) => const UserTeamsScreen(),
        '/invitations': (context) => const TeamInvitationsScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
      },
    );
  }
}
