import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/post.dart';
import '../bloc/feed_bloc.dart';
import 'poll_widget.dart';
import 'share_post_modal.dart';
import '../pages/post_detail_page.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final Function(int optionId) onVote;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onBookmark,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          _buildHeader(context),
          const SizedBox(height: 12),
          // Post Content
          _buildContent(context),
          // Media Image if present
          if (post.media.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildMedia(context),
          ],
          // Poll Widget if present
          if (post.poll != null) ...[
            PollWidget(
              poll: post.poll!,
              onVote: onVote,
            ),
          ],
          const SizedBox(height: 14),
          // Actions Bar
          _buildActionsBar(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar with verified badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipOval(
              child: Image.network(
                post.authorAvatar,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.purpleLight,
                  child: Icon(Icons.person, color: AppColors.primaryPurple),
                ),
              ),
            ),
            if (post.isVerified)
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4F46E5), // Verified Indigo
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: 11,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Author Name & Role
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildPostTypeBadge(post.postType),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${post.authorRole} · ${_formatTimeAgo(post.createdAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Three dots menu
        IconButton(
          onPressed: () => _showPostOptions(context),
          icon: const Icon(
            Icons.more_horiz,
            color: AppColors.textMuted,
          ),
          splashRadius: 20,
        ),
      ],
    );
  }

  Widget _buildPostTypeBadge(PostType type) {
    Color bg;
    Color text;

    switch (type) {
      case PostType.funding:
        bg = AppColors.emeraldBg;
        text = AppColors.emeraldText;
        break;
      case PostType.insight:
      case PostType.founderStory:
        bg = AppColors.violetBg;
        text = AppColors.violetText;
        break;
      case PostType.opportunity:
        bg = AppColors.roseBg;
        text = AppColors.roseText;
        break;
      case PostType.poll:
        bg = AppColors.purpleLight;
        text = AppColors.primaryPurple;
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        text = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.displayName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<FeedBloc>(),
              child: PostDetailPage(post: post),
            ),
          ),
        );
      },
      child: Text(
        post.content,
        style: const TextStyle(
          fontSize: 14.5,
          color: AppColors.ink,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildMedia(BuildContext context) {
    final media = post.media.first;
    final url = media.url;
    final isPdf = media.mediaType == MediaType.businessDocument ||
        media.mediaType == MediaType.pitchDeck ||
        url.toLowerCase().endsWith('.pdf') ||
        url.toLowerCase().contains('.pdf');
    final isDoc = url.toLowerCase().endsWith('.doc') ||
        url.toLowerCase().endsWith('.docx') ||
        url.toLowerCase().endsWith('.xls') ||
        url.toLowerCase().endsWith('.xlsx') ||
        url.toLowerCase().endsWith('.txt');

    if (isPdf || isDoc) {
      final fileName = url.split('/').last.split('\\').last;
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isPdf
                    ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                    : AppColors.primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isPdf
                    ? Icons.picture_as_pdf_rounded
                    : Icons.insert_drive_file_rounded,
                color: isPdf
                    ? const Color(0xFFEF4444)
                    : AppColors.primaryPurple,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName.isNotEmpty ? fileName : 'Attached Document',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isPdf
                        ? 'PDF Document · Attachment'
                        : 'Document File · Attachment',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.download_rounded,
              color: AppColors.primaryPurple,
              size: 22,
            ),
          ],
        ),
      );
    }

    Widget imageWidget;
    if (url.startsWith('http') || url.startsWith('blob:')) {
      imageWidget = Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildMediaFallback(),
      );
    } else {
      if (!kIsWeb) {
        final f = File(url);
        if (f.existsSync()) {
          imageWidget = Image.file(
            f,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildMediaFallback(),
          );
        } else {
          imageWidget = _buildMediaFallback();
        }
      } else {
        imageWidget = _buildMediaFallback();
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 260),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: imageWidget,
      ),
    );
  }

  Widget _buildMediaFallback() {
    return Container(
      height: 180,
      color: const Color(0xFF1E293B),
      child: const Center(
        child: Icon(Icons.bar_chart_rounded, color: Colors.white54, size: 48),
      ),
    );
  }

  Widget _buildActionsBar(BuildContext context) {
    return Row(
      children: [
        // Like Button
        InkWell(
          onTap: onLike,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: Row(
              children: [
                Icon(
                  post.isLiked ? Icons.favorite : Icons.favorite_border_rounded,
                  color: post.isLiked ? const Color(0xFFEF4444) : AppColors.textMuted,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  '${post.likeCount}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: post.isLiked
                        ? const Color(0xFFEF4444)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 18),
        // Comment Button
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<FeedBloc>(),
                  child: PostDetailPage(post: post),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.textMuted,
                  size: 19,
                ),
                const SizedBox(width: 6),
                Text(
                  '${post.commentCount}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 18),
        // Share Button
        InkWell(
          onTap: () => _sharePost(context),
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: Icon(
              Icons.share_outlined,
              color: AppColors.textMuted,
              size: 20,
            ),
          ),
        ),
        const Spacer(),
        // Bookmark Button
        InkWell(
          onTap: onBookmark,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: Icon(
              post.isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: post.isBookmarked
                  ? AppColors.primaryPurple
                  : AppColors.textMuted,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  void _sharePost(BuildContext context) {
    SharePostModal.show(context, post);
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: Text(post.isBookmarked ? 'Remove Bookmark' : 'Save Post'),
              onTap: () {
                Navigator.pop(ctx);
                onBookmark();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy Post Link'),
              onTap: () {
                Navigator.pop(ctx);
                _sharePost(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem_outlined, color: Colors.red),
              title: const Text('Report Post', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted for review.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
