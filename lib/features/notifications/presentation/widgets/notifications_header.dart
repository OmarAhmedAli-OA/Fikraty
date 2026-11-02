import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationsHeaderWidget extends StatelessWidget {
  final String title;

  const NotificationsHeaderWidget({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
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
}
