import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class SwitchRoleUseCase {
  final ProfileRepository repository;

  const SwitchRoleUseCase(this.repository);

  Future<Either<Failure, UserProfile>> call(UserRole newRole) {
    return repository.switchRole(newRole);
  }
}
