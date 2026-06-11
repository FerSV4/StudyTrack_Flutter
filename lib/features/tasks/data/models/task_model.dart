import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    required super.dueDate,
    required super.priority,
    required super.isCompleted,
    required super.subjectName,
    required super.subjectColor,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final dateString = json['dueDate'] ?? json['due_date']; 
    
    // Extraemos el objeto anidado de la materia, si existe
    final subject = json['subjects'] as Map<String, dynamic>?;

    return TaskModel(
      id: json['id'].toString(),
      title: json['title'] ?? 'Sin título',
      dueDate: dateString != null 
          ? DateTime.parse(dateString) 
          : DateTime.now(),
      priority: json['priority'] ?? 'medium',
      isCompleted: json['status'] == 'completed',
      // Mapeamos los campos anidados con valores por defecto por seguridad
      subjectName: subject?['name'] ?? 'Materia General',
      subjectColor: subject?['color_code'] ?? '#808080', 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'due_date': dueDate.toIso8601String(),
      'priority': priority,
      'status': isCompleted ? 'completed' : 'pending',
    };
  }
}