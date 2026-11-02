import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/notification_item.dart';

class NotificationsItemWidget extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const NotificationsItemWidget({
    super.key,
    required this.item,
    required this.onTap,
  });

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
    return InkWell(
      onTap: onTap,
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
