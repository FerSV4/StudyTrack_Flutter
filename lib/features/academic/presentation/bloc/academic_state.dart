import 'package:equatable/equatable.dart';
import '../../data/models/term_model.dart';

abstract class AcademicState extends Equatable {
  const AcademicState();
  @override
  List<Object?> get props => [];
}

class AcademicInitial extends AcademicState {}
class AcademicLoading extends AcademicState {}
class AcademicLoaded extends AcademicState {
  final TermModel term;
  const AcademicLoaded(this.term);
  @override
  List<Object?> get props => [term];
}
class AcademicError extends AcademicState {
  final String message;
  const AcademicError(this.message);
  @override
  List<Object?> get props => [message];
}