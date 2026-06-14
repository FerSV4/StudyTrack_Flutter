import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final String id;
  final String subjectId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final double? estimatedHours;
  final String priority;
  final bool isCompleted;
  final String subjectName;
  final String subjectColor;

  const TaskEntity({
    required this.id,
    required this.subjectId,
    required this.title,
    this.description,
    required this.dueDate,
    this.estimatedHours,
    required this.priority,
    required this.isCompleted,
    required this.subjectName,
    required this.subjectColor,
  });

  @override
  List<Object?> get props => [
        id,
        subjectId,
        title,
        description,
        dueDate,
        estimatedHours,
        priority,
        isCompleted,
        subjectName,
        subjectColor,
      ];
}
