import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/user_profile.dart';
import '../entities/interest_item.dart';
import '../repositories/profile_repository.dart';

class GetInterestsUseCase {
  final ProfileRepository repository;

  const GetInterestsUseCase(this.repository);

  Future<Either<Failure, List<InterestItem>>> call({
    required UserRole role,
    required InterestDirection direction,
  }) {
    return repository.getInterests(role: role, direction: direction);
  }
}
