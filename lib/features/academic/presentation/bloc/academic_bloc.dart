import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_subject_usecase.dart';
import '../../domain/usecases/create_term_usecase.dart';
import '../../domain/usecases/get_active_term_usecase.dart';
import 'academic_event.dart';
import 'academic_state.dart';

class AcademicBloc extends Bloc<AcademicEvent, AcademicState> {
  final GetActiveTermUseCase getActiveTermUseCase;
  final CreateTermUseCase createTermUseCase;
  final CreateSubjectUseCase createSubjectUseCase;

  AcademicBloc({
    required this.getActiveTermUseCase,
    required this.createTermUseCase,
    required this.createSubjectUseCase,
  }) : super(AcademicInitial()) {
    on<GetActiveTermRequested>((event, emit) async {
      emit(AcademicLoading());
      try {
        final term = await getActiveTermUseCase();
        if (term == null) {
          emit(AcademicEmpty());
        } else {
          emit(AcademicLoaded(term));
        }
      } catch (e) {
        emit(AcademicError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<CreateTermRequested>((event, emit) async {
      emit(AcademicLoading());
      try {
        final term = await createTermUseCase(event.dto);
        emit(AcademicTermCreated(term));
      } catch (e) {
        emit(AcademicError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<CreateSubjectRequested>((event, emit) async {
      emit(AcademicLoading());
      try {
        await createSubjectUseCase(event.termId, event.dto);
        emit(AcademicSubjectCreated(event.termId));
      } catch (e) {
        emit(AcademicError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
