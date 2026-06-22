class CreateTermDto {
  final String name;
  final DateTime startDate;
  final DateTime endDate;

  const CreateTermDto({
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}
