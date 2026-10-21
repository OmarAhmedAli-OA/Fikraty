import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/interest_item.dart';
import '../repositories/profile_repository.dart';

class UpdateInterestStatusUseCase {
  final ProfileRepository repository;

  const UpdateInterestStatusUseCase(this.repository);

  Future<Either<Failure, InterestItem>> call({
    required int interestId,
    required InterestStatus newStatus,
  }) {
    return repository.updateInterestStatus(
      interestId: interestId,
      newStatus: newStatus,
    );
  }
}
