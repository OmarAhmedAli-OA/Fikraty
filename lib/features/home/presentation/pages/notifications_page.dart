import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationItem {
  final String title;
  final String subtitle;
  final String timeAgo;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool isUnread;

  const NotificationItem({
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.isUnread = false,
  });
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final todayNotifications = [
      const NotificationItem(
        title: 'Omar Khalil expressed interest in NovaMed AI',
        subtitle: 'Deal potential: \$500K · Wamda Capital',
        timeAgo: '2h ago',
        icon: Icons.monetization_on_rounded,
        iconBg: Color(0xFFFEF3C7),
        iconColor: Color(0xFFD97706),
        isUnread: true,
      ),
      const NotificationItem(
        title: 'Sarah and 47 others liked your post',
        subtitle: '"Thrilled to announce our Seed round..."',
        timeAgo: '3h ago',
        icon: Icons.favorite_rounded,
        iconBg: Color(0xFFFFE4E6),
        iconColor: Color(0xFFE11D48),
        isUnread: true,
      ),
      const NotificationItem(
        title: 'Ingrid Larsen commented on your post',
        subtitle: '"Congratulations! Would love to connect."',
        timeAgo: '5h ago',
        icon: Icons.chat_bubble_rounded,
        iconBg: Color(0xFFEDE9FE),
        iconColor: Color(0xFF7C3AED),
        isUnread: true,
      ),
      const NotificationItem(
        title: 'New match: Nordic Ventures',
        subtitle: '85% compatibility · CleanTech focus',
        timeAgo: '6h ago',
        icon: Icons.handshake_rounded,
        iconBg: Color(0xFFFEF9C3),
        iconColor: Color(0xFFCA8A04),
        isUnread: false,
      ),
    ];

    final yesterdayNotifications = [
      const NotificationItem(
        title: 'Meeting reminder: Omar Khalil (Wamda)',
        subtitle: 'Tomorrow at 3:00 PM · Video call',
        timeAgo: '1d ago',
        icon: Icons.calendar_month_rounded,
        iconBg: Color(0xFFE0E7FF),
        iconColor: Color(0xFF4F46E5),
      ),
      const NotificationItem(
        title: 'Due diligence update: NovaMed AI',
        subtitle: 'Financial statements approved',
        timeAgo: '1d ago',
        icon: Icons.check_box_rounded,
        iconBg: Color(0xFFDCFCE7),
        iconColor: Color(0xFF16A34A),
      ),
      const NotificationItem(
        title: 'Tariq Hassan followed you',
        subtitle: 'Angel Investor · 12 portfolio companies',
        timeAgo: '1d ago',
        icon: Icons.group_rounded,
        iconBg: Color(0xFFF3E8FF),
        iconColor: Color(0xFF9333EA),
      ),
    ];

    final thisWeekNotifications = [
      const NotificationItem(
        title: 'MENA Pitch Night registration opens',
        subtitle: 'Oct 14 · Dubai, UAE · 342 attending',
        timeAgo: '3d ago',
        icon: Icons.confirmation_number_rounded,
        iconBg: Color(0xFFFFE4E6),
        iconColor: Color(0xFFF43F5E),
      ),
    ];

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
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.purpleLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '3 new',
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildSectionHeader('TODAY'),
          ...todayNotifications.map((n) => _buildNotificationTile(n)),
          const SizedBox(height: 16),
          _buildSectionHeader('YESTERDAY'),
          ...yesterdayNotifications.map((n) => _buildNotificationTile(n)),
          const SizedBox(height: 16),
          _buildSectionHeader('THIS WEEK'),
          ...thisWeekNotifications.map((n) => _buildNotificationTile(n)),
          const SizedBox(height: 24),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              color: item.iconColor,
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
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4F46E5), // Blue/indigo unread dot
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
