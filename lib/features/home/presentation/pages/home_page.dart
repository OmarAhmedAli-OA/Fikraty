import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../profile/presentation/pages/profile_page.dart';
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
              onSelectStartupsTab: () => _onTabSelected(3),
            ),
            const MessagesPage(),
            const ProfilePage(),
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
              _buildNavItem(2, Icons.chat_bubble_outline_rounded, 'Messages'),
              _buildNavItem(3, Icons.person_outline_rounded, 'Profile'),
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
