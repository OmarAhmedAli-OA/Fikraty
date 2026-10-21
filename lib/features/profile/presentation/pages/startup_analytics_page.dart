import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class StartupAnalyticsPage extends StatefulWidget {
  const StartupAnalyticsPage({super.key});

  @override
  State<StartupAnalyticsPage> createState() => _StartupAnalyticsPageState();
}

class _StartupAnalyticsPageState extends State<StartupAnalyticsPage> {
  String _selectedPeriod = '30D'; // '7D', '30D', '90D'

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Startup Analytics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
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
            // 4 Top Metric Cards (MRR, MoM Growth, Runway, Burn Rate)
            _buildTopMetricsGrid(),

            const SizedBox(height: 14),

            // MRR Trend Chart Card (Exact Image match)
            _buildMrrTrendCard(),

            const SizedBox(height: 14),

            // Investor Activity Card (Exact Image match)
            _buildInvestorActivityCard(),

            const SizedBox(height: 14),

            // Top Traffic Sources Card (Exact Image match)
            _buildTopTrafficSourcesCard(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Period Selector Pill (7D | 30D | 90D)
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

  // 4 Top Metric Cards
  Widget _buildTopMetricsGrid() {
    final metrics = switch (_selectedPeriod) {
      '7D' => [
          {
            'label': 'MRR',
            'value': '\$39K',
            'change': '▲ +12%',
            'changeColor': 0xFF00C48C,
          },
          {
            'label': 'MoM Growth',
            'value': '+14%',
            'change': '▲ +1pp',
            'changeColor': 0xFF00C48C,
          },
          {
            'label': 'Runway',
            'value': '15mo',
            'change': 'Stable',
            'changeColor': 0xFF718096,
          },
          {
            'label': 'Burn Rate',
            'value': '\$26K/mo',
            'change': '▼ -3%',
            'changeColor': 0xFFE02424,
          },
        ],
      '90D' => [
          {
            'label': 'MRR',
            'value': '\$48K',
            'change': '▲ +24%',
            'changeColor': 0xFF00C48C,
          },
          {
            'label': 'MoM Growth',
            'value': '+26%',
            'change': '▲ +6pp',
            'changeColor': 0xFF00C48C,
          },
          {
            'label': 'Runway',
            'value': '12mo',
            'change': 'Stable',
            'changeColor': 0xFF718096,
          },
          {
            'label': 'Burn Rate',
            'value': '\$31K/mo',
            'change': '▼ -8%',
            'changeColor': 0xFFE02424,
          },
        ],
      _ => [
          {
            'label': 'MRR',
            'value': '\$42K',
            'change': '▲ +18%',
            'changeColor': 0xFF00C48C,
          },
          {
            'label': 'MoM Growth',
            'value': '+18%',
            'change': '▲ +3pp',
            'changeColor': 0xFF00C48C,
          },
          {
            'label': 'Runway',
            'value': '14mo',
            'change': 'Stable',
            'changeColor': 0xFF718096,
          },
          {
            'label': 'Burn Rate',
            'value': '\$28K/mo',
            'change': '▼ -5%',
            'changeColor': 0xFFE02424,
          },
        ],
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, index) {
        final item = metrics[index];
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
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(item['changeColor'] as int),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // MRR Trend Chart Card
  Widget _buildMrrTrendCard() {
    final xLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final yLabels = ['\$42K', '\$28K', '\$18K', '\$12K'];
    final points = [0.2, 0.35, 0.5, 0.65, 0.78, 0.95];

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
                'MRR Trend — $_selectedPeriod',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Chart with Y-axis guides
          Row(
            children: [
              // Y labels
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: yLabels
                    .map(
                      (y) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          y,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(width: 10),

              // Canvas chart
              Expanded(
                child: SizedBox(
                  height: 110,
                  child: CustomPaint(
                    painter: _MrrChartPainter(points: points),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Bottom X labels
          Padding(
            padding: const EdgeInsets.only(left: 36.0),
            child: Row(
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
          ),
        ],
      ),
    );
  }

  // Investor Activity — {Period} (Exact Image match)
  Widget _buildInvestorActivityCard() {
    final data = switch (_selectedPeriod) {
      '7D' => [
          {
            'label': 'Profile Views',
            'val': '95',
            'sub': '▲ +15%',
            'subColor': 0xFF00C48C,
          },
          {
            'label': 'Pitch Deck Opens',
            'val': '24',
            'sub': '▲ +8%',
            'subColor': 0xFF00C48C,
          },
          {
            'label': 'Interest Received',
            'val': '6',
            'sub': 'new',
            'subColor': 0xFF5548E8,
          },
          {
            'label': 'Meetings Scheduled',
            'val': '2',
            'sub': '',
            'subColor': 0xFF718096,
          },
        ],
      '90D' => [
          {
            'label': 'Profile Views',
            'val': '980',
            'sub': '▲ +52%',
            'subColor': 0xFF00C48C,
          },
          {
            'label': 'Pitch Deck Opens',
            'val': '260',
            'sub': '▲ +28%',
            'subColor': 0xFF00C48C,
          },
          {
            'label': 'Interest Received',
            'val': '68',
            'sub': 'new',
            'subColor': 0xFF5548E8,
          },
          {
            'label': 'Meetings Scheduled',
            'val': '22',
            'sub': '',
            'subColor': 0xFF718096,
          },
        ],
      _ => [
          {
            'label': 'Profile Views',
            'val': '342',
            'sub': '▲ +34%',
            'subColor': 0xFF00C48C,
          },
          {
            'label': 'Pitch Deck Opens',
            'val': '89',
            'sub': '▲ +12%',
            'subColor': 0xFF00C48C,
          },
          {
            'label': 'Interest Received',
            'val': '24',
            'sub': 'new',
            'subColor': 0xFF5548E8,
          },
          {
            'label': 'Meetings Scheduled',
            'val': '8',
            'sub': '',
            'subColor': 0xFF718096,
          },
        ],
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
          Text(
            'Investor Activity — $_selectedPeriod',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // 2x2 grid inside card
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, index) {
              final item = data[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['label'] as String,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['val'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if ((item['sub'] as String).isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item['sub'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(item['subColor'] as int),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Top Traffic Sources Card
  Widget _buildTopTrafficSourcesCard() {
    final sources = [
      {'name': 'Direct', 'percent': 45},
      {'name': 'Explore', 'percent': 28},
      {'name': 'Matching', 'percent': 18},
      {'name': 'Referral', 'percent': 9},
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
          Row(
            children: const [
              Icon(Icons.bar_chart, size: 16, color: AppColors.textPrimary),
              SizedBox(width: 6),
              Text(
                'Top Traffic Sources',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sources.map((src) {
            final percent = src['percent'] as int;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        src['name'] as String,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Container(
                            height: 6,
                            width: constraints.maxWidth,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F2F6),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          Container(
                            height: 6,
                            width: constraints.maxWidth * (percent / 100),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5548E8),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Chart painter for MRR line chart with circular dot points
class _MrrChartPainter extends CustomPainter {
  final List<double> points;

  _MrrChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final path = Path();
    final fillPath = Path();
    final stepX = size.width / (points.length - 1);
    final offsets = <Offset>[];

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height - (points[i] * size.height);
      offsets.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Fill gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF5548E8).withValues(alpha: 0.20),
          const Color(0xFF5548E8).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = const Color(0xFF5548E8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Circle dots on vertices
    final dotFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = const Color(0xFF5548E8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final pt in offsets) {
      canvas.drawCircle(pt, 4.0, dotFillPaint);
      canvas.drawCircle(pt, 4.0, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MrrChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
