import '../entities/investor_analytics.dart';
import '../repositories/analytics_repository.dart';

class GetInvestorAnalyticsUseCase {
  final AnalyticsRepository repository;

  GetInvestorAnalyticsUseCase(this.repository);

  Future<InvestorAnalytics> call(String period) {
    return repository.getInvestorAnalytics(period);
  }
}
