import 'package:equatable/equatable.dart';

class SubjectModel extends Equatable {
  final String id;
  final String name;
  final String colorCode;

  const SubjectModel({required this.id, required this.name, required this.colorCode});

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'].toString(),
      name: json['name'] ?? 'Sin nombre',
      colorCode: json['color_code'] ?? '#808080',
    );
  }

  @override
  List<Object?> get props => [id, name, colorCode];
}

class TermModel extends Equatable {
  final String id;
  final String name;
  final List<SubjectModel> subjects;

  const TermModel({required this.id, required this.name, required this.subjects});

  factory TermModel.fromJson(Map<String, dynamic> json) {
    var list = json['subjects'] as List? ?? [];
    List<SubjectModel> subjectsList = list.map((i) => SubjectModel.fromJson(i)).toList();

    return TermModel(
      id: json['id'].toString(),
      name: json['name'] ?? 'Semestre Actual',
      subjects: subjectsList,
    );
  }

  @override
  List<Object?> get props => [id, name, subjects];
}