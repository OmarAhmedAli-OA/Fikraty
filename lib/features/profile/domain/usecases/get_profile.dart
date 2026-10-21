import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  const GetProfileUseCase(this.repository);

  Future<Either<Failure, UserProfile>> call({UserRole? role}) {
    return repository.getProfile(role: role);
  }
}
