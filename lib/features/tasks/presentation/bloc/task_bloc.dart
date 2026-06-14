import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studytrack_flutter/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:studytrack_flutter/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:studytrack_flutter/features/tasks/domain/usecases/update_task_status_usecase.dart';
import 'package:studytrack_flutter/features/tasks/domain/usecases/update_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasksUseCase;
  final UpdateTaskStatusUseCase updateTaskStatusUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;

  TaskBloc({
    required this.getTasksUseCase,
    required this.updateTaskStatusUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
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
        emit(TaskError(e.toString().replaceAll('Exception: ', '')));
      }
    });
    on<CreateTaskRequested>((event, emit) async {
      try {
        await createTaskUseCase(event.task);
        add(GetTasksRequested());
      } catch (e) {
        emit(TaskError(e.toString().replaceAll('Exception: ', '')));
      }
    });
    on<UpdateTaskDetailsRequested>((event, emit) async {
      try {
        await updateTaskUseCase(event.taskId, event.task);
        add(GetTasksRequested());
      } catch (e) {
        emit(TaskError(e.toString().replaceAll('Exception: ', '')));
      }
    });
    on<DeleteTaskRequested>((event, emit) async {
      try {
        await deleteTaskUseCase(event.taskId);
        add(GetTasksRequested());
      } catch (e) {
        emit(TaskError(e.toString().replaceAll('Exception: ', '')));
      }
    });
    on<ClearTasksRequested>((event, emit) {
      emit(TaskInitial());
    });
  }
}
