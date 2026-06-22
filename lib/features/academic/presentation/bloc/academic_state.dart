import 'package:equatable/equatable.dart';
import '../../domain/entities/term_entity.dart';

abstract class AcademicState extends Equatable {
  const AcademicState();
  @override
  List<Object?> get props => [];
}

class AcademicInitial extends AcademicState {}
class AcademicLoading extends AcademicState {}
class AcademicEmpty extends AcademicState {}
class AcademicLoaded extends AcademicState {
  final TermEntity term;
  const AcademicLoaded(this.term);
  @override
  List<Object?> get props => [term];
}
class AcademicTermCreated extends AcademicState {
  final TermEntity term;
  const AcademicTermCreated(this.term);
  @override
  List<Object?> get props => [term];
}
class AcademicSubjectCreated extends AcademicState {
  final String termId;
  const AcademicSubjectCreated(this.termId);
  @override
  List<Object?> get props => [termId];
}
class AcademicError extends AcademicState {
  final String message;
  const AcademicError(this.message);
  @override
  List<Object?> get props => [message];
}
