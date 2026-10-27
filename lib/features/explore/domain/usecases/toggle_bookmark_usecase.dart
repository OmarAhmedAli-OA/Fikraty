import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/explore_repository.dart';

class ToggleBookmarkUseCase {
  const ToggleBookmarkUseCase(this._repository);

  final ExploreRepository _repository;

  Future<Either<Failure, bool>> call({
    required String type,
    required int id,
  }) {
    return _repository.toggleBookmark(type, id);
  }
}
