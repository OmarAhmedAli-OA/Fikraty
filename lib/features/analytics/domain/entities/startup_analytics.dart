import 'analytics_common.dart';

class StartupAnalytics {
  final String period;
  final List<AnalyticsMetric> metrics;
  final List<AnalyticsChartPoint> mrrTrend;
  final List<Map<String, dynamic>> investorActivities;
  final List<Map<String, dynamic>> trafficSources;

  const StartupAnalytics({
    required this.period,
    required this.metrics,
    required this.mrrTrend,
    required this.investorActivities,
    required this.trafficSources,
  });
}
