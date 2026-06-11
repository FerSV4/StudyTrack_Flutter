import '../repositories/academic_repository.dart';
import '../../data/models/term_model.dart';

class GetActiveTermUseCase {
  final AcademicRepository repository;

  GetActiveTermUseCase(this.repository);

  Future<TermModel> call() async {
    return await repository.getActiveTerm();
  }
}