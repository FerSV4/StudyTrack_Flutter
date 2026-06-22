import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studytrack_design_system/studytrack_design_system.dart';
import 'agenda_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../academic/presentation/pages/create_term_page.dart';
import '../../../academic/presentation/bloc/academic_bloc.dart';
import '../../../academic/presentation/bloc/academic_event.dart';
import '../../../academic/presentation/bloc/academic_state.dart';
import '../../../study_sessions/presentation/pages/timer_page.dart';
import '../widgets/task_form_bottom_sheet.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _localBase64Image;
  String? _currentEmail;

  @override
  void initState() {
    super.initState();
    context.read<AcademicBloc>().add(GetActiveTermRequested());
    context.read<ProfileBloc>().add(GetProfileRequested());
  }

  Future<void> _loadLocalImage(String email) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _localBase64Image = prefs.getString('profile_picture_$email');
    });
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                String greeting = 'Hola, Estudiante';
                
                if (state is ProfileLoaded) {
                  final firstName = state.profile.fullName.split(' ').first;
                  greeting = 'Hola, $firstName';

                  if (_currentEmail != state.profile.email) {
                    _currentEmail = state.profile.email;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _loadLocalImage(state.profile.email);
                    });
                  }
                }
                
                return Text(
                  greeting,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                );
              },
            ),
            BlocBuilder<AcademicBloc, AcademicState>(
              builder: (context, state) {
                String termName = 'Cargando semestre...';
                if (state is AcademicLoaded) {
                  termName = state.term.name;
                } else if (state is AcademicError) {
                  termName = 'Error de conexión';
                }
                return Text(
                  termName,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                );
              },
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                final bool hasImage = _localBase64Image != null && 
                                      state is ProfileLoaded && 
                                      state.profile.email == _currentEmail;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
                  },
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFFE2E8F0),
                    backgroundImage: hasImage ? MemoryImage(base64Decode(_localBase64Image!)) : null,
                    child: hasImage ? null : const Icon(Icons.person, color: Color(0xFF64748B)),
                  ),
                );
              },
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BlocBuilder<AcademicBloc, AcademicState>(
                builder: (context, state) {
                  if (state is AcademicLoading || state is AcademicInitial) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF1D4ED8)));
                  }

                  if (state is AcademicEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Aún no tienes un semestre activo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 240,
                            child: StButton(
                              text: 'Configurar Semestre',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CreateTermPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (state is AcademicError) {
                    return Center(
                      child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
                    );
                  }

                  if (state is AcademicLoaded) {
                    final subjects = state.term.subjects;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mis Materias',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: subjects.isEmpty
                              ? const Center(child: Text('No tienes materias registradas en este semestre.'))
                              : ListView.builder(
                                  itemCount: subjects.length,
                                  itemBuilder: (context, index) {
                                    final subject = subjects[index];
                                    final subjectColor = _hexToColor(subject.colorCode);

                                    return Card(
                                      color: Colors.white,
                                      elevation: 0,
                                      margin: const EdgeInsets.only(bottom: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AgendaPage(
                                                filterBySubjectName: subject.name,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  // ignore: deprecated_member_use
                                                  color: subjectColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Center(
                                                  child: Icon(Icons.folder_outlined, color: subjectColor),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      subject.name,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Color(0xFF0F172A),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: LinearProgressIndicator(
                                                            value: 0.5,
                                                            backgroundColor: const Color(0xFFE2E8F0),
                                                            valueColor: AlwaysStoppedAnimation<Color>(subjectColor),
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        const Text(
                                                          '50%',
                                                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  }
                  
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onPressed: () {
          showTaskFormBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF1D4ED8),
        unselectedItemColor: const Color(0xFF94A3B8),
        showUnselectedLabels: true,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AgendaPage()));
          } else if (index == 2) { 
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TimerPage()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Agenda'),
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'Estudio'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Ajustes'),
        ],
      ),
    );
  }
}