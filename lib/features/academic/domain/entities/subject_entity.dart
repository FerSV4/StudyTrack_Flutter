import 'package:equatable/equatable.dart';

class SubjectEntity extends Equatable {
  final String id;
  final String name;
  final String colorCode;

  const SubjectEntity({
    required this.id,
    required this.name,
    required this.colorCode,
  });

  @override
  List<Object?> get props => [id, name, colorCode];
}
