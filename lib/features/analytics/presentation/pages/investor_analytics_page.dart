import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';
import '../widgets/analytics_card.dart';
import '../widgets/analytics_item.dart';
import '../widgets/analytics_period_selector.dart';

class InvestorAnalyticsPage extends StatefulWidget {
  const InvestorAnalyticsPage({super.key});

  @override
  State<InvestorAnalyticsPage> createState() => _InvestorAnalyticsPageState();
}

class _InvestorAnalyticsPageState extends State<InvestorAnalyticsPage> {
  String _selectedPeriod = '30D';

  @override
  void initState() {
    super.initState();
    context
        .read<AnalyticsBloc>()
        .add(LoadInvestorAnalyticsEvent(period: _selectedPeriod));
  }

  void _onPeriodChanged(String period) {
    setState(() => _selectedPeriod = period);
    context
        .read<AnalyticsBloc>()
        .add(LoadInvestorAnalyticsEvent(period: period));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softLavenderBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Investor Analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Dealflow, evaluations & portfolio activity',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: AnalyticsPeriodSelectorWidget(
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: _onPeriodChanged,
            ),
          ),
        ],
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPurple),
            );
          }

          if (state is AnalyticsError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          if (state is InvestorAnalyticsLoaded) {
            final data = state.data;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 4 Top Metrics Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.metrics.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.5,
                    ),
                    itemBuilder: (context, index) {
                      final icons = [
                        Icons.search_rounded,
                        Icons.bookmark_outline_rounded,
                        Icons.trending_up_rounded,
                        Icons.calendar_today_outlined,
                      ];
                      return AnalyticsMetricItemWidget(
                        metric: data.metrics[index],
                        icon: icons[index % icons.length],
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // Investor Reputation Score
                  AnalyticsCardWidget(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Investor Activity & Trust Score',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            data.reputationLevel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.emeraldText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Text(
                              '${data.reputationScore}',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: AppColors.secondaryDark,
                                letterSpacing: -1,
                              ),
                            ),
                            const Text(
                              ' / 100',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.verified_user_rounded,
                              color: AppColors.secondaryDark,
                              size: 28,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: data.reputationScore / 100.0,
                            minHeight: 8,
                            backgroundColor: AppColors.borderSubtle,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.secondaryDark),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Evaluations Activity Trend Chart
                  AnalyticsCardWidget(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Evaluated Deals Trend',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Startups vetted across the chosen timeframe',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 140,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: data.evaluationsTrend.map((point) {
                              final maxValue = data.evaluationsTrend
                                  .map((p) => p.value)
                                  .reduce((a, b) => a > b ? a : b);
                              final heightFactor = (maxValue > 0)
                                  ? (point.value / maxValue).clamp(0.15, 1.0)
                                  : 0.2;
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    point.value.toInt().toString(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: 22,
                                    height: 90 * heightFactor,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    point.label,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Sector Allocation Distribution
                  AnalyticsCardWidget(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Portfolio & Screening Sectors',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...data.sectorDistribution.map(
                          (sec) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryPurple,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    sec['sector']?.toString() ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${sec['count']} deals',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.grayBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    sec['share']?.toString() ?? '',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryPurple,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Recent Dealflow & Diligence Activities
                  AnalyticsCardWidget(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Diligence Activities',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...data.recentActivities.map(
                          (act) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: AppColors.secondarySoft,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.insights_rounded,
                                    color: AppColors.secondaryDark,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    act['title']?.toString() ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  act['time']?.toString() ?? '',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
