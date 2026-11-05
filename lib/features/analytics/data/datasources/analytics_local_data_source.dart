import '../models/analytics_model.dart';

abstract class AnalyticsLocalDataSource {
  Future<FounderAnalyticsModel> getFounderAnalytics(String period);
  Future<StartupAnalyticsModel> getStartupAnalytics(String period);
  Future<InvestorAnalyticsModel> getInvestorAnalytics(String period);
}

class AnalyticsLocalDataSourceImpl implements AnalyticsLocalDataSource {
  @override
  Future<FounderAnalyticsModel> getFounderAnalytics(String period) async {
    final sanitizedPeriod = _normalizePeriod(period);

    final metrics = switch (sanitizedPeriod) {
      '7D' => const [
          AnalyticsMetricModel(
            label: 'Profile Views',
            value: '680',
            change: '+85 this week',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Followers',
            value: '1,080',
            change: '+60 this week',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Investor Matches',
            value: '14',
            change: '+3 this week',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Messages',
            value: '8',
            change: '8 received',
            isPositive: true,
          ),
        ],
      '90D' => const [
          AnalyticsMetricModel(
            label: 'Profile Views',
            value: '8,420',
            change: '+1,120 this quarter',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Followers',
            value: '1,420',
            change: '+420 this quarter',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Investor Matches',
            value: '86',
            change: '+28 this quarter',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Messages',
            value: '112',
            change: '112 received',
            isPositive: true,
          ),
        ],
      _ => const [
          AnalyticsMetricModel(
            label: 'Profile Views',
            value: '2,840',
            change: '+18% this month',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Followers',
            value: '1,240',
            change: '+140 this month',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Investor Matches',
            value: '38',
            change: '+12 this month',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Messages',
            value: '29',
            change: '29 received',
            isPositive: true,
          ),
        ],
    };

    final viewsTrend = switch (sanitizedPeriod) {
      '7D' => const [
          AnalyticsChartPointModel(label: 'Sat', value: 75),
          AnalyticsChartPointModel(label: 'Sun', value: 92),
          AnalyticsChartPointModel(label: 'Mon', value: 110),
          AnalyticsChartPointModel(label: 'Tue', value: 85),
          AnalyticsChartPointModel(label: 'Wed', value: 130),
          AnalyticsChartPointModel(label: 'Thu', value: 95),
          AnalyticsChartPointModel(label: 'Fri', value: 93),
        ],
      '90D' => const [
          AnalyticsChartPointModel(label: 'W1', value: 450),
          AnalyticsChartPointModel(label: 'W3', value: 580),
          AnalyticsChartPointModel(label: 'W6', value: 720),
          AnalyticsChartPointModel(label: 'W9', value: 890),
          AnalyticsChartPointModel(label: 'W12', value: 1040),
        ],
      _ => const [
          AnalyticsChartPointModel(label: 'Day 1', value: 42),
          AnalyticsChartPointModel(label: 'Day 5', value: 65),
          AnalyticsChartPointModel(label: 'Day 10', value: 88),
          AnalyticsChartPointModel(label: 'Day 15', value: 74),
          AnalyticsChartPointModel(label: 'Day 20', value: 115),
          AnalyticsChartPointModel(label: 'Day 25', value: 140),
          AnalyticsChartPointModel(label: 'Day 30', value: 165),
        ],
    };

    return FounderAnalyticsModel(
      period: sanitizedPeriod,
      metrics: metrics,
      reputationScore: 84,
      reputationLevel: 'Rising Founder Tier',
      viewsTrend: viewsTrend,
      topPosts: const [
        {
          'title': 'Announcing our AgriSense Seed Round milestone!',
          'likes': '148',
          'comments': '32',
          'views': '1.8K',
          'time': '3d ago',
        },
        {
          'title': 'Lessons learned building hardware-enabled IoT in Egypt',
          'likes': '96',
          'comments': '18',
          'views': '1.2K',
          'time': '1w ago',
        },
      ],
      recentActivities: const [
        {
          'title': 'Tariq Al-Mansoor followed your profile',
          'time': '15m ago',
          'type': 'follow',
        },
        {
          'title': 'Sarah Jenkins commented on your launch post',
          'time': '2h ago',
          'type': 'comment',
        },
        {
          'title': 'Nour Capital viewed your pitch deck',
          'time': '5h ago',
          'type': 'view',
        },
      ],
    );
  }

