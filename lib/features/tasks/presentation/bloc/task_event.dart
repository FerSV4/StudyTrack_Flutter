import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class GetTasksRequested extends TaskEvent {}

class ClearTasksRequested extends TaskEvent {}