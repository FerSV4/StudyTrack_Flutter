import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../../domain/entities/task_entity.dart';

class AgendaPage extends StatefulWidget {
  final String? filterBySubjectName; // Opcional: para filtrar si tocamos una materia específica

  const AgendaPage({super.key, this.filterBySubjectName});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  @override
  void initState() {
    super.initState();
    // Pedimos las tareas a NestJS al abrir la agenda
    context.read<TaskBloc>().add(GetTasksRequested());
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
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Text(
          widget.filterBySubjectName != null 
              ? 'Tareas: ${widget.filterBySubjectName}' 
              : 'Mi Agenda Completa',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading || state is TaskInitial) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF1D4ED8)));
            }
            
            if (state is TaskError) {
              return Center(
                child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
              );
            }

            if (state is TaskLoaded) {
              // Si venimos del Dashboard tocando una materia, filtramos localmente
              List<TaskEntity> displayTasks = state.tasks;
              if (widget.filterBySubjectName != null) {
                displayTasks = displayTasks.where((t) => t.subjectName == widget.filterBySubjectName).toList();
              }

              if (displayTasks.isEmpty) {
                return const Center(
                  child: Text('¡Todo al día! No tienes entregas pendientes aquí.', style: TextStyle(color: Color(0xFF64748B))),
                );
              }

              return ListView.builder(
                itemCount: displayTasks.length,
                itemBuilder: (context, index) {
                  final TaskEntity task = displayTasks[index];
                  
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
                          color: _hexToColor(task.subjectColor),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: task.isCompleted ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            task.subjectName,
                            style: TextStyle(color: _hexToColor(task.subjectColor), fontWeight: FontWeight.w500, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Vence: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          task.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          color: task.isCompleted ? const Color(0xFF1D4ED8) : const Color(0xFFCBD5E1),
                        ),
                        onPressed: () {
                          // ¡Disparamos el evento de actualización que ya habiamos programado!
                          context.read<TaskBloc>().add(
                            ToggleTaskStatusRequested(task.id, task.isCompleted),
                          );
                        },
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
    );
  }
}