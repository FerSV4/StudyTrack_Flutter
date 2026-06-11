import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    required super.dueDate,
    required super.priority,
    required super.isCompleted,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final dateString = json['dueDate'] ?? json['due_date']; 
    
    return TaskModel(
      id: json['id'].toString(),
      title: json['title'] ?? 'Sin título',
      dueDate: dateString != null 
          ? DateTime.parse(dateString) 
          : DateTime.now(),
      priority: json['priority'] ?? 'LOW',
      isCompleted: json['isCompleted'] ?? json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }
}