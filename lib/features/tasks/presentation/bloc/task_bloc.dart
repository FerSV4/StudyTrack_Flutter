import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasksUseCase;

  TaskBloc({required this.getTasksUseCase}) : super(TaskInitial()) {
    
    on<GetTasksRequested>((event, emit) async {
      emit(TaskLoading());
      try {
        final tasks = await getTasksUseCase();
        emit(TaskLoaded(tasks));
      } catch (e) {
        emit(TaskError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<ClearTasksRequested>((event, emit) {
      emit(TaskInitial()); 
    });
  }
}