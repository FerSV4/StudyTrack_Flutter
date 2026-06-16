import '../repositories/academic_repository.dart';
import '../entities/term_entity.dart';

class GetActiveTermUseCase {
  final AcademicRepository repository;

  GetActiveTermUseCase(this.repository);

  Future<TermEntity?> call() async {
    return await repository.getActiveTerm();
  }
}
