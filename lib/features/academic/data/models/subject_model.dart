import '../../domain/entities/subject_entity.dart';

class SubjectModel extends SubjectEntity {
  const SubjectModel({
    required super.id,
    required super.name,
    required super.colorCode,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'].toString(),
      name: json['name'] ?? 'Sin nombre',
      colorCode: json['color_code'] ?? json['colorCode'] ?? '#808080',
    );
  }
}
