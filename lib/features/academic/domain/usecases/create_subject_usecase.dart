import '../../data/dtos/create_subject_dto.dart';
import '../entities/subject_entity.dart';
import '../repositories/academic_repository.dart';

class CreateSubjectUseCase {
  final AcademicRepository repository;

  CreateSubjectUseCase(this.repository);

  Future<SubjectEntity> call(String termId, CreateSubjectDto dto) {
    return repository.createSubject(termId, dto);
  }
}
