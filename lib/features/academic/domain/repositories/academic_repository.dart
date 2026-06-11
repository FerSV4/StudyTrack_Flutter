import '../../data/models/term_model.dart';

abstract class AcademicRepository {
  Future<TermModel> getActiveTerm();
}