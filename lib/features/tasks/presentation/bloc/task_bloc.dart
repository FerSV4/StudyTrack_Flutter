import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studytrack_flutter/features/tasks/domain/usecases/update_task_status_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasksUseCase;
  final UpdateTaskStatusUseCase updateTaskStatusUseCase;

  TaskBloc({
    required this.getTasksUseCase,
    required this.updateTaskStatusUseCase
  }) : super(TaskInitial()) {
    
    on<GetTasksRequested>((event, emit) async {
      emit(TaskLoading());
      try {
        final tasks = await getTasksUseCase();
        emit(TaskLoaded(tasks));
      } catch (e) {
        emit(TaskError(e.toString().replaceAll('Exception: ', '')));
      }
    });
    on<ToggleTaskStatusRequested>((event, emit) async {
      try {
        await updateTaskStatusUseCase(event.taskId, !event.currentStatus);
        add(GetTasksRequested()); 
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });
    on<ClearTasksRequested>((event, emit) {
      emit(TaskInitial()); 
    });
  }
}