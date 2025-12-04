import 'package:easy_sports_app/src/screens/matches_dashboard_screen.dart';
import 'package:easy_sports_app/src/screens/user_profile_screen.dart';
import 'package:easy_sports_app/src/screens/user_teams_screen.dart';
import 'package:easy_sports_app/src/screens/ligas_screen.dart'; // Importar la pantalla de ligas
import 'package:easy_sports_app/src/screens/login_screen.dart'; // Para el logout
import 'package:easy_sports_app/src/services/api_service.dart'; // Para el logout
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    const MatchesDashboardScreen(),
    const UserTeamsScreen(),
    const LigasScreen(), // Añadir la nueva pantalla de ligas
    const UserProfileScreen(),
  ];

  static final List<String> _titles = <String>[
    'Partidos',
    'Mis Equipos',
    'Ligas',
    'Perfil',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ApiService().deleteToken();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Partidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Equipos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Ligas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}