import 'package:equatable/equatable.dart';
import '../../data/dtos/create_subject_dto.dart';
import '../../data/dtos/create_term_dto.dart';

abstract class AcademicEvent extends Equatable {
  const AcademicEvent();
  @override
  List<Object?> get props => [];
}

class GetActiveTermRequested extends AcademicEvent {}

class CreateTermRequested extends AcademicEvent {
  final CreateTermDto dto;

  const CreateTermRequested(this.dto);

  @override
  List<Object?> get props => [dto];
}

class CreateSubjectRequested extends AcademicEvent {
  final String termId;
  final CreateSubjectDto dto;

  const CreateSubjectRequested({
    required this.termId,
    required this.dto,
  });

  @override
  List<Object?> get props => [termId, dto];
}
