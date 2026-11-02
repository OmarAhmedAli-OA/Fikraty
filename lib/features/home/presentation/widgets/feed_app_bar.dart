import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../auth/domain/entities/auth.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../chat/presentation/pages/messages_page.dart';
import '../../../notifications/presentation/bloc/notifications_bloc.dart';
import '../../../notifications/presentation/bloc/notifications_state.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';

class FeedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FeedAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

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

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, AuthUser?>((b) => b.state.user);
    final isInvestor = user?.role == UserRole.investor;
    final roleLabel = isInvestor ? 'Investor' : 'Entrepreneur';

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Brand Logo matching splash & auth
            const AppLogo(size: 32),
            const SizedBox(width: 8),
            // Title
            const Text(
              'Fikraty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 6),
            // Dynamic Role Pill Badge
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: isInvestor ? AppColors.lightIndigoBg : AppColors.purpleLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  roleLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isInvestor ? AppColors.indigoText : AppColors.primaryPurple,
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Notification Bell with badge synced to NotificationsBloc
            BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (context, notifState) {
                final hasUnread = (notifState is NotificationsLoaded) && notifState.hasUnread;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsPage(),
                          ),
                        );
                      },
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.ink,
                        size: 22,
                      ),
                      tooltip: 'Notifications',
                    ),
                    if (hasUnread)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            // Chat/Messages bubble
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MessagesPage(),
                  ),
                );
              },
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.ink,
                size: 21,
              ),
              tooltip: 'Messages',
            ),
            // Quick Sign Out action
            IconButton(
              onPressed: () => _confirmSignOut(context),
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: const Icon(
                Icons.logout_rounded,
                color: AppColors.textMuted,
                size: 21,
              ),
              tooltip: 'Sign Out',
            ),
          ],
        ),
      ),
    );
  }
}
