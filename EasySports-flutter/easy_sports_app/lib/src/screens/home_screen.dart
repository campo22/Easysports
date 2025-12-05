import 'package:easy_sports_app/src/screens/create_match_screen.dart';
import 'package:easy_sports_app/src/screens/matches_dashboard_screen.dart';
import 'package:easy_sports_app/src/screens/user_profile_screen.dart';
import 'package:easy_sports_app/src/screens/ligas_screen.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'home_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = <Widget>[
      const HomeDashboardScreen(),
      const MatchesDashboardScreen(),
      const LigasScreen(),
      const UserProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // Centro - Crear partido
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateMatchScreen()),
      );
      return;
    }
    
    // Mapear índices: 0=Home, 1=Matches, 2=Create(skip), 3=Leagues, 4=Profile
    // A índices de pantalla: 0=Home, 1=Matches, 2=Leagues, 3=Profile
    int screenIndex;
    if (index < 2) {
      screenIndex = index; // 0=Home, 1=Matches
    } else {
      screenIndex = index - 1; // 3=Leagues(2), 4=Profile(3)
    }
    
    setState(() {
      _selectedIndex = screenIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.sports_soccer, 'Matches', 1),
          _buildCenterButton(),
          _buildNavItem(Icons.emoji_events, 'Leagues', 3),
          _buildNavItem(Icons.person, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int navIndex) {
    // Calcular el índice de pantalla real
    int screenIndex;
    if (navIndex < 2) {
      screenIndex = navIndex;
    } else {
      screenIndex = navIndex - 1;
    }
    
    final isSelected = _selectedIndex == screenIndex;
    
    return GestureDetector(
      onTap: () => _onItemTapped(navIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryOrange : AppTheme.tertiaryText,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppTheme.primaryOrange : AppTheme.tertiaryText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = screenIndex;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryOrange : AppTheme.tertiaryText,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppTheme.primaryOrange : AppTheme.tertiaryText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () => _onItemTapped(2),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppTheme.orangeGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryOrange.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
