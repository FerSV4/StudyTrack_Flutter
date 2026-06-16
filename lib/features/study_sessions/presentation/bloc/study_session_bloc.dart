import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/finish_session_usecase.dart';
import '../../domain/usecases/start_session_usecase.dart';
import 'study_session_event.dart';
import 'study_session_state.dart';

class StudySessionBloc extends Bloc<StudySessionEvent, StudySessionState> {
  final StartSessionUseCase startSessionUseCase;
  final FinishSessionUseCase finishSessionUseCase;
  Timer? timer;

  StudySessionBloc({
    required this.startSessionUseCase,
    required this.finishSessionUseCase,
  }) : super(const StudySessionState.initial()) {
    on<StudySessionTaskSelected>((event, emit) {
      emit(state.copyWith(selectedTaskId: event.taskId, errorMessage: null));
    });

    on<StudySessionDurationSelected>((event, emit) {
      if (state.status == StudySessionStatus.running) return;
      emit(
        state.copyWith(
          selectedDurationSeconds: event.seconds,
          remainingSeconds: event.seconds,
          errorMessage: null,
        ),
      );
    });

    on<StudySessionStartRequested>((event, emit) async {
      if (state.selectedTaskId == null || state.selectedTaskId!.isEmpty) {
        emit(state.copyWith(errorMessage: 'Selecciona una tarea antes de iniciar.'));
        return;
      }
      try {
        final session = await startSessionUseCase(state.selectedTaskId!);
        emit(
          state.copyWith(
            status: StudySessionStatus.running,
            sessionId: session.id,
            remainingSeconds: state.selectedDurationSeconds,
            errorMessage: null,
          ),
        );
        _startTimer();
      } catch (e) {
        emit(state.copyWith(errorMessage: e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<StudySessionPauseRequested>((event, emit) {
      if (state.status != StudySessionStatus.running) return;
      timer?.cancel();
      emit(state.copyWith(status: StudySessionStatus.paused));
    });

    on<StudySessionResumeRequested>((event, emit) {
      if (state.status != StudySessionStatus.paused) return;
      emit(state.copyWith(status: StudySessionStatus.running));
      _startTimer();
    });

    on<StudySessionFinishRequested>((event, emit) async {
      timer?.cancel();
      final sessionId = state.sessionId;
      if (sessionId != null && sessionId.isNotEmpty) {
        try {
          await finishSessionUseCase(sessionId);
        } catch (e) {
          emit(state.copyWith(errorMessage: e.toString().replaceAll('Exception: ', '')));
          return;
        }
      }
      emit(
        state.copyWith(
          status: StudySessionStatus.finished,
          remainingSeconds: 0,
          errorMessage: null,
        ),
      );
    });

    on<StudySessionTicked>((event, emit) {
      final remaining = event.remainingSeconds;
      if (remaining <= 0) {
        timer?.cancel();
        add(StudySessionFinishRequested());
        return;
      }
      emit(state.copyWith(remainingSeconds: remaining));
    });
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(StudySessionTicked(state.remainingSeconds - 1));
    });
  }

  @override
  Future<void> close() {
    timer?.cancel();
    return super.close();
  }
}