  @override
  Future<StartupAnalyticsModel> getStartupAnalytics(String period) async {
    final sanitizedPeriod = _normalizePeriod(period);

    final metrics = switch (sanitizedPeriod) {
      '7D' => const [
          AnalyticsMetricModel(
            label: 'MRR',
            value: '\$41.2K',
            change: '+3.5% this week',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'MoM Growth',
            value: '+14.2%',
            change: '+2.1% vs last wk',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Runway',
            value: '18 Mos',
            change: 'Healthy',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Burn Rate',
            value: '\$8.5K',
            change: '-4% optimized',
            isPositive: true,
          ),
        ],
      '90D' => const [
          AnalyticsMetricModel(
            label: 'MRR',
            value: '\$41.2K',
            change: '+\$14.2K this qtr',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'MoM Growth',
            value: '+16.5%',
            change: 'Consistent',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Runway',
            value: '18 Mos',
            change: 'Post seed',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Burn Rate',
            value: '\$8.5K/mo',
            change: 'Predictable',
            isPositive: true,
          ),
        ],
      _ => const [
          AnalyticsMetricModel(
            label: 'MRR',
            value: '\$41.2K',
            change: '+14% this month',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'MoM Growth',
            value: '+15.8%',
            change: '+3.2% vs target',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Runway',
            value: '18 Mos',
            change: 'Safe horizon',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Burn Rate',
            value: '\$8.5K',
            change: '-\$1.2K vs budget',
            isPositive: true,
          ),
        ],
    };

    final mrrTrend = switch (sanitizedPeriod) {
      '7D' => const [
          AnalyticsChartPointModel(label: 'Day 1', value: 39.5),
          AnalyticsChartPointModel(label: 'Day 3', value: 40.1),
          AnalyticsChartPointModel(label: 'Day 5', value: 40.8),
          AnalyticsChartPointModel(label: 'Day 7', value: 41.2),
        ],
      '90D' => const [
          AnalyticsChartPointModel(label: 'Month 1', value: 27.0),
          AnalyticsChartPointModel(label: 'Month 2', value: 33.5),
          AnalyticsChartPointModel(label: 'Month 3', value: 41.2),
        ],
      _ => const [
          AnalyticsChartPointModel(label: 'Week 1', value: 36.0),
          AnalyticsChartPointModel(label: 'Week 2', value: 37.8),
          AnalyticsChartPointModel(label: 'Week 3', value: 39.4),
          AnalyticsChartPointModel(label: 'Week 4', value: 41.2),
        ],
    };

    return StartupAnalyticsModel(
      period: sanitizedPeriod,
      metrics: metrics,
      mrrTrend: mrrTrend,
      investorActivities: const [
        {
          'investorName': 'Nour Capital',
          'action': 'Downloaded pitch deck',
          'time': '2h ago',
        },
        {
          'investorName': 'Oasis Ventures',
          'action': 'Requested intro to founder',
          'time': '1d ago',
        },
        {
          'investorName': 'Tariq Al-Mansoor',
          'action': 'Added to watchlist',
          'time': '2d ago',
        },
      ],
      trafficSources: const [
        {'source': 'Fikraty Explore', 'percentage': '48%', 'count': '1,240'},
        {'source': 'Direct Links', 'percentage': '26%', 'count': '680'},
        {'source': 'LinkedIn Shares', 'percentage': '18%', 'count': '460'},
        {'source': 'Other Channels', 'percentage': '8%', 'count': '210'},
      ],
    );
  }

