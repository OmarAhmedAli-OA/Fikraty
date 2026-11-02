import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../chat/presentation/pages/chat_detail_page.dart';
import '../../../explore/data/datasources/explore_local_data_source.dart';
import '../../../explore/presentation/bloc/explore_bloc.dart';
import '../../../explore/presentation/bloc/explore_state.dart';
import '../../../explore/presentation/pages/campaign_detail_page.dart';
import '../../../explore/presentation/pages/founder_detail_page.dart';
import '../../../explore/presentation/pages/investor_detail_page.dart';
import '../../../explore/presentation/pages/startup_detail_page.dart';
import '../../../home/domain/entities/post.dart';
import '../../../home/presentation/bloc/feed_bloc.dart';
import '../../../home/presentation/bloc/feed_state.dart';
import '../../../home/presentation/pages/post_detail_page.dart';
import '../../domain/entities/notification_item.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // Once the user visits notifications, synchronize and mark them as read
    // so the red badge on the home feed is cleared.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<NotificationsBloc>()
          .add(const MarkAllNotificationsAsReadEvent());
    });
  }

  Future<void> _handleNotificationTap(NotificationItem item) async {
    context
        .read<NotificationsBloc>()
        .add(MarkNotificationAsReadEvent(item.id));

    if (!mounted) return;

    switch (item.targetType) {
      case NotificationTargetType.post:
        Post? targetPost;
        final feedState = context.read<FeedBloc>().state;
        if (feedState is FeedLoadedState) {
          targetPost = feedState.posts.cast<Post?>().firstWhere(
                (p) => p?.id == item.targetId,
                orElse: () => null,
              );
        }
        targetPost ??= Post(
          id: item.targetId,
          authorUserId: 999,
          authorName: 'You (Founder)',
          authorRole: 'Founder @ Fikraty Startup',
          authorAvatar:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
          isVerified: true,
          postType: PostType.launch,
          content:
              'Excited to launch our journey on Fikraty! We are building the next-gen platform for tech startups in the MENA region. Stay tuned for our upcoming investor pitch deck! 🚀',
          tags: const ['#Startup', '#Launch', '#Tech', '#MVP'],
          likeCount: 48,
          commentCount: 5,
          shareCount: 2,
          isLiked: false,
          isBookmarked: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          comments: const [],
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailPage(post: targetPost!),
          ),
        );
        break;

      case NotificationTargetType.startup:
        final exploreState = context.read<ExploreBloc>().state;
        if (exploreState is ExploreLoadedState) {
          final startup = exploreState.startups.firstWhere(
            (s) => s.id == item.targetId,
            orElse: () => exploreState.startups.first,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StartupDetailPage(startup: startup),
            ),
          );
        } else {
          final ds = sl<ExploreLocalDataSource>();
          final startups = await ds.getStartups();
          if (!mounted) return;
          final startup = startups.firstWhere(
            (s) => s.id == item.targetId,
            orElse: () => startups.first,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StartupDetailPage(startup: startup),
            ),
          );
        }
        break;

      case NotificationTargetType.founder:
        final exploreState = context.read<ExploreBloc>().state;
        if (exploreState is ExploreLoadedState) {
          final founder = exploreState.founders.firstWhere(
            (f) => f.id == item.targetId,
            orElse: () => exploreState.founders.first,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FounderDetailPage(founder: founder),
            ),
          );
        } else {
          final ds = sl<ExploreLocalDataSource>();
          final founders = await ds.getFounders();
          if (!mounted) return;
          final founder = founders.firstWhere(
            (f) => f.id == item.targetId,
            orElse: () => founders.first,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FounderDetailPage(founder: founder),
            ),
          );
        }
        break;

      case NotificationTargetType.investor:
        final exploreState = context.read<ExploreBloc>().state;
        if (exploreState is ExploreLoadedState) {
          final investor = exploreState.investors.firstWhere(
            (inv) => inv.id == item.targetId,
            orElse: () => exploreState.investors.first,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvestorDetailPage(investor: investor),
            ),
          );
        } else {
          final ds = sl<ExploreLocalDataSource>();
          final investors = await ds.getInvestors();
          if (!mounted) return;
          final investor = investors.firstWhere(
            (inv) => inv.id == item.targetId,
            orElse: () => investors.first,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvestorDetailPage(investor: investor),
            ),
          );
        }
        break;

      case NotificationTargetType.campaign:
        final exploreState = context.read<ExploreBloc>().state;
        if (exploreState is ExploreLoadedState) {
          final campaign = exploreState.campaigns.firstWhere(
            (c) => c.id == item.targetId,
            orElse: () => exploreState.campaigns.first,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CampaignDetailPage(campaign: campaign),
            ),
          );
        } else {
          final ds = sl<ExploreLocalDataSource>();
          final campaigns = await ds.getCampaigns();
          if (!mounted) return;
          final campaign = campaigns.firstWhere(
            (c) => c.id == item.targetId,
            orElse: () => campaigns.first,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CampaignDetailPage(campaign: campaign),
            ),
          );
        }
        break;

      case NotificationTargetType.chat:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailPage(
              userName: item.chatUserName ?? 'Omar Khalil',
              userAvatar: item.chatUserAvatar ??
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
              isOnline: true,
            ),
          ),
        );
        break;
    }
  }

  IconData _getIconForTarget(NotificationTargetType type) {
    switch (type) {
      case NotificationTargetType.founder:
        return Icons.person_add_outlined;
      case NotificationTargetType.investor:
        return Icons.trending_up_rounded;
      case NotificationTargetType.startup:
        return Icons.rocket_launch_outlined;
      case NotificationTargetType.campaign:
        return Icons.campaign_outlined;
      case NotificationTargetType.post:
        return Icons.chat_bubble_outline_rounded;
      case NotificationTargetType.chat:
        return Icons.mail_outline_rounded;
    }
  }

  Color _getIconBgForTarget(NotificationTargetType type) {
    switch (type) {
      case NotificationTargetType.founder:
        return AppColors.lightIndigoBg;
      case NotificationTargetType.investor:
        return AppColors.emeraldBg;
      case NotificationTargetType.startup:
        return AppColors.purpleLight;
      case NotificationTargetType.campaign:
        return AppColors.orangeLightBg;
      case NotificationTargetType.post:
        return AppColors.softBlueBg;
      case NotificationTargetType.chat:
        return AppColors.lightIndigoBg;
    }
  }

  Color _getIconColorForTarget(NotificationTargetType type) {
    switch (type) {
      case NotificationTargetType.founder:
        return AppColors.indigoText;
      case NotificationTargetType.investor:
        return AppColors.emeraldText;
      case NotificationTargetType.startup:
        return AppColors.primaryPurple;
      case NotificationTargetType.campaign:
        return AppColors.orangeDark;
      case NotificationTargetType.post:
        return AppColors.bluePrimary;
      case NotificationTargetType.chat:
        return AppColors.indigoText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        final notifications = (state is NotificationsLoaded)
            ? state.notifications
            : const <NotificationItem>[];
        final unreadCount =
            (state is NotificationsLoaded) ? state.unreadCount : 0;

        final todayNotifications =
            notifications.where((n) => n.group == 'TODAY').toList();
        final yesterdayNotifications =
            notifications.where((n) => n.group == 'YESTERDAY').toList();
        final thisWeekNotifications =
            notifications.where((n) => n.group == 'THIS WEEK').toList();

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.ink),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.purpleLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unreadCount new',
                      style: const TextStyle(
                        color: AppColors.primaryPurple,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              if (unreadCount > 0)
                TextButton(
                  onPressed: () {
                    context
                        .read<NotificationsBloc>()
                        .add(const MarkAllNotificationsAsReadEvent());
                  },
                  child: const Text(
                    'Mark all as read',
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context
                  .read<NotificationsBloc>()
                  .add(const LoadNotificationsEvent());
            },
            color: AppColors.primaryPurple,
            child: notifications.isEmpty
                ? const Center(
                    child: Text(
                      'No notifications yet',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 15,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    children: [
                      if (todayNotifications.isNotEmpty) ...[
                        _buildSectionHeader('TODAY'),
                        ...todayNotifications
                            .map((n) => _buildNotificationTile(n)),
                        const SizedBox(height: 16),
                      ],
                      if (yesterdayNotifications.isNotEmpty) ...[
                        _buildSectionHeader('YESTERDAY'),
                        ...yesterdayNotifications
                            .map((n) => _buildNotificationTile(n)),
                        const SizedBox(height: 16),
                      ],
                      if (thisWeekNotifications.isNotEmpty) ...[
                        _buildSectionHeader('THIS WEEK'),
                        ...thisWeekNotifications
                            .map((n) => _buildNotificationTile(n)),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildNotificationTile(NotificationItem item) {
    return InkWell(
      onTap: () => _handleNotificationTap(item),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getIconBgForTarget(item.targetType),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForTarget(item.targetType),
                color: _getIconColorForTarget(item.targetType),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.timeAgo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                if (item.isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
