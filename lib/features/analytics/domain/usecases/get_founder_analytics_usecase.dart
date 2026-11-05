import '../entities/founder_analytics.dart';
import '../repositories/analytics_repository.dart';

class GetFounderAnalyticsUseCase {
  final AnalyticsRepository repository;

  GetFounderAnalyticsUseCase(this.repository);

  Future<FounderAnalytics> call(String period) {
    return repository.getFounderAnalytics(period);
  }
}
