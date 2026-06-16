import '../../data/dtos/create_term_dto.dart';
import '../entities/term_entity.dart';
import '../repositories/academic_repository.dart';

class CreateTermUseCase {
  final AcademicRepository repository;

  CreateTermUseCase(this.repository);

  Future<TermEntity> call(CreateTermDto dto) {
    return repository.createTerm(dto);
  }
}
