import '../entities/startups.dart';
import '../repositories/startups_repository.dart';

class SaveStartupUseCase {
  const SaveStartupUseCase(this._repository);

  final StartupsRepository _repository;

  Future<StartupEntity> call(StartupEntity startup) {
    if (startup.name.trim().isEmpty) {
      throw ArgumentError('Startup name is required.');
    }
    if (startup.tagline.trim().isEmpty) {
      throw ArgumentError('Startup tagline is required.');
    }
    return _repository.saveStartup(startup);
  }
}
