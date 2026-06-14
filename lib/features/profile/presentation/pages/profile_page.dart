import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../features/auth/presentation/pages/login_page.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(GetProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String fullName = 'Cargando perfil...';
        String email = 'Cargando correo...';
        String subscriptionTier = '...';
        String timezone = 'Cargando zona horaria...';
        Widget? statusWidget;

        if (state is ProfileLoaded) {
          fullName = state.profile.fullName;
          email = state.profile.email;
          subscriptionTier = state.profile.subscriptionTier;
          timezone = state.profile.timezone;
        } else if (state is ProfileError) {
          fullName = 'No se pudo cargar el perfil';
          email = state.message;
          subscriptionTier = 'ERROR';
          timezone = 'Sin datos';
          statusWidget = Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        } else if (state is ProfileLoading || state is ProfileInitial) {
          statusWidget = const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF1D4ED8)),
            ),
          );
        }

        final bool isProPlan = subscriptionTier.toUpperCase() == 'PRO';

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
                if (statusWidget != null) statusWidget,
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFFE2E8F0),
                    child: Icon(Icons.person, size: 50, color: Color(0xFF64748B)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  fullName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isProPlan ? const Color(0xFFF59E0B).withOpacity(0.1) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isProPlan ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Text(
                    'Plan $subscriptionTier',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isProPlan ? const Color(0xFFF59E0B) : const Color(0xFF64748B),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildSettingsItem(
                  icon: Icons.access_time_filled_outlined,
                  title: 'Zona Horaria',
                  subtitle: timezone,
                  onTap: () {},
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _buildSettingsItem(
                  icon: Icons.lock_outline,
                  title: 'Cambiar Contrase\u00f1a',
                  onTap: () {},
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _buildSettingsItem(
                  icon: Icons.notifications_none_outlined,
                  title: 'Notificaciones',
                  onTap: () {},
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLogoutRequested());

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                    label: const Text('Cerrar Sesi\u00f3n', style: TextStyle(color: Color(0xFFEF4444), fontSize: 16)),
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
      },
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
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
