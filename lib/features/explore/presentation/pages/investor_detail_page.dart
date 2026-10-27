import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/explore_investor.dart';
import '../../../home/presentation/pages/chat_detail_page.dart';
import '../bloc/explore_bloc.dart';
import '../bloc/explore_event.dart';
import '../bloc/explore_state.dart';

class InvestorDetailPage extends StatefulWidget {
  const InvestorDetailPage({
    super.key,
    required this.investor,
  });

  final ExploreInvestor investor;

  @override
  State<InvestorDetailPage> createState() => _InvestorDetailPageState();
}

class _InvestorDetailPageState extends State<InvestorDetailPage> {
  void _toggleSave() {
    context.read<ExploreBloc>().add(
          ToggleBookmarkEvent(type: 'investor', id: widget.investor.id),
        );
  }

  void _toggleFollow(bool currentIsFollowing, String name) {
    final nextFollowing = !currentIsFollowing;
    context.read<ExploreBloc>().add(
          ToggleFollowEvent(type: 'investor', id: widget.investor.id),
        );
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nextFollowing
              ? 'You are now following $name'
              : 'Unfollowed $name',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openMessage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          userName: widget.investor.name,
          userAvatar: widget.investor.avatarUrl,
          isOnline: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exploreState = context.watch<ExploreBloc>().state;
    final inv = (exploreState is ExploreLoadedState)
        ? exploreState.investors.firstWhere(
            (i) => i.id == widget.investor.id,
            orElse: () => widget.investor,
          )
        : widget.investor;
    final isSaved = inv.isSaved;
    final isFollowing = inv.isFollowing;
    final followersCount = inv.followers;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          inv.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border_rounded,
              color: isSaved ? AppColors.primary : AppColors.darkText,
            ),
            onPressed: _toggleSave,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.darkText),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Investor profile link copied!'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Investor Header Card
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundImage: NetworkImage(inv.avatarUrl),
                    backgroundColor: AppColors.selectionTint,
                    child: inv.avatarUrl.isEmpty
                        ? Text(
                            inv.name.isNotEmpty ? inv.name[0] : 'I',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          inv.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (inv.isVerified) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, size: 20, color: AppColors.primary),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${inv.type} at ${inv.firm}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.tertiaryText),
                      const SizedBox(width: 4),
                      Text(
                        '${inv.location} · $followersCount followers',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.tertiaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Investment Statistics Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _buildStatTile('Check Size', inv.ticket),
                  Container(width: 1, height: 40, color: AppColors.border),
                  _buildStatTile('Total Invested', inv.totalInvested),
                  Container(width: 1, height: 40, color: AppColors.border),
                  _buildStatTile('Active Deals', '${inv.activeDeals}'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Investment Thesis Card
            if (inv.thesis.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.format_quote_rounded, color: AppColors.primary, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'INVESTMENT THESIS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"${inv.thesis}"',
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E293B),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),

            // Bio
            _buildSection(
              title: 'About & Background',
              icon: Icons.person_outline_rounded,
              content: inv.bio,
            ),

            // Focus Areas / Preferred Sectors
            if (inv.industries.isNotEmpty || inv.stages.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.filter_list_rounded, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Investment Preferences',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                    if (inv.industries.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Target Industries',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.tertiaryText),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: inv.industries
                            .map((i) => _buildChip(i, AppColors.primaryPurple.withValues(alpha: 0.1), AppColors.primaryPurple))
                            .toList(),
                      ),
                    ],
                    if (inv.stages.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Preferred Stages',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.tertiaryText),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: inv.stages
                            .map((st) => _buildChip(st, const Color(0xFFF1F5F9), AppColors.darkText))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),

            // Portfolio Companies
            if (inv.portfolio.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.pie_chart_outline_rounded, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Portfolio Highlights',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: inv.portfolio.map((company) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                company,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openMessage,
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text(
                    'Message',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _toggleFollow(isFollowing, inv.name),
                  icon: Icon(
                    isFollowing ? Icons.check_circle_rounded : Icons.person_add_rounded,
                    size: 18,
                  ),
                  label: Text(
                    isFollowing ? 'Following' : 'Follow',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? const Color(0xFFE6FBF5) : AppColors.primary,
                    foregroundColor: isFollowing ? AppColors.secondary : AppColors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.tertiaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required String content,
  }) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF475569),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
