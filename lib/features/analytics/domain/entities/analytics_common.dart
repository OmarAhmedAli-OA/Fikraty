class AnalyticsMetric {
  final String label;
  final String value;
  final String change;
  final bool isPositive;

  const AnalyticsMetric({
    required this.label,
    required this.value,
    required this.change,
    this.isPositive = true,
  });
}

class AnalyticsChartPoint {
  final String label;
  final double value;

  const AnalyticsChartPoint({
    required this.label,
    required this.value,
  });
}
