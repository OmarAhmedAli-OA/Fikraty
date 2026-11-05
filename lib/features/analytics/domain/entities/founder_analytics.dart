import 'analytics_common.dart';

class FounderAnalytics {
  final String period;
  final List<AnalyticsMetric> metrics;
  final int reputationScore;
  final String reputationLevel;
  final List<AnalyticsChartPoint> viewsTrend;
  final List<Map<String, dynamic>> topPosts;
  final List<Map<String, dynamic>> recentActivities;

  const FounderAnalytics({
    required this.period,
    required this.metrics,
    required this.reputationScore,
    required this.reputationLevel,
    required this.viewsTrend,
    required this.topPosts,
    required this.recentActivities,
  });
}
