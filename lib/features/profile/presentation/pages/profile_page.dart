import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../features/auth/presentation/pages/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí idealmente consumirías un ProfileBloc que haga un GET a /api/users/me
    // Por ahora, maquetamos con datos estáticos basados en tu esquema de Prisma
    const String fullName = "Estudiante Universitario";
    const String email = "estudiante@ucb.edu.bo";
    const String subscriptionTier = "PRO"; // free o pro
    const String timezone = "America/La_Paz";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: const Text(
          'Mi Perfil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Sección de Avatar y Nombre
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFE2E8F0),
                child: Icon(Icons.person, size: 50, color: Color(0xFF64748B)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              fullName,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            const Text(
              email,
              style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            
            // Badge de Suscripción (Basado en tu enum subscription_type)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: subscriptionTier == 'PRO' ? const Color(0xFFF59E0B).withOpacity(0.1) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: subscriptionTier == 'PRO' ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Text(
                'Plan $subscriptionTier',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: subscriptionTier == 'PRO' ? const Color(0xFFF59E0B) : const Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Opciones de Configuración
            _buildSettingsItem(
              icon: Icons.access_time_filled_outlined,
              title: 'Zona Horaria',
              subtitle: timezone,
              onTap: () {},
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            _buildSettingsItem(
              icon: Icons.lock_outline,
              title: 'Cambiar Contraseña',
              onTap: () {},
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            _buildSettingsItem(
              icon: Icons.notifications_none_outlined,
              title: 'Notificaciones',
              onTap: () {},
            ),
            const SizedBox(height: 32),

            // Botón de Cerrar Sesión (Con lógica real del BLoC)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Despacha el evento para borrar todo rastro del JWT en SharedPreferences
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                  
                  // Redirige al login limpiando el historial de navegación
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                label: const Text('Cerrar Sesión', style: TextStyle(color: Color(0xFFEF4444), fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para mantener el código limpio
  Widget _buildSettingsItem({required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1D4ED8).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF1D4ED8)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))) : null,
      trailing: const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
      onTap: onTap,
    );
  }
}