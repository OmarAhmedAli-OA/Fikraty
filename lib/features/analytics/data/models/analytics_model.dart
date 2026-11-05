import '../../domain/entities/analytics_common.dart';
import '../../domain/entities/founder_analytics.dart';
import '../../domain/entities/investor_analytics.dart';
import '../../domain/entities/startup_analytics.dart';

class AnalyticsMetricModel extends AnalyticsMetric {
  const AnalyticsMetricModel({
    required super.label,
    required super.value,
    required super.change,
    super.isPositive = true,
  });

  factory AnalyticsMetricModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsMetricModel(
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
      change: json['change'] as String? ?? '',
      isPositive: json['isPositive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'change': change,
      'isPositive': isPositive,
    };
  }
}

class AnalyticsChartPointModel extends AnalyticsChartPoint {
  const AnalyticsChartPointModel({
    required super.label,
    required super.value,
  });

  factory AnalyticsChartPointModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsChartPointModel(
      label: json['label'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
    };
  }
}

class FounderAnalyticsModel extends FounderAnalytics {
  const FounderAnalyticsModel({
    required super.period,
    required super.metrics,
    required super.reputationScore,
    required super.reputationLevel,
    required super.viewsTrend,
    required super.topPosts,
    required super.recentActivities,
  });

  factory FounderAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return FounderAnalyticsModel(
      period: json['period'] as String? ?? '30D',
      metrics: (json['metrics'] as List<dynamic>?)
              ?.map((e) =>
                  AnalyticsMetricModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reputationScore: (json['reputationScore'] as num?)?.toInt() ?? 0,
      reputationLevel: json['reputationLevel'] as String? ?? 'Rising Founder',
      viewsTrend: (json['viewsTrend'] as List<dynamic>?)
              ?.map((e) =>
                  AnalyticsChartPointModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      topPosts: (json['topPosts'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [],
      recentActivities: (json['recentActivities'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'metrics': metrics
          .map((m) => (m is AnalyticsMetricModel)
              ? m.toJson()
              : {
                  'label': m.label,
                  'value': m.value,
                  'change': m.change,
                  'isPositive': m.isPositive
                })
          .toList(),
      'reputationScore': reputationScore,
      'reputationLevel': reputationLevel,
      'viewsTrend': viewsTrend
          .map((p) => (p is AnalyticsChartPointModel)
              ? p.toJson()
              : {'label': p.label, 'value': p.value})
          .toList(),
      'topPosts': topPosts,
      'recentActivities': recentActivities,
    };
  }
}

class StartupAnalyticsModel extends StartupAnalytics {
  const StartupAnalyticsModel({
    required super.period,
    required super.metrics,
    required super.mrrTrend,
    required super.investorActivities,
    required super.trafficSources,
  });

  factory StartupAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return StartupAnalyticsModel(
      period: json['period'] as String? ?? '30D',
      metrics: (json['metrics'] as List<dynamic>?)
              ?.map((e) =>
                  AnalyticsMetricModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      mrrTrend: (json['mrrTrend'] as List<dynamic>?)
              ?.map((e) =>
                  AnalyticsChartPointModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      investorActivities: (json['investorActivities'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [],
      trafficSources: (json['trafficSources'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'metrics': metrics
          .map((m) => (m is AnalyticsMetricModel)
              ? m.toJson()
              : {
                  'label': m.label,
                  'value': m.value,
                  'change': m.change,
                  'isPositive': m.isPositive
                })
          .toList(),
      'mrrTrend': mrrTrend
          .map((p) => (p is AnalyticsChartPointModel)
              ? p.toJson()
              : {'label': p.label, 'value': p.value})
          .toList(),
      'investorActivities': investorActivities,
      'trafficSources': trafficSources,
    };
  }
}

class InvestorAnalyticsModel extends InvestorAnalytics {
  const InvestorAnalyticsModel({
    required super.period,
    required super.metrics,
    required super.reputationScore,
    required super.reputationLevel,
    required super.evaluationsTrend,
    required super.sectorDistribution,
    required super.recentActivities,
  });

  factory InvestorAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return InvestorAnalyticsModel(
      period: json['period'] as String? ?? '30D',
      metrics: (json['metrics'] as List<dynamic>?)
              ?.map((e) =>
                  AnalyticsMetricModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reputationScore: (json['reputationScore'] as num?)?.toInt() ?? 0,
      reputationLevel: json['reputationLevel'] as String? ?? 'Verified Investor',
      evaluationsTrend: (json['evaluationsTrend'] as List<dynamic>?)
              ?.map((e) =>
                  AnalyticsChartPointModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      sectorDistribution: (json['sectorDistribution'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [],
      recentActivities: (json['recentActivities'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'metrics': metrics
          .map((m) => (m is AnalyticsMetricModel)
              ? m.toJson()
              : {
                  'label': m.label,
                  'value': m.value,
                  'change': m.change,
                  'isPositive': m.isPositive
                })
          .toList(),
      'reputationScore': reputationScore,
      'reputationLevel': reputationLevel,
      'evaluationsTrend': evaluationsTrend
          .map((p) => (p is AnalyticsChartPointModel)
              ? p.toJson()
              : {'label': p.label, 'value': p.value})
          .toList(),
      'sectorDistribution': sectorDistribution,
      'recentActivities': recentActivities,
    };
  }
}
