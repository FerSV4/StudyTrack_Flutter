class CreateSubjectDto {
  final String termId;
  final String name;
  final String colorCode;

  const CreateSubjectDto({
    required this.termId,
    required this.name,
    required this.colorCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'termId': termId,
      'name': name,
      'colorCode': colorCode,
    };
  }
}
