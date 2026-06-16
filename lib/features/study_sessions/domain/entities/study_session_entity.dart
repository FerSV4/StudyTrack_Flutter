import 'package:equatable/equatable.dart';

class StudySessionEntity extends Equatable {
  final String id;
  final String taskId;
  final DateTime startedAt;
  final DateTime? finishedAt;

  const StudySessionEntity({
    required this.id,
    required this.taskId,
    required this.startedAt,
    this.finishedAt,
  });

  @override
  List<Object?> get props => [id, taskId, startedAt, finishedAt];
}
