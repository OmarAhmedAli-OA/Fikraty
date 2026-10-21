import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/investor_preferences.dart';
import '../repositories/profile_repository.dart';

class UpdateInvestorPreferencesUseCase {
  final ProfileRepository repository;

  const UpdateInvestorPreferencesUseCase(this.repository);

  Future<Either<Failure, InvestorPreferences>> call(
      InvestorPreferences preferences) {
    if (preferences.sectors.isEmpty) {
      return Future.value(
          const Left(ValidationFailure('Please select at least one sector.')));
    }
    return repository.updateInvestorPreferences(preferences);
  }
}
