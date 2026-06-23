import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studytrack_design_system/studytrack_design_system.dart';

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
  String? _localBase64Image;
  String? _currentEmail;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(GetProfileRequested());
  }

  Future<void> _loadLocalImage(String email) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _localBase64Image = prefs.getString('profile_picture_$email');
    });
  }

  Future<void> _pickImage(ImageSource source, String email) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      PermissionStatus status;
      if (source == ImageSource.camera) {
        status = await Permission.camera.request();
      } else {
        status = await Permission.photos.request();
        if (status.isPermanentlyDenied || status.isDenied) {
          status = await Permission.storage.request();
        }
      }

      if (!status.isGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Necesitamos permisos para cambiar tu foto.')),
        );
        return;
      }
    }

    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source, imageQuality: 50);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_picture_$email', base64String);

      setState(() {
        _localBase64Image = base64String;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Foto actualizada con éxito!')),
      );
    }
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

          if (_currentEmail != email) {
            _currentEmail = email;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadLocalImage(email);
            });
          }
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
              child: CircularProgressIndicator(color: StColors.primary),
            ),
          );
        }

        final bool isProPlan = subscriptionTier.toUpperCase() == 'PRO';
        final String activeEmail = state is ProfileLoaded ? state.profile.email : '';

        return Scaffold(
          backgroundColor: StColors.background,
          appBar: AppBar(
            backgroundColor: StColors.background,
            elevation: 0,
            title: const Text(
              'Mi Perfil',
              style: TextStyle(fontWeight: FontWeight.bold, color: StColors.textPrimary),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    statusWidget ?? const SizedBox.shrink(),
                    
                    StCard(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              if (activeEmail.isEmpty) return;
                              showModalBottomSheet(
                                context: context,
                                builder: (_) => SafeArea(
                                  child: Wrap(
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.camera_alt),
                                        title: const Text('Tomar foto con Cámara'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _pickImage(ImageSource.camera, activeEmail);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.photo_library),
                                        title: const Text('Elegir de Galería'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _pickImage(ImageSource.gallery, activeEmail);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: StColors.border,
                                  backgroundImage: _localBase64Image != null && activeEmail == _currentEmail
                                      ? MemoryImage(base64Decode(_localBase64Image!))
                                      : null,
                                  child: _localBase64Image == null || activeEmail != _currentEmail
                                      ? const Icon(Icons.person, size: 50, color: StColors.textPrimary)
                                      : null,
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Icon(Icons.edit, color: Colors.blue, size: 20),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            fullName,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: StColors.textPrimary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 16,
                              color: StColors.textPrimary.withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isProPlan ? const Color(0xFFF59E0B).withValues(alpha: 0.1) : StColors.border,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isProPlan ? const Color(0xFFF59E0B) : StColors.border,
                              ),
                            ),
                            child: Text(
                              'Plan $subscriptionTier',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isProPlan ? const Color(0xFFF59E0B) : StColors.textPrimary.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    StCard(
                      child: Column(
                        children: [
                          _buildSettingsItem(
                            icon: Icons.access_time_filled_outlined,
                            title: 'Zona Horaria',
                            subtitle: timezone,
                            onTap: () {},
                          ),
                          const Divider(height: 1, color: StColors.border),
                          _buildSettingsItem(
                            icon: Icons.lock_outline,
                            title: 'Cambiar Contraseña',
                            onTap: () {},
                          ),
                          const Divider(height: 1, color: StColors.border),
                          _buildSettingsItem(
                            icon: Icons.notifications_none_outlined,
                            title: 'Notificaciones',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();

                          if (!context.mounted) return;
                          
                          context.read<AuthBloc>().add(AuthLogoutRequested());
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: StColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: StColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: StColors.textPrimary)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: StColors.textPrimary.withValues(alpha: 0.6))) : null,
      trailing: const Icon(Icons.chevron_right, color: StColors.border),
      onTap: onTap,
    );
  }
}