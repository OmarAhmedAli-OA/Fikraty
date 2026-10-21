import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';

class MyAnalyticsPage extends StatefulWidget {
  const MyAnalyticsPage({super.key});

  @override
  State<MyAnalyticsPage> createState() => _MyAnalyticsPageState();
}

class _MyAnalyticsPageState extends State<MyAnalyticsPage> {
  String _selectedPeriod = '30D'; // '7D', '30D', '90D'

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state is ProfileLoadedState ? state.profile : null;
        final isInvestor = profile?.role == UserRole.investor;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isInvestor ? 'Investor Analytics' : 'My Analytics',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  isInvestor
                      ? 'Dealflow, evaluations & portfolio activity'
                      : 'Profile, social & network performance',
                  style: const TextStyle(
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
                child: _buildPeriodSelector(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 4 Metric cards in 2x2 grid
                _buildMetricsGrid(isInvestor),

                const SizedBox(height: 14),

                // Reputation Score Card (Exact Figma match)
                _buildReputationCard(isInvestor),

                const SizedBox(height: 14),

                // Profile Views Chart Card (Exact Figma match)
                _buildProfileViewsChartCard(),

                const SizedBox(height: 14),

                // Top Posts Card (Exact Figma match)
                _buildTopPostsCard(profile, isInvestor),

                const SizedBox(height: 14),

                // Recent Activity Card (Exact Figma match)
                _buildRecentActivityCard(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // Pill Period Selector (7D | 30D | 90D)
  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E6EE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['7D', '30D', '90D'].map((period) {
          final isSelected = _selectedPeriod == period;
          return InkWell(
            onTap: () => setState(() => _selectedPeriod = period),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF5548E8) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                period,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF718096),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 4 Top Cards (Profile Views / Evaluations, Followers / Saved, Matches / Pipeline, Messages)
  Widget _buildMetricsGrid(bool isInvestor) {
    final data = isInvestor
        ? switch (_selectedPeriod) {
            '7D' => [
                {
                  'label': 'Startups Evaluated',
                  'value': '64',
                  'change': '+12 this week',
                  'color': 0xFF5548E8,
                },
                {
                  'label': 'Saved Startups',
                  'value': '8',
                  'change': '+2 this week',
                  'color': 0xFF00C48C,
                },
                {
                  'label': 'Active Pipeline',
                  'value': '4',
                  'change': '2 in DD',
                  'color': 0xFFE8A020,
                },
                {
                  'label': 'Meetings',
                  'value': '3',
                  'change': '3 this week',
                  'color': 0xFF5548E8,
                },
              ],
            '90D' => [
                {
                  'label': 'Startups Evaluated',
                  'value': '840',
                  'change': '+190 this quarter',
                  'color': 0xFF5548E8,
                },
                {
                  'label': 'Saved Startups',
                  'value': '85',
                  'change': '+24 this quarter',
                  'color': 0xFF00C48C,
                },
                {
                  'label': 'Active Pipeline',
                  'value': '12',
                  'change': '4 term sheets',
                  'color': 0xFFE8A020,
                },
                {
                  'label': 'Meetings',
                  'value': '36',
                  'change': '36 held',
                  'color': 0xFF5548E8,
                },
              ],
            _ => [
                {
                  'label': 'Startups Evaluated',
                  'value': '284',
                  'change': '+42 this month',
                  'color': 0xFF5548E8,
                },
                {
                  'label': 'Saved Startups',
                  'value': '31',
                  'change': '+7 this month',
                  'color': 0xFF00C48C,
                },
                {
                  'label': 'Active Pipeline',
                  'value': '6',
                  'change': '2 term sheets',
                  'color': 0xFFE8A020,
                },
                {
                  'label': 'Meetings',
                  'value': '12',
                  'change': '12 scheduled',
                  'color': 0xFF5548E8,
                },
              ],
          }
        : switch (_selectedPeriod) {
            '7D' => [
                {
                  'label': 'Profile Views',
                  'value': '680',
                  'change': '+85 this week',
                  'color': 0xFF5548E8,
                },
                {
                  'label': 'Followers',
                  'value': '1,080',
                  'change': '+60 this week',
                  'color': 0xFF00C48C,
                },
                {
                  'label': 'Investor Matches',
                  'value': '14',
                  'change': '+3 this week',
                  'color': 0xFFE8A020,
                },
                {
                  'label': 'Messages',
                  'value': '8',
                  'change': '8 received',
                  'color': 0xFF5548E8,
                },
              ],
            '90D' => [
                {
                  'label': 'Profile Views',
                  'value': '8,420',
                  'change': '+1,120 this quarter',
                  'color': 0xFF5548E8,
                },
                {
                  'label': 'Followers',
                  'value': '1,450',
                  'change': '+490 this quarter',
                  'color': 0xFF00C48C,
                },
                {
                  'label': 'Investor Matches',
                  'value': '132',
                  'change': '+35 this quarter',
                  'color': 0xFFE8A020,
                },
                {
                  'label': 'Messages',
                  'value': '96',
                  'change': '96 received',
                  'color': 0xFF5548E8,
                },
              ],
            _ => [
                {
                  'label': 'Profile Views',
                  'value': '2,840',
                  'change': '+340 this month',
                  'color': 0xFF5548E8,
                },
                {
                  'label': 'Followers',
                  'value': '1,200',
                  'change': '+240 this month',
                  'color': 0xFF00C48C,
                },
                {
                  'label': 'Investor Matches',
                  'value': '47',
                  'change': '+12 this month',
                  'color': 0xFFE8A020,
                },
                {
                  'label': 'Messages',
                  'value': '34',
                  'change': '34 received',
                  'color': 0xFF5548E8,
                },
              ],
          };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, index) {
        final item = data[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item['label'] as String,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                item['value'] as String,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['change'] as String,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(item['color'] as int),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Reputation Score Card (Exact Image match)
  Widget _buildReputationCard(bool isInvestor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isInvestor ? 'Investor Reputation Score' : 'Reputation Score',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isInvestor
                        ? 'Top 5% active angel investors in MENA'
                        : 'Top 8% of founders in your sector',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Text(
                isInvestor ? '92' : '78',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5548E8),
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Gradient progress bar
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 8,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 8,
                    width: constraints.maxWidth * 0.78,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5548E8), Color(0xFF00C48C)],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '0',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
              Text(
                '100',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Profile Views Chart Card
  Widget _buildProfileViewsChartCard() {
    final xLabels = switch (_selectedPeriod) {
      '7D' => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      '90D' => ['Month 1', 'Month 2', 'Month 3'],
      _ => ['W1', 'W2', 'W3', 'W4'],
    };

    final points = switch (_selectedPeriod) {
      '7D' => [0.3, 0.45, 0.4, 0.65, 0.6, 0.8, 0.85],
      '90D' => [0.25, 0.6, 0.9],
      _ => [0.35, 0.55, 0.75, 0.82],
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, size: 16, color: AppColors.textPrimary),
              const SizedBox(width: 6),
              Text(
                'Profile Views — $_selectedPeriod',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Custom Bezier Chart
          SizedBox(
            height: 110,
            width: double.infinity,
            child: CustomPaint(
              painter: _LineChartPainter(points: points),
            ),
          ),
          const SizedBox(height: 8),

          // Horizontal Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: xLabels
                .map(
                  (lbl) => Text(
                    lbl,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // Top Posts Card (Exact Figma match)
  Widget _buildTopPostsCard(UserProfile? profile, bool isInvestor) {
    final defaultPosts = isInvestor
        ? [
            {
              'text':
                  'What I look for in a founder pitch: clarity of problem, size of opportunity, and undeniable unfair advantage...',
              'likes': 512,
              'time': '4h ago',
            },
            {
              'text':
                  'Proud to lead NovaMed AI\'s Seed round. This team is solving a real problem at scale in healthcare diagnostics...',
              'likes': 243,
              'time': '3d ago',
            },
          ]
        : [
            {
              'text':
                  'Thrilled to announce NovaMed AI has just closed our Seed round — \$2.4M led by Sequoia Arabia...',
              'likes': 284,
              'time': '2h ago',
            },
            {
              'text':
                  'Month 3 update: we onboarded our first 10 clinics across UAE and KSA. The AI is performing...',
              'likes': 156,
              'time': '2w ago',
            },
          ];

    final posts = profile != null && profile.posts.isNotEmpty
        ? profile.posts.take(2).map((p) => {
              'text': p.text,
              'likes': p.likes,
              'time': p.time,
            }).toList()
        : defaultPosts;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isInvestor
                ? 'Top Investment Insights — $_selectedPeriod'
                : 'Top Posts — $_selectedPeriod',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...posts.asMap().entries.map((entry) {
            final idx = entry.key;
            final post = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (idx > 0) const Divider(height: 24, color: AppColors.cardBorder),
                Text(
                  post['text'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      size: 14,
                      color: Color(0xFFE02424),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post['likes']} likes',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      post['time'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // Recent Activity Card (Exact Figma match)
  Widget _buildRecentActivityCard() {
    final activities = [
      {
        'color': 0xFF5548E8,
        'text': '12 new investors bookmarked your profile',
        'time': '1w ago',
      },
      {
        'color': 0xFF00C48C,
        'text': 'Reputation score increased to 78',
        'time': '2w ago',
      },
      {
        'color': 0xFFE8A020,
        'text': 'Post reached 500+ views',
        'time': '3w ago',
      },
      {
        'color': 0xFF8B5CF6,
        'text': '+240 new followers this month',
        'time': 'This month',
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...activities.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Column(
              children: [
                if (idx > 0)
                  const Divider(height: 20, color: AppColors.cardBorder),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color(item['color'] as int),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item['text'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      item['time'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// Chart Painter for smooth gradient curve
class _LineChartPainter extends CustomPainter {
  final List<double> points;

  _LineChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height - (points[i] * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = size.height - (points[i - 1] * size.height);
        final controlX1 = prevX + (x - prevX) / 2;
        final controlY1 = prevY;
        final controlX2 = prevX + (x - prevX) / 2;
        final controlY2 = y;
        path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
        fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Fill paint with subtle gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF5548E8).withValues(alpha: 0.25),
          const Color(0xFF5548E8).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Line paint
    final linePaint = Paint()
      ..color = const Color(0xFF5548E8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
