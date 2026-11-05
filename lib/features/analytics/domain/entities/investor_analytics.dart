import 'analytics_common.dart';

class InvestorAnalytics {
  final String period;
  final List<AnalyticsMetric> metrics;
  final int reputationScore;
  final String reputationLevel;
  final List<AnalyticsChartPoint> evaluationsTrend;
  final List<Map<String, dynamic>> sectorDistribution;
  final List<Map<String, dynamic>> recentActivities;

  const InvestorAnalytics({
    required this.period,
    required this.metrics,
    required this.reputationScore,
    required this.reputationLevel,
    required this.evaluationsTrend,
    required this.sectorDistribution,
    required this.recentActivities,
  });
}
