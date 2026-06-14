import 'package:equatable/equatable.dart';

import '../../domain/entities/task_entity.dart';

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

class CreateTaskRequested extends TaskEvent {
  final TaskEntity task;

  const CreateTaskRequested(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTaskDetailsRequested extends TaskEvent {
  final String taskId;
  final TaskEntity task;

  const UpdateTaskDetailsRequested(this.taskId, this.task);

  @override
  List<Object?> get props => [taskId, task];
}

class DeleteTaskRequested extends TaskEvent {
  final String taskId;

  const DeleteTaskRequested(this.taskId);

  @override
  List<Object?> get props => [taskId];
}
