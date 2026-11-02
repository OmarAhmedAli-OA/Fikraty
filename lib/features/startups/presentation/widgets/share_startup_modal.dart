import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/startups.dart';

class ShareStartupModal extends StatefulWidget {
  final StartupEntity? startup;

  const ShareStartupModal({super.key, this.startup});

  static Future<void> show(BuildContext context, StartupEntity? startup) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareStartupModal(startup: startup),
    );
  }

  @override
  State<ShareStartupModal> createState() => _ShareStartupModalState();
}

class _ShareStartupModalState extends State<ShareStartupModal> {
  bool _copied = false;

  String get _startupUrl =>
      'https://fikraty.app/startups/${widget.startup?.id ?? "venture-profile"}';

  void _copyLink([String? platform]) {
    final shareText = widget.startup != null
        ? '${widget.startup!.name} - ${widget.startup!.tagline}\n$_startupUrl'
        : 'Explore startup investment profiles on Fikraty!\n$_startupUrl';

    Clipboard.setData(ClipboardData(text: shareText));
    setState(() {
      _copied = true;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.slateNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 20),
            const SizedBox(width: 10),
            Text(
              platform != null
                  ? 'Shared via $platform! Link copied.'
                  : 'Profile link copied to clipboard!',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startup = widget.startup;
    final name = startup?.name ?? 'My Startup Profile';
    final tagline = startup?.tagline ?? 'Pioneering innovative digital solutions in MENA';
    final industry = startup?.industryName ?? 'Technology';
    final stage = startup?.stageName ?? 'Seed';
    final location = startup?.cityName ?? 'Cairo, Egypt';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Gray Drag Handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.borderSlate,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header: Title + Close Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Share Startup Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Startup Mini Preview Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.grayBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.purpleGlow, AppColors.primaryPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'S',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified_rounded,
                              color: AppColors.success,
                              size: 16,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tagline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.purpleLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                industry,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.emeraldBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                stage,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.emeraldText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              location,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Section Label
            const Text(
              'Share via',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Social platforms row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSocialItem(
                  icon: Icons.chat_rounded,
                  label: 'WhatsApp',
                  color: AppColors.whatsAppGreen,
                  onTap: () => _copyLink('WhatsApp'),
                ),
                _buildSocialItem(
                  icon: Icons.business_center_rounded,
                  label: 'LinkedIn',
                  color: AppColors.linkedInBlue,
                  onTap: () => _copyLink('LinkedIn'),
                ),
                _buildSocialItem(
                  icon: Icons.tag_rounded,
                  label: 'X (Twitter)',
                  color: AppColors.slateBlack,
                  onTap: () => _copyLink('X'),
                ),
                _buildSocialItem(
                  icon: Icons.send_rounded,
                  label: 'Telegram',
                  color: AppColors.telegramBlue,
                  onTap: () => _copyLink('Telegram'),
                ),
                _buildSocialItem(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  color: AppColors.textMuted,
                  onTap: () => _copyLink('Email'),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Copy Link Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _copied ? AppColors.success : AppColors.borderLight,
                  width: _copied ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded, color: AppColors.textMuted, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _startupUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _copyLink(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _copied ? AppColors.success : AppColors.primaryPurple,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _copied ? 'Copied!' : 'Copy',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
