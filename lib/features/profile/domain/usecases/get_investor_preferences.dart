import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/investor_preferences.dart';
import '../repositories/profile_repository.dart';

class GetInvestorPreferencesUseCase {
  final ProfileRepository repository;

  const GetInvestorPreferencesUseCase(this.repository);

  Future<Either<Failure, InvestorPreferences>> call() {
    return repository.getInvestorPreferences();
  }
}
