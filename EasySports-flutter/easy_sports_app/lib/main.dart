import 'package:easy_sports_app/src/screens/create_match_screen.dart';
import 'package:easy_sports_app/src/screens/create_team_screen.dart';
import 'package:easy_sports_app/src/screens/home_screen.dart';
import 'package:easy_sports_app/src/screens/invite_member_screen.dart';
import 'package:easy_sports_app/src/screens/join_match_screen.dart';
import 'package:easy_sports_app/src/screens/league_standings_screen.dart';
import 'package:easy_sports_app/src/screens/login_screen.dart';
import 'package:easy_sports_app/src/screens/match_detail_screen.dart';
import 'package:easy_sports_app/src/screens/register_result_screen.dart';
import 'package:easy_sports_app/src/screens/register_screen.dart';
import 'package:easy_sports_app/src/screens/team_invitations_screen.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasySports',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/create-match': (context) => const CreateMatchScreen(),
        '/create-team': (context) => const CreateTeamScreen(),
        '/join-match': (context) => const JoinMatchScreen(),
        '/invitations': (context) => const TeamInvitationsScreen(),
        '/league-standings': (context) => const LeagueStandingsScreen(),
        // No es necesario registrar aquí porque la navegación es por MaterialPageRoute
      },
    );
  }
}
