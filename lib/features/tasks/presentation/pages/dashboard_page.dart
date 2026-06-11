import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../../domain/entities/task_entity.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Disparar de forma mandatoria la carga de tareas al entrar a la pantalla
    context.read<TaskBloc>().add(GetTasksRequested());
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFEF4444); // Rojo
      case 'MEDIUM':
        return const Color(0xFFF59E0B); // Amarillo/Naranja
      case 'LOW':
      default:
        return const Color(0xFF10B981); // Verde
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, Estudiante 👋',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            Text(
              'Panel de control de tus asignaturas',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFE2E8F0),
              child: IconButton(
                icon: const Icon(Icons.person, color: Color(0xFF64748B)),
                onPressed: () {
                  // Al cerrar sesión purgamos el estado del TaskBloc para evitar fugas de información
                  context.read<TaskBloc>().add(ClearTasksRequested());
                  Navigator.pop(context);
                },
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Listado Horizontal de Fechas Estáticas del Diseño
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  bool isToday = index == 2;
                  return Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isToday ? const Color(0xFF1D4ED8) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: isToday ? null : Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lun',
                          style: TextStyle(
                            color: isToday ? Colors.white70 : const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${10 + index}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isToday ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Mis Tareas Pendientes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 16),
            
            // Consumidor del estado de BLoC para inyección de datos reales
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF1D4ED8)));
                  }
                  
                  if (state is TaskError) {
                    return Center(
                      child: Text(
                        'Fallo de sincronización: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (state is TaskLoaded) {
                    if (state.tasks.isEmpty) {
                      return const Center(
                        child: Text('¡Felicidades! No tienes entregas registradas para hoy.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.tasks.length,
                      itemBuilder: (context, index) {
                        final TaskEntity task = state.tasks[index];
                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 4,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _getPriorityColor(task.priority),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            title: Text(
                              task.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            subtitle: Text(
                              'Vence: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                              style: const TextStyle(color: Color(0xFF64748B)),
                            ),
                            trailing: Icon(
                              task.isCompleted 
                                  ? Icons.check_circle_rounded 
                                  : Icons.radio_button_unchecked_rounded,
                              color: task.isCompleted ? const Color(0xFF1D4ED8) : const Color(0xFFCBD5E1),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF1D4ED8),
        unselectedItemColor: const Color(0xFF94A3B8),
        showUnselectedLabels: true,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), label: 'Materias'),
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'Estudio'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Ajustes'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1D4ED8),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}