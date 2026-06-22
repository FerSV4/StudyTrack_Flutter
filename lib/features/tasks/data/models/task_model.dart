import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.subjectId,
    required super.title,
    super.description,
    required super.dueDate,
    super.estimatedHours,
    required super.priority,
    required super.isCompleted,
    required super.subjectName,
    required super.subjectColor,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final dateString = json['dueDate'] ?? json['due_date'];
    final subject = json['subjects'] as Map<String, dynamic>?;
    final estimatedHoursValue = json['estimatedHours'] ?? json['estimated_hours'];

    return TaskModel(
      id: json['id'].toString(),
      subjectId: json['subjectId']?.toString() ??
          json['subject_id']?.toString() ??
          subject?['id']?.toString() ??
          '',
      title: json['title'] ?? 'Sin titulo',
      description: json['description'],
      dueDate: dateString != null ? DateTime.parse(dateString) : DateTime.now(),
      estimatedHours: estimatedHoursValue != null
          ? double.tryParse(estimatedHoursValue.toString())
          : null,
      priority: json['priority'] ?? 'medium',
      isCompleted: json['status'] == 'completed',
      subjectName: subject?['name'] ?? 'Materia General',
      subjectColor: subject?['color_code'] ?? '#808080',
    );
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      subjectId: entity.subjectId,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      estimatedHours: entity.estimatedHours,
      priority: entity.priority,
      isCompleted: entity.isCompleted,
      subjectName: entity.subjectName,
      subjectColor: entity.subjectColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'estimatedHours': estimatedHours,
      'priority': priority,
      'status': isCompleted ? 'completed' : 'pending', 

      'subjects': {
        'id': subjectId,
        'name': subjectName,
        'color_code': subjectColor,
      }
    };
  }

  Map<String, dynamic> toCreateOrUpdateJson() {
    final Map<String, dynamic> data = {
      'subjectId': int.parse(subjectId),
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
    };

    if (description != null && description!.trim().isNotEmpty) {
      data['description'] = description!.trim();
    }

    if (estimatedHours != null) {
      final value = estimatedHours!;
      data['estimatedHours'] = value % 1 == 0 ? value.toInt() : value;
    }

    return data;
  }
}