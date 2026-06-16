import '../../domain/entities/term_entity.dart';
import 'subject_model.dart';

class TermModel extends TermEntity {
  const TermModel({
    required super.id,
    required super.name,
    required super.subjects,
  });

  factory TermModel.fromJson(Map<String, dynamic> json) {
    final list = json['subjects'] as List? ?? [];
    final subjectsList =
        list.map((i) => SubjectModel.fromJson(i as Map<String, dynamic>)).toList();

    return TermModel(
      id: json['id'].toString(),
      name: json['name'] ?? 'Semestre Actual',
      subjects: subjectsList,
    );
  }
}
