import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/startups.dart';
import 'custom_startup_image.dart';

class StartupHeaderCard extends StatelessWidget {
  const StartupHeaderCard({
    super.key,
    required this.startup,
    required this.onEditPressed,
    required this.onVerifyPressed,
  });

  final StartupEntity startup;
  final VoidCallback onEditPressed;
  final VoidCallback onVerifyPressed;

  Color _getVerificationColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'pending':
      case 'under_review':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }

  String _getVerificationText(String status) {
    switch (status) {
      case 'approved':
        return 'Verified Startup';
      case 'pending':
      case 'under_review':
        return 'Verification Under Review';
      case 'rejected':
        return 'Verification Rejected';
      default:
        return 'Not Verified Yet';
    }
  }

  IconData _getVerificationIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.verified_rounded;
      case 'pending':
      case 'under_review':
        return Icons.hourglass_top_rounded;
      case 'rejected':
        return Icons.error_outline_rounded;
      default:
        return Icons.shield_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getVerificationColor(startup.verificationStatus);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppColors.tint),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (startup.coverImageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CustomStartupImage(
                imagePath: startup.coverImageUrl!,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 14),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: AppColors.tint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.blue.withValues(alpha: 0.2),
                  ),
                ),
                child: startup.logoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CustomStartupImage(
                          imagePath: startup.logoUrl!,
                          fit: BoxFit.cover,
                          placeholder: const Icon(
                            Icons.business_center_rounded,
                            size: 34,
                            color: AppColors.navy,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.business_center_rounded,
                        size: 34,
                        color: AppColors.navy,
                      ),
              ),
              const SizedBox(width: 16),
              // Name & Tagline
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      startup.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      startup.tagline,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.tint),
          const SizedBox(height: 14),

          // Metadata Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetaChip(
                icon: Icons.category_outlined,
                label: startup.industryName,
              ),
              _buildMetaChip(
                icon: Icons.location_on_outlined,
                label: startup.cityName,
              ),
              _buildMetaChip(
                icon: Icons.timeline_rounded,
                label: startup.stageName,
              ),
              _buildMetaChip(
                icon: Icons.calendar_today_outlined,
                label: 'Founded ${startup.foundedYear}',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Profile completion progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile Completion',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    '${startup.profileCompletion}%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: startup.profileCompletion / 100,
                  backgroundColor: AppColors.tint,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.blue,
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Verification Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  _getVerificationIcon(startup.verificationStatus),
                  color: statusColor,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _getVerificationText(startup.verificationStatus),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                if (startup.verificationStatus == 'unverified')
                  TextButton.icon(
                    onPressed: onVerifyPressed,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text(
                      'Verify Now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action button
          OutlinedButton.icon(
            onPressed: onEditPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.navy,
              side: const BorderSide(color: AppColors.navy, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.edit_note_rounded),
            label: const Text(
              'Edit Startup Profile in Wizard',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.tint),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.blue),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.ink,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
