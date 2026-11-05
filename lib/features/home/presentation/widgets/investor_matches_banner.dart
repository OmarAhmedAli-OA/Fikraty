import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class InvestorMatchesBanner extends StatelessWidget {
  final bool isInvestor;

  const InvestorMatchesBanner({
    super.key,
    this.isInvestor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.purpleGlow, // Indigo
            AppColors.primaryPurple, // Purple
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: AppColors.instagramYellow, // Gold lightning
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isInvestor ? '5 new founder matches' : '5 new investor matches',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isInvestor
                      ? 'Tap to see matching startups & founders'
                      : 'Tap to see your compatibility scores',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.lightIndigoBg,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isInvestor
                        ? 'Opening Founder Matching features...'
                        : 'Opening Investor Matching features...',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
