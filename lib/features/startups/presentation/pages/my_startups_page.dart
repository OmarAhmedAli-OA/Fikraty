import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../verification/presentation/pages/submit_verification_page.dart';
import '../../data/repositories/startups_repository_impl.dart';
import '../../domain/entities/startups.dart';
import '../bloc/startups_bloc.dart';
import '../bloc/startups_event.dart';
import '../bloc/startups_state.dart';
import '../widgets/dashed_create_card.dart';
import '../widgets/startup_header_card.dart';
import '../widgets/startup_member_tile.dart';
import 'startup_wizard_page.dart';

class MyStartupsPage extends StatelessWidget {
  const MyStartupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StartupsBloc(
        repository: StartupsRepositoryImpl(),
      )..add(const LoadMyStartupEvent()),
      child: const _MyStartupsView(),
    );
  }
}

class _MyStartupsView extends StatelessWidget {
  const _MyStartupsView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1, // Default to 'Startup' tab
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: _buildProfileHeader(context),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  labelColor: const Color(0xFF6C5CE7),
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorColor: const Color(0xFF6C5CE7),
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  tabs: const [
                    Tab(text: 'Posts'),
                    Tab(text: 'Startup'),
                    Tab(text: 'Analytics'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _buildPostsPlaceholder(),
              _buildStartupTab(context),
              _buildAnalyticsPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }

  /// Profile Header matching Figma design
  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        // Top Purple Banner
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 110,
              width: double.infinity,
              color: const Color(0xFF7052FF),
              padding: const EdgeInsets.only(top: 36, right: 16, left: 16),
              alignment: Alignment.topRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      final state = context.read<StartupsBloc>().state;
                      final startup = state is StartupsLoadedState ? state.startup : null;
                      final shareText = startup != null
                          ? '${startup.name} on Fikraty: ${startup.tagline}'
                          : 'Explore startup investment profiles on Fikraty!';
                      Clipboard.setData(ClipboardData(text: shareText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile details copied to clipboard!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Share Profile'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      final state = context.read<StartupsBloc>().state;
                      final startup = state is StartupsLoadedState ? state.startup : null;
                      _navigateToWizard(context, startup);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF7052FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(Icons.edit_rounded, size: 15),
                    label: const Text(
                      'Edit',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            // Avatar
            Positioned(
              left: 18,
              bottom: -40,
              child: Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Youssef\nali rafat',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 48),

        // Founder Details
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Youssef ali rafat',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E2D),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Pending Review',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6D28D9),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              Text(
                'Founder & Tech Entrepreneur',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 15,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Qalyubia',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '  •  ',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                  Icon(
                    Icons.language_rounded,
                    size: 15,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'https://fikraty.app',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                'Passionate founder building next-gen tech solutions to connect startups with smart capital.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade800,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 12),

              // Badges
              Row(
                children: [
                  _buildTagChip('Top Pitcher', const Color(0xFFFEF3C7),
                      const Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  _buildTagChip('Fast Growing', const Color(0xFFCCFBF1),
                      const Color(0xFF0F766E)),
                ],
              ),

              const SizedBox(height: 16),

              // Stats Row
              Row(
                children: [
                  _buildStatItem('1.2K', 'Followers'),
                  const SizedBox(width: 24),
                  _buildStatItem('348', 'Following'),
                  const SizedBox(width: 24),
                  _buildStatItem('49', 'Investors interested'),
                ],
              ),

              const SizedBox(height: 14),

              // Category Chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  'Product',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Row(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E2D),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Startup Tab Content (Empty State or Filled Dashboard)
  Widget _buildStartupTab(BuildContext context) {
    return BlocConsumer<StartupsBloc, StartupsState>(
      listener: (context, state) {
        if (state is StartupActionSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.message,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        if (state is StartupsErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is StartupsLoadingState) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
          );
        }

        if (state is StartupsLoadedState) {
          final startup = state.startup;
          if (startup == null) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              child: DashedCreateCard(
                onTap: () => _navigateToWizard(context, null),
              ),
            );
          }
          return _buildStartupDashboard(context, startup);
        }

        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
        );
      },
    );
  }

  /// Filled Startup Dashboard
  Widget _buildStartupDashboard(BuildContext context, StartupEntity startup) {
    return RefreshIndicator(
      color: const Color(0xFF6C5CE7),
      onRefresh: () async {
        context.read<StartupsBloc>().add(const LoadMyStartupEvent());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Startup Header Card
            StartupHeaderCard(
              startup: startup,
              onEditPressed: () => _navigateToWizard(context, startup),
              onVerifyPressed: () => _navigateToVerification(context, startup),
            ),

            const SizedBox(height: 22),

            // Fundraising & Traction Section
            if (startup.targetRaise.isNotEmpty || startup.activeUsers.isNotEmpty) ...[
              _buildSectionTitle('Fundraising Ask & Growth Traction'),
              const SizedBox(height: 10),
              _buildFundraisingCard(startup),
              const SizedBox(height: 22),
            ],

            // Problem & Solution Section
            _buildSectionTitle('The Pitch & Business Model'),
            const SizedBox(height: 10),
            _buildInfoCard(
              title: 'The Problem',
              content: startup.problem,
              icon: Icons.lightbulb_outline_rounded,
              iconColor: Colors.amber.shade800,
            ),
            const SizedBox(height: 10),
            _buildInfoCard(
              title: 'The Innovative Solution',
              content: startup.solution,
              icon: Icons.check_circle_outline_rounded,
              iconColor: Colors.teal,
            ),
            const SizedBox(height: 10),
            _buildInfoCard(
              title: 'Business Model & Target Market',
              content:
                  '${startup.businessModel}\n\nTarget Market: ${startup.targetMarket}',
              icon: Icons.pie_chart_outline_rounded,
              iconColor: AppColors.blue,
            ),

            const SizedBox(height: 22),

            // Team Members Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle(
                    'Co-Founding Team (${startup.members.length})'),
                TextButton.icon(
                  onPressed: () => _showManageTeamSheet(context, startup),
                  icon: const Icon(Icons.people_alt_rounded, size: 18),
                  label: const Text('Manage Team'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (startup.members.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.tint),
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Text(
                        'No team members added yet.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _showManageTeamSheet(context, startup),
                        icon: const Icon(Icons.person_add_rounded, size: 16),
                        label: const Text('Add Team Members Now'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6C5CE7),
                          side: const BorderSide(color: Color(0xFF6C5CE7)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...startup.members.map(
                (m) => StartupMemberTile(
                  member: m,
                  onEditPressed: () =>
                      _editSingleMemberDirectly(context, startup, m),
                  onDeletePressed: () =>
                      _deleteSingleMemberDirectly(context, startup, m),
                ),
              ),

            const SizedBox(height: 22),

            // Links & Pitch Deck
            _buildSectionTitle('Links & Investor Presentations'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.tint),
              ),
              child: Column(
                children: [
                  _buildLinkRow(
                    icon: Icons.language_rounded,
                    title: 'Official Website',
                    value: startup.websiteUrl ?? 'Not specified',
                    trailing: startup.websiteUrl != null &&
                            startup.websiteUrl!.isNotEmpty
                        ? const Icon(Icons.open_in_new_rounded,
                            size: 16, color: AppColors.blue)
                        : null,
                    onTap: startup.websiteUrl != null &&
                            startup.websiteUrl!.isNotEmpty
                        ? () {
                            Clipboard.setData(
                                ClipboardData(text: startup.websiteUrl!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Website URL copied: ${startup.websiteUrl}'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        : null,
                  ),
                  const Divider(height: 20),
                  _buildLinkRow(
                    icon: Icons.play_circle_outline_rounded,
                    title: 'Interactive Demo',
                    value: startup.demoUrl ?? 'Not specified',
                    trailing: startup.demoUrl != null &&
                            startup.demoUrl!.isNotEmpty
                        ? const Icon(Icons.play_arrow_rounded,
                            size: 18, color: AppColors.blue)
                        : null,
                    onTap: startup.demoUrl != null &&
                            startup.demoUrl!.isNotEmpty
                        ? () {
                            Clipboard.setData(
                                ClipboardData(text: startup.demoUrl!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Demo URL copied: ${startup.demoUrl}'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        : null,
                  ),
                  const Divider(height: 20),
                  _buildLinkRow(
                    icon: Icons.picture_as_pdf_rounded,
                    title: 'Pitch Deck & Data Room',
                    value: 'Pitch deck attached & investor-ready',
                    trailing: const Icon(Icons.visibility_outlined,
                        size: 18, color: AppColors.blue),
                    onTap: () => _showPitchDeckModal(context, startup),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.feed_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No Posts Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E2D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share startup milestones, launches, and founder stories with the community.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights_rounded, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Profile Analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E2D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track page visits, investor engagement, and deck downloads once your startup is active.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.navy,
      ),
    );
  }

  Widget _buildFundraisingCard(StartupEntity startup) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.monetization_on_rounded,
                      color: Color(0xFF6C5CE7),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fundraising Deal Terms',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        startup.fundingRound,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6C5CE7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6FFFA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF38B2AC)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up_rounded,
                        size: 14, color: Color(0xFF38B2AC)),
                    SizedBox(width: 4),
                    Text(
                      'Actively Raising',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF38B2AC),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          // Metric Row 1: Target, Valuation Cap, Min Ticket
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Goal',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      startup.targetRaise,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E2D),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valuation Cap',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      startup.valuationCap,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C5CE7),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Min Ticket',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      startup.minTicket,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E2D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Metric Row 2: Monthly Rev, Growth Rate, Instrument
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Rev',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      startup.monthlyRevenue,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Growth Rate',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      startup.growthRate,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stage',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      startup.stageName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (startup.activeUsers.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F2F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_alt_rounded, size: 16, color: Color(0xFF6C5CE7)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Active Traction: ${startup.activeUsers}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (startup.useOfFunds.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pie_chart_rounded, size: 16, color: Color(0xFF6D28D9)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Use of Funds: ${startup.useOfFunds}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF5B21B6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.tint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content.isNotEmpty ? content : 'No details specified yet.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.navy),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  void _showManageTeamSheet(BuildContext context, StartupEntity startup) {
    final bloc = context.read<StartupsBloc>();
    List<StartupMemberEntity> currentMembers = List.from(startup.members);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetCtx).size.height * 0.85,
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C5CE7).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.people_alt_rounded,
                              color: Color(0xFF6C5CE7), size: 22),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Manage Startup Team',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.navy,
                              ),
                            ),
                            Text(
                              '${currentMembers.length} member(s) listed',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(sheetCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Add, edit roles, or update co-founders and team members without re-editing the rest of your startup profile.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Members List
                Expanded(
                  child: currentMembers.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.group_off_rounded,
                                    size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                const Text(
                                  'No Team Members Added',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Add your co-founders and key specialists below to build investor credibility.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: currentMembers.length,
                          itemBuilder: (ctx, index) {
                            final member = currentMembers[index];
                            return StartupMemberTile(
                              member: member,
                              onEditPressed: () {
                                _showMemberFormDialog(
                                  context: sheetCtx,
                                  initialMember: member,
                                  title: 'Edit Team Member',
                                  confirmLabel: 'Update Member',
                                  onConfirm: (updated) {
                                    setSheetState(() {
                                      currentMembers[index] = updated;
                                    });
                                  },
                                );
                              },
                              onDeletePressed: () {
                                setSheetState(() {
                                  currentMembers.removeAt(index);
                                });
                              },
                            );
                          },
                        ),
                ),

                const SizedBox(height: 12),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showMemberFormDialog(
                            context: sheetCtx,
                            title: 'Add New Member',
                            confirmLabel: 'Add to Team',
                            onConfirm: (newMember) {
                              setSheetState(() {
                                currentMembers.add(newMember);
                              });
                            },
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6C5CE7),
                          side: const BorderSide(color: Color(0xFF6C5CE7)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.person_add_rounded, size: 18),
                        label: const Text(
                          'Add Member',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final updatedStartup =
                              startup.copyWith(members: currentMembers);
                          bloc.add(
                              SaveStartupEvent(updatedStartup, isEditing: true));
                          Navigator.pop(sheetCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    'Team updated successfully!',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C5CE7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text(
                          'Save Changes',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _editSingleMemberDirectly(
    BuildContext context,
    StartupEntity startup,
    StartupMemberEntity member,
  ) {
    final bloc = context.read<StartupsBloc>();
    _showMemberFormDialog(
      context: context,
      initialMember: member,
      title: 'Edit Team Member',
      confirmLabel: 'Save & Update',
      onConfirm: (updated) {
        final updatedList = startup.members.map((m) {
          return m.id == member.id ? updated : m;
        }).toList();
        final updatedStartup = startup.copyWith(members: updatedList);
        bloc.add(SaveStartupEvent(updatedStartup, isEditing: true));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Member "${updated.fullName}" updated successfully!',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  void _deleteSingleMemberDirectly(
    BuildContext context,
    StartupEntity startup,
    StartupMemberEntity member,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Team Member?'),
        content: Text(
            'Are you sure you want to remove "${member.fullName}" from ${startup.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              final bloc = context.read<StartupsBloc>();
              final updatedList =
                  startup.members.where((m) => m.id != member.id).toList();
              final updatedStartup = startup.copyWith(members: updatedList);
              bloc.add(SaveStartupEvent(updatedStartup, isEditing: true));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Member "${member.fullName}" removed.'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showMemberFormDialog({
    required BuildContext context,
    StartupMemberEntity? initialMember,
    required String title,
    required String confirmLabel,
    required void Function(StartupMemberEntity) onConfirm,
  }) {
    final nameCtrl = TextEditingController(text: initialMember?.fullName ?? '');
    final roleCtrl = TextEditingController(text: initialMember?.roleTitle ?? '');
    final bioCtrl = TextEditingController(text: initialMember?.bio ?? '');
    bool isCofounder = initialMember?.isCofounder ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: roleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Role Title (e.g. CTO, CFO, Lead AI) *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: bioCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Brief Experience / Background',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Co-founder Role'),
                    value: isCofounder,
                    activeThumbColor: AppColors.blue,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setModalState(() => isCofounder = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty ||
                          roleCtrl.text.trim().isEmpty) {
                        return;
                      }
                      final member = StartupMemberEntity(
                        id: initialMember?.id ??
                            'mem-${DateTime.now().millisecondsSinceEpoch}',
                        fullName: nameCtrl.text.trim(),
                        roleTitle: roleCtrl.text.trim(),
                        isCofounder: isCofounder,
                        bio: bioCtrl.text.trim().isNotEmpty
                            ? bioCtrl.text.trim()
                            : null,
                      );
                      onConfirm(member);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPitchDeckModal(BuildContext context, StartupEntity startup) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded,
                      color: Colors.red, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pitch Deck & Data Room',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                      Text(
                        'Verified Investor Presentation',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FD),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.tint),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Startup Company:',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      Text(
                        startup.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Round & Target:',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      Text(
                        '${startup.fundingRound} - ${startup.targetRaise}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C5CE7),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Valuation Cap:',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      Text(
                        startup.valuationCap,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  if (startup.useOfFunds.isNotEmpty) ...[
                    const Divider(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Use of Funds: ',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        Expanded(
                          child: Text(
                            startup.useOfFunds,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.ink,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final summary =
                          'Startup: ${startup.name}\nTagline: ${startup.tagline}\nRound: ${startup.fundingRound}\nTarget: ${startup.targetRaise}\nValuation Cap: ${startup.valuationCap}\nMRR: ${startup.monthlyRevenue}\nMoM Growth: ${startup.growthRate}';
                      Clipboard.setData(ClipboardData(text: summary));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pitch summary copied to clipboard!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copy Summary'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToWizard(BuildContext context, StartupEntity? current) async {
    final bloc = context.read<StartupsBloc>();
    await Navigator.push<StartupEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: StartupWizardPage(initialStartup: current),
        ),
      ),
    );
    bloc.add(const LoadMyStartupEvent());
  }

  void _navigateToVerification(
      BuildContext context, StartupEntity startup) async {
    final bloc = context.read<StartupsBloc>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: SubmitVerificationPage(startup: startup),
        ),
      ),
    );
    bloc.add(const LoadMyStartupEvent());
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
