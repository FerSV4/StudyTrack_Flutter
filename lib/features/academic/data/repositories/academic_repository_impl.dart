import '../../domain/repositories/academic_repository.dart';
import '../datasources/academic_remote_data_source.dart';
import '../models/term_model.dart';

class AcademicRepositoryImpl implements AcademicRepository {
  final AcademicRemoteDataSource remoteDataSource;

  AcademicRepositoryImpl({required this.remoteDataSource});

  @override
  Future<TermModel> getActiveTerm() async {
    return await remoteDataSource.getActiveTerm();
  }
}