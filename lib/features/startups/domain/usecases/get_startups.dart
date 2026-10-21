import '../entities/startups.dart';
import '../repositories/startups_repository.dart';

class GetMyStartupUseCase {
  const GetMyStartupUseCase(this._repository);

  final StartupsRepository _repository;

  Future<StartupEntity?> call() {
    return _repository.getMyStartup();
  }
}