  @override
  Future<InvestorAnalyticsModel> getInvestorAnalytics(String period) async {
    final sanitizedPeriod = _normalizePeriod(period);

    final metrics = switch (sanitizedPeriod) {
      '7D' => const [
          AnalyticsMetricModel(
            label: 'Startups Evaluated',
            value: '64',
            change: '+12 this week',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Saved Startups',
            value: '8',
            change: '+2 this week',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Active Pipeline',
            value: '4',
            change: '2 in DD',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Active Deals',
            value: '3',
            change: '2 term sheets',
            isPositive: true,
          ),
        ],
      '90D' => const [
          AnalyticsMetricModel(
            label: 'Startups Evaluated',
            value: '840',
            change: '+190 this quarter',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Saved Startups',
            value: '85',
            change: '+24 this quarter',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Active Pipeline',
            value: '12',
            change: '4 term sheets',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Active Deals',
            value: '18',
            change: '+6 this quarter',
            isPositive: true,
          ),
        ],
      _ => const [
          AnalyticsMetricModel(
            label: 'Startups Evaluated',
            value: '284',
            change: '+42 this month',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Saved Startups',
            value: '31',
            change: '+7 this month',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Active Pipeline',
            value: '6',
            change: '2 term sheets',
            isPositive: true,
          ),
          AnalyticsMetricModel(
            label: 'Active Deals',
            value: '6',
            change: '+2 this month',
            isPositive: true,
          ),
        ],
    };

    final evaluationsTrend = switch (sanitizedPeriod) {
      '7D' => const [
          AnalyticsChartPointModel(label: 'Sat', value: 8),
          AnalyticsChartPointModel(label: 'Sun', value: 12),
          AnalyticsChartPointModel(label: 'Mon', value: 14),
          AnalyticsChartPointModel(label: 'Tue', value: 9),
          AnalyticsChartPointModel(label: 'Wed', value: 11),
          AnalyticsChartPointModel(label: 'Thu', value: 6),
          AnalyticsChartPointModel(label: 'Fri', value: 4),
        ],
      '90D' => const [
          AnalyticsChartPointModel(label: 'Month 1', value: 240),
          AnalyticsChartPointModel(label: 'Month 2', value: 290),
          AnalyticsChartPointModel(label: 'Month 3', value: 310),
        ],
      _ => const [
          AnalyticsChartPointModel(label: 'Week 1', value: 58),
          AnalyticsChartPointModel(label: 'Week 2', value: 74),
          AnalyticsChartPointModel(label: 'Week 3', value: 68),
          AnalyticsChartPointModel(label: 'Week 4', value: 84),
        ],
    };

    return InvestorAnalyticsModel(
      period: sanitizedPeriod,
      metrics: metrics,
      reputationScore: 92,
      reputationLevel: 'Accredited Lead Investor',
      evaluationsTrend: evaluationsTrend,
      sectorDistribution: const [
        {'sector': 'Fintech & Payments', 'share': '38%', 'count': '108'},
        {'sector': 'Agritech & Sustainability', 'share': '28%', 'count': '80'},
        {'sector': 'Healthtech & AI', 'share': '22%', 'count': '62'},
        {'sector': 'Logistics & Supply Chain', 'share': '12%', 'count': '34'},
      ],
      recentActivities: const [
        {
          'title': 'Evaluated AgriSense deck and financials',
          'time': '1h ago',
          'type': 'evaluation',
        },
        {
          'title': 'Initiated due diligence with SolarGrid team',
          'time': '4h ago',
          'type': 'deal',
        },
        {
          'title': 'Saved PayLink to FinTech 2026 pipeline',
          'time': 'Yesterday',
          'type': 'save',
        },
      ],
    );
  }

  String _normalizePeriod(String period) {
    switch (period.toUpperCase().trim()) {
      case '7D':
      case 'WEEK':
        return '7D';
      case '90D':
      case 'QUARTER':
        return '90D';
      default:
        return '30D';
    }
  }
}
