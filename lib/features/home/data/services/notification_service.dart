import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum NotificationTargetType {
  post,
  startup,
  investor,
  founder,
  campaign,
  chat,
}

class AppNotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final String timeAgo;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool isUnread;
  final NotificationTargetType targetType;
  final int targetId;
  final String? chatUserName;
  final String? chatUserAvatar;
  final String group; // 'TODAY', 'YESTERDAY', 'THIS WEEK'

  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.isUnread = false,
    required this.targetType,
    this.targetId = 0,
    this.chatUserName,
    this.chatUserAvatar,
    required this.group,
  });

  AppNotificationItem copyWith({bool? isUnread}) {
    return AppNotificationItem(
      id: id,
      title: title,
      subtitle: subtitle,
      timeAgo: timeAgo,
      icon: icon,
      iconBg: iconBg,
      iconColor: iconColor,
      isUnread: isUnread ?? this.isUnread,
      targetType: targetType,
      targetId: targetId,
      chatUserName: chatUserName,
      chatUserAvatar: chatUserAvatar,
      group: group,
    );
  }
}

class NotificationService extends ChangeNotifier {
  NotificationService._() {
    _initNotifications();
  }

  static final NotificationService instance = NotificationService._();

  final List<AppNotificationItem> _notifications = [];

  List<AppNotificationItem> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => n.isUnread).length;

  bool get hasUnread => unreadCount > 0;

  void _initNotifications() {
    _notifications.clear();
    _notifications.addAll([
      // TODAY
      const AppNotificationItem(
        id: 'notif_1',
        title: 'Omar Khalil expressed interest in NovaMed AI',
        subtitle: 'Deal potential: \$500K · Wamda Capital',
        timeAgo: '2h ago',
        icon: Icons.monetization_on_rounded,
        iconBg: AppColors.warningLight,
        iconColor: AppColors.warning,
        isUnread: true,
        targetType: NotificationTargetType.startup,
        targetId: 1, // NovaMed AI
        group: 'TODAY',
      ),
      const AppNotificationItem(
        id: 'notif_2',
        title: 'Sarah and 47 others liked your post',
        subtitle: '"Excited to launch our journey on Fikraty!..."',
        timeAgo: '3h ago',
        icon: Icons.favorite_rounded,
        iconBg: AppColors.roseBg,
        iconColor: AppColors.roseText,
        isUnread: true,
        targetType: NotificationTargetType.post,
        targetId: 9991, // User's own Post
        group: 'TODAY',
      ),
      const AppNotificationItem(
        id: 'notif_3',
        title: 'Ingrid Larsen commented on your post',
        subtitle: '"Congratulations! Would love to connect."',
        timeAgo: '5h ago',
        icon: Icons.chat_bubble_rounded,
        iconBg: AppColors.primaryTint,
        iconColor: AppColors.violetText,
        isUnread: true,
        targetType: NotificationTargetType.post,
        targetId: 9991, // User's own Post
        group: 'TODAY',
      ),
      const AppNotificationItem(
        id: 'notif_4',
        title: 'New message from Omar Khalil',
        subtitle: '"Hello, I checked your pitch deck and would love to connect."',
        timeAgo: '6h ago',
        icon: Icons.chat_outlined,
        iconBg: AppColors.selectionTint,
        iconColor: AppColors.primary,
        isUnread: false,
        targetType: NotificationTargetType.chat,
        chatUserName: 'Omar Khalil',
        chatUserAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        group: 'TODAY',
      ),

      // YESTERDAY
      const AppNotificationItem(
        id: 'notif_5',
        title: 'Sarah Al-Mansouri followed you',
        subtitle: 'Founder & CEO at NovaMed AI',
        timeAgo: '1d ago',
        icon: Icons.person_add_rounded,
        iconBg: AppColors.purpleLight,
        iconColor: AppColors.primaryPurple,
        isUnread: false,
        targetType: NotificationTargetType.founder,
        targetId: 1, // Sarah Al-Mansouri
        group: 'YESTERDAY',
      ),
      const AppNotificationItem(
        id: 'notif_6',
        title: 'Tariq Hassan followed you',
        subtitle: 'Angel Investor · 12 portfolio companies',
        timeAgo: '1d ago',
        icon: Icons.group_rounded,
        iconBg: AppColors.secondarySoft,
        iconColor: AppColors.secondary,
        isUnread: false,
        targetType: NotificationTargetType.investor,
        targetId: 3, // Tariq Hassan
        group: 'YESTERDAY',
      ),

      // THIS WEEK
      const AppNotificationItem(
        id: 'notif_7',
        title: 'New investor interest in FlowSync campaign',
        subtitle: 'Target: \$1.2M · 82% funded',
        timeAgo: '3d ago',
        icon: Icons.trending_up_rounded,
        iconBg: AppColors.emeraldBg,
        iconColor: AppColors.emeraldText,
        isUnread: false,
        targetType: NotificationTargetType.campaign,
        targetId: 3, // FlowSync campaign
        group: 'THIS WEEK',
      ),
    ]);
  }

  void markAllAsRead() {
    bool hasChanged = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].isUnread) {
        _notifications[i] = _notifications[i].copyWith(isUnread: false);
        hasChanged = true;
      }
    }
    if (hasChanged) {
      notifyListeners();
    }
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && _notifications[index].isUnread) {
      _notifications[index] = _notifications[index].copyWith(isUnread: false);
      notifyListeners();
    }
  }
}
