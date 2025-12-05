import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_sports_app/src/providers/auth_provider.dart';
import 'package:easy_sports_app/src/theme/app_theme.dart';
import 'package:easy_sports_app/src/widgets/sport_components.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.userName ?? 'Usuario';
    final userEmail = authProvider.userEmail ?? 'email@example.com';

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, userName),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(userName, userEmail),
                  const SizedBox(height: 24),
                  _buildStatsSection(),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildSettingsSection(context, authProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String userName) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.backgroundDark,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryOrange.withOpacity(0.3),
                AppTheme.backgroundDark,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryOrange, width: 3),
                    gradient: AppTheme.orangeGradient,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String userName, String userEmail) {
    return SportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información Personal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person_outline, 'Nombre', userName),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.email_outlined, 'Email', userEmail),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryOrange, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.secondaryText,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estadísticas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('Partidos', '12', Icons.sports_soccer)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Equipos', '3', Icons.groups)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Victorias', '8', Icons.emoji_events)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Rating', '4.5', Icons.star)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return SportCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryOrange, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText,
          ),
        ),
        const SizedBox(height: 16),
        SportCard(
          onTap: () => Navigator.pushNamed(context, '/user-teams'),
          child: const Row(
            children: [
              Icon(Icons.shield, color: AppTheme.primaryOrange, size: 28),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Mis Equipos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: AppTheme.secondaryText, size: 16),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SportCard(
          onTap: () => Navigator.pushNamed(context, '/team-invitations'),
          child: const Row(
            children: [
              Icon(Icons.mail_outline, color: AppTheme.primaryOrange, size: 28),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Invitaciones',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: AppTheme.secondaryText, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configuración',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText,
          ),
        ),
        const SizedBox(height: 16),
        SportCard(
          onTap: () {
            // TODO: Implementar edición de perfil
          },
          child: const Row(
            children: [
              Icon(Icons.edit_outlined, color: AppTheme.secondaryText, size: 24),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Editar Perfil',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.primaryText,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: AppTheme.secondaryText, size: 16),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SportCard(
          onTap: () async {
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppTheme.cardBackground,
                title: const Text('Cerrar Sesión', style: TextStyle(color: AppTheme.primaryText)),
                content: const Text(
                  '¿Estás seguro de que quieres cerrar sesión?',
                  style: TextStyle(color: AppTheme.secondaryText),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar', style: TextStyle(color: AppTheme.secondaryText)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Cerrar Sesión', style: TextStyle(color: AppTheme.errorRed)),
                  ),
                ],
              ),
            );

            if (shouldLogout == true && context.mounted) {
              await authProvider.logout();
            }
          },
          child: const Row(
            children: [
              Icon(Icons.logout, color: AppTheme.errorRed, size: 24),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.errorRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: AppTheme.errorRed, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}
