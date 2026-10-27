import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/explore_repository.dart';

class ToggleEventRegistrationUseCase {
  const ToggleEventRegistrationUseCase(this._repository);

  final ExploreRepository _repository;

  Future<Either<Failure, bool>> call(int eventId) {
    return _repository.toggleEventRegistration(eventId);
  }
}
