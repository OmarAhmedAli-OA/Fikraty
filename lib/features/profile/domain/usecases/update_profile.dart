import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  const UpdateProfileUseCase(this.repository);

  Future<Either<Failure, UserProfile>> call(UserProfile profile) {
    if (profile.fullName.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('Full name cannot be empty.')));
    }
    return repository.updateProfile(profile);
  }
}
