import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/post.dart';

class SharePostModal extends StatefulWidget {
  final Post post;

  const SharePostModal({super.key, required this.post});

  static Future<void> show(BuildContext context, Post post) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SharePostModal(post: post),
    );
  }

  @override
  State<SharePostModal> createState() => _SharePostModalState();
}

class _SharePostModalState extends State<SharePostModal> {
  bool _copied = false;

  String get _postUrl => 'https://fikraty.app/posts/${widget.post.id}';

  void _copyLink([String? platform]) {
    Clipboard.setData(ClipboardData(text: _postUrl));
    setState(() {
      _copied = true;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF10B981), size: 20),
            const SizedBox(width: 10),
            Text(
              platform != null
                  ? 'Shared via $platform! Link copied.'
                  : 'Link copied to clipboard!',
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
    final post = widget.post;

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
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header: Title + Close Icon
            Row(
              children: [
                const Text(
                  'Share Post',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF64748B),
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Post Preview Card (matching Figma / screenshot)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          post.authorAvatar,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.purpleLight,
                            child: Text(
                              post.authorName.isNotEmpty
                                  ? post.authorName[0]
                                  : 'U',
                              style: const TextStyle(
                                color: AppColors.primaryPurple,
                                fontWeight: FontWeight.bold,
                              ),
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
                                    post.authorName,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.ink,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDE9FE),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    post.postType.displayName,
                                    style: const TextStyle(
                                      color: Color(0xFF7C3AED),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${post.authorRole} · ${_formatTimeAgo(post.createdAt)}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (post.content.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      post.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF334155),
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Link Box with Chain Icon & "Copied" Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDE9FE)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.link_rounded,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _postUrl,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4F46E5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _copyLink(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: _copied ? 10 : 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _copied
                            ? const Color(0xFFDCFCE7)
                            : AppColors.primaryPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _copied
                              ? const Color(0xFF86EFAC)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_copied) ...[
                            const Icon(
                              Icons.check,
                              color: Color(0xFF16A34A),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            _copied ? 'Copied' : 'Copy',
                            style: TextStyle(
                              color: _copied
                                  ? const Color(0xFF16A34A)
                                  : AppColors.primaryPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // "Share via" section header
            const Text(
              'Share via',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 14),

            // Share via options row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildShareOption(
                  iconWidget: const Icon(
                    Icons.copy_rounded,
                    color: Color(0xFF6366F1),
                    size: 22,
                  ),
                  bgColor: const Color(0xFFEEF2FF),
                  label: 'Copy',
                  onTap: () => _copyLink('Link Copy'),
                ),
                _buildShareOption(
                  iconWidget: const Icon(
                    Icons.chat_bubble_rounded,
                    color: Color(0xFF22C55E),
                    size: 22,
                  ),
                  bgColor: const Color(0xFFDCFCE7),
                  label: 'WhatsApp',
                  onTap: () => _copyLink('WhatsApp'),
                ),
                _buildShareOption(
                  iconWidget: const Center(
                    child: Text(
                      '#',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  bgColor: const Color(0xFFF1F5F9),
                  label: 'X (Twitter)',
                  onTap: () => _copyLink('X (Twitter)'),
                ),
                _buildShareOption(
                  iconWidget: const Icon(
                    Icons.business_center_rounded,
                    color: Color(0xFF0284C7),
                    size: 22,
                  ),
                  bgColor: const Color(0xFFE0F2FE),
                  label: 'LinkedIn',
                  onTap: () => _copyLink('LinkedIn'),
                ),
                _buildShareOption(
                  iconWidget: const Icon(
                    Icons.mail_outline_rounded,
                    color: Color(0xFFEF4444),
                    size: 22,
                  ),
                  bgColor: const Color(0xFFFEE2E2),
                  label: 'Email',
                  onTap: () => _copyLink('Email'),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required Widget iconWidget,
    required Color bgColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(child: iconWidget),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
