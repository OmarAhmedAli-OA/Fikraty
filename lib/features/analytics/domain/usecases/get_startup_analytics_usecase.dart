import '../entities/startup_analytics.dart';
import '../repositories/analytics_repository.dart';

class GetStartupAnalyticsUseCase {
  final AnalyticsRepository repository;

  GetStartupAnalyticsUseCase(this.repository);

  Future<StartupAnalytics> call(String period) {
    return repository.getStartupAnalytics(period);
  }
}
