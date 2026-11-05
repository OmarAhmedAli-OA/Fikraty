import '../models/analytics_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<FounderAnalyticsModel> fetchFounderAnalytics(String period);
  Future<StartupAnalyticsModel> fetchStartupAnalytics(String period);
  Future<InvestorAnalyticsModel> fetchInvestorAnalytics(String period);
}
