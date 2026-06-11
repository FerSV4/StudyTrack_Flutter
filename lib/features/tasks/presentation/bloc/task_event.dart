import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class GetTasksRequested extends TaskEvent {}

class ClearTasksRequested extends TaskEvent {}

class ToggleTaskStatusRequested extends TaskEvent {
  final String taskId;
  final bool currentStatus;
  const ToggleTaskStatusRequested(this.taskId, this.currentStatus);
  @override
  List<Object?> get props => [taskId, currentStatus];
}