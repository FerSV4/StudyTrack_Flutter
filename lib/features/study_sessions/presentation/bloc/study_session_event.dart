import 'package:equatable/equatable.dart';

abstract class StudySessionEvent extends Equatable {
  const StudySessionEvent();

  @override
  List<Object?> get props => [];
}

class StudySessionTaskSelected extends StudySessionEvent {
  final String taskId;

  const StudySessionTaskSelected(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class StudySessionDurationSelected extends StudySessionEvent {
  final int seconds;

  const StudySessionDurationSelected(this.seconds);

  @override
  List<Object?> get props => [seconds];
}

class StudySessionStartRequested extends StudySessionEvent {}

class StudySessionPauseRequested extends StudySessionEvent {}

class StudySessionResumeRequested extends StudySessionEvent {}

class StudySessionFinishRequested extends StudySessionEvent {}

class StudySessionTicked extends StudySessionEvent {
  final int remainingSeconds;

  const StudySessionTicked(this.remainingSeconds);

  @override
  List<Object?> get props => [remainingSeconds];
}
