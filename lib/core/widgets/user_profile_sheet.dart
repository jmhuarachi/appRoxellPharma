import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roxellpharma/core/costants/app_colors.dart';
import 'package:roxellpharma/core/widgets/profile_option.dart';
import 'package:roxellpharma/features/auth/presentation/login_screen.dart';
import 'package:roxellpharma/features/auth/presentation/providers/auth_provider.dart';

class UserProfileSheet extends StatelessWidget {
  const UserProfileSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Avatar y información básica
          const _UserProfileHeader(),
          const SizedBox(height: 32),
          // Opciones del perfil
          Expanded(
            child: _ProfileOptionsList(),
          ),
        ],
      ),
    );
  }
}

class _UserProfileHeader extends StatelessWidget {
  const _UserProfileHeader();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    
    return Column(
      children: [
        Hero(
          tag: 'user_avatar',
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.orange400, AppColors.orange600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange200.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user?.name ?? 'Administrador',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.gray800,
          ),
        ),
        Text(
          user?.email ?? 'admin@empresa.com',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.gray600,
          ),
        ),
        const SizedBox(height: 8),
        if (user?.role != null)
          Text(
            'Rol: ${user!.role}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray500,
            ),
          ),
        if (user?.sucursalId != null)
          Text(
            'Sucursal: ${user!.sucursalName ?? 'No asignada'}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray500,
            ),
          ),
      ],
    );
  }
}

class _ProfileOptionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        ProfileOption(
          icon: Icons.person_outline_rounded,
          title: 'Editar Perfil',
          onTap: () {},
        ),
        ProfileOption(
          icon: Icons.security_rounded,
          title: 'Cambiar Contraseña',
          onTap: () {},
        ),
        ProfileOption(
          icon: Icons.notifications_rounded,
          title: 'Notificaciones',
          onTap: () {},
        ),
        ProfileOption(
          icon: Icons.help_outline_rounded,
          title: 'Ayuda y Soporte',
          onTap: () {},
        ),
        ProfileOption(
          icon: Icons.info_outline_rounded,
          title: 'Acerca de',
          onTap: () {},
        ),
        const SizedBox(height: 20),
        _LogoutButton(),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLogoutDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.red600.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.red600),
            SizedBox(width: 8),
            Text(
              'Cerrar Sesión',
              style: TextStyle(
                color: AppColors.red600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _performLogout(context);
    }
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Cerrar sesión
      await Provider.of<AuthProvider>(context, listen: false).logout();

      // Navegar al login y limpiar stack
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Cerrar el loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}