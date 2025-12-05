import 'package:easy_sports_app/src/screens/create_match_screen.dart';
import 'package:easy_sports_app/src/screens/matches_dashboard_screen.dart';
import 'package:easy_sports_app/src/screens/user_profile_screen.dart';
import 'package:easy_sports_app/src/screens/user_teams_screen.dart';
import 'package:easy_sports_app/src/screens/ligas_screen.dart';
import 'package:easy_sports_app/src/services/auth_service.dart'; // Importa el servicio
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService(); // Instancia el servicio
  int _selectedIndex = 0;
  String _userName = '...'; // Variable para guardar el nombre del usuario

  final GlobalKey<MatchesDashboardScreenState> _matchesDashboardKey = GlobalKey();
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _screens = <Widget>[
      MatchesDashboardScreen(key: _matchesDashboardKey),
      const UserTeamsScreen(),
      const LigasScreen(),
      const UserProfileScreen(),
    ];
  }

  Future<void> _loadUserData() async {
    final name = await _authService.getUserName();
    if (mounted) {
      setState(() {
        _userName = name ?? 'Usuario';
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToCreateMatch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateMatchScreen()),
    );
    if (result == true) {
      _matchesDashboardKey.currentState?.fetchMatches();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateMatch,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        elevation: 2.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hey,',
            style: TextStyle(fontSize: 14, color: AppTheme.secondaryText),
          ),
          Text(
            _userName, // Muestra el nombre real del usuario
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: AppTheme.primaryText),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TeamInvitationsScreen()),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () => _onItemTapped(3),
            child: const CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: AppTheme.cardBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildNavItem(icon: Icons.home, index: 0),
          _buildNavItem(icon: Icons.shield_outlined, index: 1),
          const SizedBox(width: 40),
          _buildNavItem(icon: Icons.star_border, index: 2),
          _buildNavItem(icon: Icons.person_outline, index: 3),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    return IconButton(
      icon: Icon(
        icon,
        color: _selectedIndex == index ? AppTheme.primaryColor : AppTheme.secondaryText,
        size: 28,
      ),
      onPressed: () => _onItemTapped(index),
    );
  }
}
