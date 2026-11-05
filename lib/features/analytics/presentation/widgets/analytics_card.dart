import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AnalyticsCardWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AnalyticsCardWidget({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }
}
