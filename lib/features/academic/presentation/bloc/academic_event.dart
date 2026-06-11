import 'package:equatable/equatable.dart';

abstract class AcademicEvent extends Equatable {
  const AcademicEvent();
  @override
  List<Object?> get props => [];
}

class GetActiveTermRequested extends AcademicEvent {}