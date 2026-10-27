import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/explore_founder.dart';

class FounderExploreCard extends StatelessWidget {
  const FounderExploreCard({
    super.key,
    required this.founder,
    required this.onToggleSave,
    this.onExpressInterest,
    required this.onTapDetail,
  });

  final ExploreFounder founder;
  final VoidCallback onToggleSave;
  final VoidCallback? onExpressInterest;
  final VoidCallback onTapDetail;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          GestureDetector(
            onTap: onTapDetail,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.background,
                  backgroundImage: NetworkImage(founder.avatarUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              founder.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (founder.isVerified) ...[
                            const SizedBox(width: 5),
                            Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 10,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${founder.role} · ${founder.startupName}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.tertiaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 11,
                            color: AppColors.tertiaryText,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            founder.location,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.tertiaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${founder.followers} followers',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tertiaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Bio
          Text(
            founder.bio,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF5F5F72),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),

          // Skills pills
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: founder.skills.take(4).map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  s,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF5F5F72),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Action row: Only "View Profile" + Bookmark
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onTapDetail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  child: const Text(
                    'View Profile',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onToggleSave,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: founder.isSaved
                        ? AppColors.primary
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: founder.isSaved
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Icon(
                    founder.isSaved ? Icons.bookmark : Icons.bookmark_border_rounded,
                    size: 18,
                    color: founder.isSaved ? AppColors.white : AppColors.tertiaryText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
