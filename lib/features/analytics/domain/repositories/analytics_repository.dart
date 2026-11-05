import '../entities/founder_analytics.dart';
import '../entities/investor_analytics.dart';
import '../entities/startup_analytics.dart';

abstract class AnalyticsRepository {
  Future<FounderAnalytics> getFounderAnalytics(String period);
  Future<StartupAnalytics> getStartupAnalytics(String period);
  Future<InvestorAnalytics> getInvestorAnalytics(String period);
}
