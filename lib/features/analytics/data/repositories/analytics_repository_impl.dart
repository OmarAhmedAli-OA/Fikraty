import '../../domain/entities/founder_analytics.dart';
import '../../domain/entities/investor_analytics.dart';
import '../../domain/entities/startup_analytics.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_local_data_source.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsLocalDataSource localDataSource;

  AnalyticsRepositoryImpl(this.localDataSource);

  @override
  Future<FounderAnalytics> getFounderAnalytics(String period) {
    return localDataSource.getFounderAnalytics(period);
  }

  @override
  Future<StartupAnalytics> getStartupAnalytics(String period) {
    return localDataSource.getStartupAnalytics(period);
  }

  @override
  Future<InvestorAnalytics> getInvestorAnalytics(String period) {
    return localDataSource.getInvestorAnalytics(period);
  }
}
