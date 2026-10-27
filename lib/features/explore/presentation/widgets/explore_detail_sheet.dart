import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/explore_campaign.dart';
import '../../domain/entities/explore_event.dart';
import '../../domain/entities/explore_founder.dart';
import '../../domain/entities/explore_investor.dart';
import '../../domain/entities/explore_startup.dart';

class ExploreDetailSheet extends StatelessWidget {
  const ExploreDetailSheet({
    super.key,
    this.startup,
    this.investor,
    this.founder,
    this.event,
    this.campaign,
    this.onExpressInterest,
    this.onToggleRegister,
  });

  final ExploreStartup? startup;
  final ExploreInvestor? investor;
  final ExploreFounder? founder;
  final ExploreEvent? event;
  final ExploreCampaign? campaign;
  final VoidCallback? onExpressInterest;
  final VoidCallback? onToggleRegister;

  static void show(
    BuildContext context, {
    ExploreStartup? startup,
    ExploreInvestor? investor,
    ExploreFounder? founder,
    ExploreEvent? event,
    ExploreCampaign? campaign,
    VoidCallback? onExpressInterest,
    VoidCallback? onToggleRegister,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExploreDetailSheet(
        startup: startup,
        investor: investor,
        founder: founder,
        event: event,
        campaign: campaign,
        onExpressInterest: onExpressInterest,
        onToggleRegister: onToggleRegister,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),

          // Content body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: _buildBody(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (startup != null) return _buildStartupDetail(context, startup!);
    if (investor != null) return _buildInvestorDetail(context, investor!);
    if (founder != null) return _buildFounderDetail(context, founder!);
    if (event != null) return _buildEventDetail(context, event!);
    if (campaign != null) return _buildCampaignDetail(context, campaign!);
    return const Center(child: Text('No details available.'));
  }

  Widget _buildStartupDetail(BuildContext context, ExploreStartup s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Color(s.colorHex),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  s.initials,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          s.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                      if (s.isVerified) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, size: 18, color: AppColors.primary),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${s.industry} · ${s.stage} · ${s.location}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.tertiaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          s.tagline,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333340),
          ),
        ),
        const SizedBox(height: 16),

        // Metrics Row
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniMetric('Raised', '\$${(s.raisedAmount / 1000000).toStringAsFixed(1)}M'),
              _buildMiniMetric('Valuation', '\$${(s.valuation / 1000000).toStringAsFixed(1)}M'),
              _buildMiniMetric('MRR', '\$${(s.mrr / 1000).toStringAsFixed(0)}K'),
              _buildMiniMetric('Growth', '+${s.monthlyGrowth.toInt()}%'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _buildDetailSection('About', s.about),
        _buildDetailSection('Problem', s.problem),
        _buildDetailSection('Solution', s.solution),
        _buildDetailSection('Business Model', s.businessModel),
        _buildDetailSection('Target Market', s.targetMarket),

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onExpressInterest != null) onExpressInterest!();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Connect with Startup',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvestorDetail(BuildContext context, ExploreInvestor inv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(inv.avatarUrl),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          inv.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                      if (inv.isVerified) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, size: 18, color: AppColors.primary),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${inv.type} at ${inv.firm}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    inv.location,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.tertiaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Ticket & Stats
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniMetric('Ticket Range', inv.ticket),
              _buildMiniMetric('Total Invested', inv.totalInvested),
              _buildMiniMetric('Active Deals', '${inv.activeDeals}'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _buildDetailSection('Investment Thesis', inv.thesis),
        _buildDetailSection('Bio', inv.bio),
        _buildDetailSection('Portfolio', inv.portfolio.join(', ')),

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onExpressInterest != null) onExpressInterest!();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: inv.isInterestSent
                  ? const Color(0xFFE6FBF5)
                  : AppColors.primary,
              foregroundColor: inv.isInterestSent
                  ? AppColors.secondary
                  : AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              inv.isInterestSent ? 'Interest Sent ✓' : 'Express Interest',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFounderDetail(BuildContext context, ExploreFounder f) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(f.avatarUrl),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                  Text(
                    '${f.role} · ${f.startupName}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    f.location,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.tertiaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildDetailSection('About', f.bio),
        _buildDetailSection('Looking For', f.lookingFor),
        _buildDetailSection('Expertise', f.skills.join(' · ')),

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onExpressInterest != null) onExpressInterest!();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: f.isInterestSent
                  ? const Color(0xFFE6FBF5)
                  : AppColors.primary,
              foregroundColor: f.isInterestSent
                  ? AppColors.secondary
                  : AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              f.isInterestSent ? 'Interest Sent ✓' : 'Connect with Founder',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventDetail(BuildContext context, ExploreEvent e) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            e.imageUrl,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          e.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${e.date} · ${e.time} · ${e.location}',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailSection('About Event', e.description),
        _buildDetailSection('Organized by', e.organizer),
        _buildDetailSection('Attendees', '${e.attendeesCount} participants registered'),

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onToggleRegister != null) onToggleRegister!();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: e.isRegistered
                  ? const Color(0xFFE6FBF5)
                  : AppColors.primary,
              foregroundColor: e.isRegistered
                  ? AppColors.secondary
                  : AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              e.isRegistered ? 'Registered ✓ (Tap to cancel)' : 'Register for Event',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCampaignDetail(BuildContext context, ExploreCampaign c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          c.startupName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${c.investmentType} · ${c.industry} · Closes ${c.deadline}',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailSection('Round Overview', c.description),
        _buildDetailSection('Target Amount', '\$${(c.targetAmount / 1000000).toStringAsFixed(1)}M'),
        _buildDetailSection('Amount Raised', '\$${(c.raisedAmount / 1000000).toStringAsFixed(1)}M (${c.fundedPercentage.toInt()}%)'),
        _buildDetailSection('Minimum Ticket', '\$${c.minTicket.toInt()}'),
      ],
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.tertiaryText,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF404050),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.tertiaryText,
          ),
        ),
      ],
    );
  }
}
