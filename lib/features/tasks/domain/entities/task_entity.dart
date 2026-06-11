import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final DateTime dueDate;
  final String priority;
  final bool isCompleted;
  final String subjectName;
  final String subjectColor;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
    required this.subjectName,
    required this.subjectColor,
  });

  @override
  List<Object?> get props => [id, title, dueDate, priority, isCompleted, subjectName, subjectColor];
}