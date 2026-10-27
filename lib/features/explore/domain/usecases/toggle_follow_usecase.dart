import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/explore_repository.dart';

class ToggleFollowUseCase {
  const ToggleFollowUseCase(this.repository);
  final ExploreRepository repository;

  Future<Either<Failure, bool>> call({
    required String type,
    required int id,
  }) {
    return repository.toggleFollow(type, id);
  }
}
