import 'package:equatable/equatable.dart';

import 'subject_entity.dart';

class TermEntity extends Equatable {
  final String id;
  final String name;
  final List<SubjectEntity> subjects;

  const TermEntity({
    required this.id,
    required this.name,
    required this.subjects,
  });

  @override
  List<Object?> get props => [id, name, subjects];
}
