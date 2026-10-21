import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/auth.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../startups/domain/entities/startups.dart';
import '../../../startups/presentation/pages/my_startups_page.dart';
import '../../../startups/presentation/pages/startup_wizard_page.dart';
import '../../../startups/presentation/pages/submit_verification_page.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../bloc/feed_state.dart';
import '../widgets/feed_app_bar.dart';
import '../widgets/investor_matches_banner.dart';
import '../widgets/post_card.dart';
import '../widgets/quick_create_box.dart';
import '../widgets/recommended_investors_card.dart';
import '../widgets/stories_tray.dart';
import '../widgets/trending_tags_bar.dart';
import 'explore_page.dart';
import 'messages_page.dart';
import 'notifications_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeScreenBody();
  }
}

class _HomeScreenBody extends StatefulWidget {
  const _HomeScreenBody();

  @override
  State<_HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<_HomeScreenBody> {
  int _selectedBottomNavIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedBottomNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == AuthStatus.unauthenticated,
      listener: (context, state) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.signIn,
          (_) => false,
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _selectedBottomNavIndex == 0 ? const FeedAppBar() : null,
        body: IndexedStack(
          index: _selectedBottomNavIndex,
          children: [
            _buildFeedBody(context),
            ExploreScreen(
              onSelectStartupsTab: () => _onTabSelected(2),
            ),
            const MyStartupsPage(),
            const MessagesPage(),
            _buildProfileTab(context),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildFeedBody(BuildContext context) {
    return BlocConsumer<FeedBloc, FeedState>(
      listener: (context, state) {
        if (state is FeedLoadedState && state.actionFeedbackMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionFeedbackMessage!),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is FeedLoadingState) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryPurple),
          );
        }

        if (state is FeedErrorState) {
          return _buildErrorState(context, state.errorMessage);
        }

        if (state is FeedEmptyState) {
          return _buildEmptyState(context, state);
        }

        if (state is FeedLoadedState) {
          return _buildFeedContent(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFeedContent(BuildContext context, FeedLoadedState state) {
    return RefreshIndicator(
      color: AppColors.primaryPurple,
      onRefresh: () async {
        context.read<FeedBloc>().add(
              LoadFeedEvent(
                selectedTag: state.selectedTag,
                isRefresh: true,
              ),
            );
      },
      child: CustomScrollView(
        slivers: [
          // Stories Tray
          SliverToBoxAdapter(
            child: StoriesTray(stories: state.stories),
          ),
          const SliverToBoxAdapter(
            child: Divider(color: Color(0xFFF1F5F9), height: 1),
          ),
          // "Share a startup update..." quick box
          const SliverToBoxAdapter(
            child: QuickCreateBox(),
          ),
          const SliverToBoxAdapter(
            child: Divider(color: Color(0xFFF1F5F9), height: 1),
          ),
          // Trending tags row
          SliverToBoxAdapter(
            child: TrendingTagsBar(selectedTag: state.selectedTag),
          ),
          // Matches banner
          const SliverToBoxAdapter(
            child: InvestorMatchesBanner(),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 4),
          ),
          // Posts list with Recommended Investors injected dynamically
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Insert Recommended Investors card after post index 1
                if (index == 2 && state.recommendedInvestors.isNotEmpty) {
                  return RecommendedInvestorsCard(
                    investors: state.recommendedInvestors,
                  );
                }

                // Adjust index if we passed the recommended investors card
                final postIndex =
                    (index > 2 && state.recommendedInvestors.isNotEmpty)
                        ? index - 1
                        : index;

                if (postIndex >= state.posts.length) return null;

                final post = state.posts[postIndex];
                return PostCard(
                  post: post,
                  onLike: () {
                    context.read<FeedBloc>().add(ToggleLikeEvent(post.id));
                  },
                  onBookmark: () {
                    context.read<FeedBloc>().add(ToggleBookmarkEvent(post.id));
                  },
                  onVote: (optionId) {
                    context.read<FeedBloc>().add(
                          VotePollEvent(
                            postId: post.id,
                            pollOptionId: optionId,
                          ),
                        );
                  },
                );
              },
              childCount: state.posts.length +
                  (state.recommendedInvestors.isNotEmpty &&
                          state.posts.length >= 2
                      ? 1
                      : 0),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, FeedEmptyState state) {
    return Column(
      children: [
        if (state.stories.isNotEmpty) StoriesTray(stories: state.stories),
        const QuickCreateBox(),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.purpleLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.feed_outlined,
                      size: 36,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No posts found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      context
                          .read<FeedBloc>()
                          .add(const SelectTagEvent('All'));
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Show All Posts'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            const Text(
              'Oops! Could not load feed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<FeedBloc>().add(const LoadFeedEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: AppColors.white,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    final user = context.select<AuthBloc, AuthUser?>((b) => b.state.user);
    final isInvestor = user?.role == UserRole.investor;
    final roleName = isInvestor ? 'Investor' : 'Entrepreneur';
    final name = (user != null && user.displayName.trim().isNotEmpty)
        ? user.displayName.trim()
        : (isInvestor ? 'Investor Member' : 'Startup Founder');
    final email = (user != null && user.email.trim().isNotEmpty)
        ? user.email.trim()
        : 'member@fikraty.com';
    final phone = user?.phone ?? '01012345678';
    final location = user?.profile.location ?? 'Cairo, Egypt';
    final title = user?.profile.professionalTitle;
    final company = user?.startup?.name;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Profile & Features Hub',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded, color: AppColors.ink),
            onPressed: () => _confirmSignOut(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.white.withValues(alpha: 0.2),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'F',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFE0E7FF),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            roleName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Profile info details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.phone_outlined, 'Phone', phone),
                  const Divider(color: Color(0xFFF1F5F9), height: 16),
                  _buildDetailRow(Icons.location_on_outlined, 'Location', location),
                  if (title != null) ...[
                    const Divider(color: Color(0xFFF1F5F9), height: 16),
                    _buildDetailRow(
                      Icons.work_outline_rounded,
                      'Title',
                      title,
                    ),
                  ],
                  if (company != null) ...[
                    const Divider(color: Color(0xFFF1F5F9), height: 16),
                    _buildDetailRow(
                      Icons.business_outlined,
                      'Company',
                      company,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Feature Testing Hub Section Header
            const Row(
              children: [
                Icon(Icons.hub_rounded, color: AppColors.primaryPurple, size: 20),
                SizedBox(width: 8),
                Text(
                  'Feature Testing & Quick Navigation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action Cards
            _buildFeatureActionCard(
              icon: Icons.rocket_launch_rounded,
              color: const Color(0xFF4F46E5),
              title: 'Startups Feature (My Startups)',
              subtitle: 'View startup profile, tabs (Posts, Startup, Analytics), and pitch deck',
              buttonLabel: 'Go to Startups Tab',
              onPressed: () => _onTabSelected(2),
            ),
            const SizedBox(height: 10),

            _buildFeatureActionCard(
              icon: Icons.add_circle_outline_rounded,
              color: const Color(0xFF059669),
              title: 'Startup Creation Wizard',
              subtitle: 'Interactive 4-step wizard to create or update a startup profile',
              buttonLabel: 'Launch Wizard',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StartupWizardPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            _buildFeatureActionCard(
              icon: Icons.verified_user_outlined,
              color: const Color(0xFFD97706),
              title: 'Submit Legal Verification',
              subtitle: 'Upload official Commercial Register or Tax ID for official badge',
              buttonLabel: 'Open Verification',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubmitVerificationPage(
                      startup: StartupEntity(
                        id: 'demo-startup-1',
                        ownerUserId: user?.id ?? 'user-1',
                        name: company ?? 'FikraPay Tech',
                        tagline: 'Empowering digital venture matchmaking in MENA',
                        description: 'AI-driven financial management and instant payment rails for MENA SMEs.',
                        problem: 'SMEs face payment delays and working capital bottlenecks.',
                        solution: 'Instant payments and automated factoring.',
                        businessModel: 'Subscription + 0.5% per settlement.',
                        targetMarket: '3.8M SMEs in Egypt and Saudi Arabia.',
                        industryName: 'FinTech',
                        stageName: 'Seed',
                        cityName: 'Cairo',
                        websiteUrl: 'https://fikraty.com',
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            _buildFeatureActionCard(
              icon: Icons.dynamic_feed_rounded,
              color: const Color(0xFF8B5CF6),
              title: 'Home & Community Feed',
              subtitle: 'Stories, live polls, updates, and recommended investor matches',
              buttonLabel: 'Go to Feed',
              onPressed: () => _onTabSelected(0),
            ),
            const SizedBox(height: 10),

            _buildFeatureActionCard(
              icon: Icons.chat_bubble_outline_rounded,
              color: const Color(0xFF0284C7),
              title: 'Direct Messages & Chat',
              subtitle: 'In-app real-time messaging, attachments, and audio voice notes',
              buttonLabel: 'Open Messages',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MessagesPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            _buildFeatureActionCard(
              icon: Icons.notifications_none_rounded,
              color: const Color(0xFFE11D48),
              title: 'Notifications Center',
              subtitle: 'Activity notifications, investor interest, and comment alerts',
              buttonLabel: 'Open Notifications',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Auth Reset / Restart Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.restart_alt_rounded, color: Color(0xFFB45309)),
                      SizedBox(width: 8),
                      Text(
                        'Test Splash & Onboarding Again',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Clear onboarding preferences to experience the full introductory flow from the beginning.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF78350F)),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('onboarding_completed');
                      } catch (_) {}
                      if (!context.mounted) return;
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.splash,
                        (_) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Restart from Splash Screen'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sign Out Button
            OutlinedButton.icon(
              onPressed: () => _confirmSignOut(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: Color(0xFFFECACA), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text(
                'Sign Out & Test Sign In / Sign Up Forms',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureActionCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              buttonLabel,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out from Fikraty?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.explore_outlined, 'Explore'),
              _buildNavItem(2, Icons.rocket_launch_rounded, 'Startups'),
              _buildNavItem(3, Icons.chat_bubble_outline_rounded, 'Messages'),
              _buildNavItem(4, Icons.person_outline_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
  ) {
    final active = _selectedBottomNavIndex == index;
    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: active ? AppColors.primaryPurple : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color:
                    active ? AppColors.primaryPurple : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? AppColors.primaryPurple : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
