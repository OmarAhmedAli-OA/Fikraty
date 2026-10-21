import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../auth/domain/entities/auth.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../pages/messages_page.dart';
import '../pages/notifications_page.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Brand Logo matching splash & auth
            const AppLogo(size: 36),
            const SizedBox(width: 10),
            // Title
            const Text(
              'Fikraty',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 8),
            // Dynamic Role Pill Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isInvestor ? const Color(0xFFE0E7FF) : AppColors.purpleLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                roleLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isInvestor ? const Color(0xFF4338CA) : AppColors.primaryPurple,
                ),
              ),
            ),
            const Spacer(),
            // Notification Bell with badge
            Stack(
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
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.ink,
                    size: 24,
                  ),
                  tooltip: 'Notifications',
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF43F5E), // Pink/Red badge
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
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
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.ink,
                size: 22,
              ),
              tooltip: 'Messages',
            ),
            // Quick Sign Out action
            IconButton(
              onPressed: () => _confirmSignOut(context),
              icon: const Icon(
                Icons.logout_rounded,
                color: AppColors.textMuted,
                size: 22,
              ),
              tooltip: 'Sign Out',
            ),
          ],
        ),
      ),
    );
  }
}
