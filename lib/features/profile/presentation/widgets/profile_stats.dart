import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_profile.dart';

class ProfileStats extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback? onInterestsTap;

  const ProfileStats({
    super.key,
    required this.profile,
    this.onInterestsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEntrepreneur = profile.role == UserRole.entrepreneur;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: isEntrepreneur
                ? [
                    _StatItem(
                      value: '${(profile.followersCount / 1000).toStringAsFixed(1)}K',
                      label: 'Followers',
                    ),
                    _StatItem(
                      value: '${profile.followingCount}',
                      label: 'Following',
                    ),
                    _StatItem(
                      value: '${profile.investorInterestCount}',
                      label: 'Investors interested',
                      onTap: onInterestsTap,
                      isHighlighted: true,
                    ),
                  ]
                : [
                    _StatItem(
                      value: '${profile.portfolioCount}',
                      label: 'Portfolio cos.',
                    ),
                    _StatItem(
                      value: profile.totalDeployed.isNotEmpty
                          ? profile.totalDeployed
                          : '\$28M',
                      label: 'Total deployed',
                    ),
                    _StatItem(
                      value: '${(profile.followersCount / 1000).toStringAsFixed(1)}K',
                      label: 'Followers',
                    ),
                  ],
          ),

          if (profile.investorInterestCount > 0) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: onInterestsTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isEntrepreneur
                            ? '${profile.investorInterestCount} investors interested in your startup'
                            : '${profile.investorInterestCount} founder proposals received',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.successDark,
                        ),
                      ),
                    ),
                    const Text(
                      'View →',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.successDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback? onTap;
  final bool isHighlighted;

  const _StatItem({
    required this.value,
    required this.label,
    this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlighted
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.cardBorder,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isHighlighted ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(14),
                child: content,
              )
            : content,
      ),
    );
  }
}
