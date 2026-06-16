import '../../data/dtos/create_subject_dto.dart';
import '../../data/dtos/create_term_dto.dart';
import '../entities/subject_entity.dart';
import '../entities/term_entity.dart';

abstract class AcademicRepository {
  Future<TermEntity?> getActiveTerm();
  Future<TermEntity> createTerm(CreateTermDto dto);
  Future<SubjectEntity> createSubject(String termId, CreateSubjectDto dto);
}
