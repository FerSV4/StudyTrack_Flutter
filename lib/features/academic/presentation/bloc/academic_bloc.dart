import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_active_term_usecase.dart';
import 'academic_event.dart';
import 'academic_state.dart';

class AcademicBloc extends Bloc<AcademicEvent, AcademicState> {
  final GetActiveTermUseCase getActiveTermUseCase;

  AcademicBloc({required this.getActiveTermUseCase}) : super(AcademicInitial()) {
    on<GetActiveTermRequested>((event, emit) async {
      emit(AcademicLoading());
      try {
        final term = await getActiveTermUseCase();
        emit(AcademicLoaded(term));
      } catch (e) {
        emit(AcademicError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}