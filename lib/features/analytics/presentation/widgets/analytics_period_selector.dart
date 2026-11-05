import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AnalyticsPeriodSelectorWidget extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const AnalyticsPeriodSelectorWidget({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.subtleGrayBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderCool),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['7D', '30D', '90D'].map((period) {
          final isSelected = selectedPeriod == period;
          return InkWell(
            onTap: () => onPeriodChanged(period),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                period,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.white : AppColors.slateMuted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
