import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationsCardWidget extends StatelessWidget {
  final Widget child;

  const NotificationsCardWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}
