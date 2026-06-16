import '../../data/dtos/create_subject_dto.dart';
import '../../data/dtos/create_term_dto.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/entities/term_entity.dart';
import '../../domain/repositories/academic_repository.dart';
import '../datasources/academic_remote_data_source.dart';

class AcademicRepositoryImpl implements AcademicRepository {
  final AcademicRemoteDataSource remoteDataSource;

  AcademicRepositoryImpl({required this.remoteDataSource});

  @override
  Future<TermEntity?> getActiveTerm() async {
    return await remoteDataSource.getActiveTerm();
  }

  @override
  Future<TermEntity> createTerm(CreateTermDto dto) async {
    return await remoteDataSource.createTerm(dto);
  }

  @override
  Future<SubjectEntity> createSubject(String termId, CreateSubjectDto dto) async {
    return await remoteDataSource.createSubject(termId, dto);
  }
}
