import 'package:equatable/equatable.dart';

enum StudySessionStatus { initial, running, paused, finished }

class StudySessionState extends Equatable {
  final StudySessionStatus status;
  final String? selectedTaskId;
  final int selectedDurationSeconds;
  final int remainingSeconds;
  final String? sessionId;
  final String? errorMessage;

  const StudySessionState({
    required this.status,
    required this.selectedDurationSeconds,
    required this.remainingSeconds,
    this.selectedTaskId,
    this.sessionId,
    this.errorMessage,
  });

  const StudySessionState.initial()
      : status = StudySessionStatus.initial,
        selectedTaskId = null,
        selectedDurationSeconds = 1500,
        remainingSeconds = 1500,
        sessionId = null,
        errorMessage = null;

  StudySessionState copyWith({
    StudySessionStatus? status,
    String? selectedTaskId,
    int? selectedDurationSeconds,
    int? remainingSeconds,
    String? sessionId,
    String? errorMessage,
  }) {
    return StudySessionState(
      status: status ?? this.status,
      selectedTaskId: selectedTaskId ?? this.selectedTaskId,
      selectedDurationSeconds:
          selectedDurationSeconds ?? this.selectedDurationSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      sessionId: sessionId ?? this.sessionId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedTaskId,
        selectedDurationSeconds,
        remainingSeconds,
        sessionId,
        errorMessage,
      ];
}
