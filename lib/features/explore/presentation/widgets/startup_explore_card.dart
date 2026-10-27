import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/explore_startup.dart';

class StartupExploreCard extends StatelessWidget {
  const StartupExploreCard({
    super.key,
    required this.startup,
    required this.onToggleSave,
    required this.onTapDetail,
  });

  final ExploreStartup startup;
  final VoidCallback onToggleSave;
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
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Initials avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(startup.colorHex),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    startup.initials,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            startup.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (startup.isVerified) ...[
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
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          startup.industry,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.tertiaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            '·',
                            style: TextStyle(
                              color: AppColors.tertiaryText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppColors.tertiaryText,
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            startup.location,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.tertiaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Save button
              IconButton(
                onPressed: onToggleSave,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  startup.isSaved ? Icons.bookmark : Icons.bookmark_border_rounded,
                  color: startup.isSaved ? AppColors.primary : const Color(0xFFC0C0D0),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tagline
          Text(
            startup.tagline,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF5F5F72),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),

          // Metric tags
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildTag(startup.stage),
              _buildTag('Target: \$${(startup.targetAmount / 1000000).toStringAsFixed(1)}M'),
              if (startup.isFunded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6FBF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Funded ✓',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Bottom match and CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Match progress
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (startup.matchScore / 100).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${startup.matchScore}% match',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              // View Profile CTA
              ElevatedButton(
                onPressed: onTapDetail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.selectionTint,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'View Profile',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFF5F5F72),
        ),
      ),
    );
  }
}
