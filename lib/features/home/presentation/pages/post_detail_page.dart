import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/post.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../bloc/feed_state.dart';
import '../widgets/share_post_modal.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    context.read<FeedBloc>().add(
          AddCommentEvent(
            postId: widget.post.id,
            content: text,
          ),
        );

    _commentController.clear();
    FocusScope.of(context).unfocus();

    // Smooth scroll down to new comment
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        // Find latest post state from BLoC if available
        Post currentPost = widget.post;
        if (state is FeedLoadedState) {
          final found = state.posts.where((p) => p.id == widget.post.id);
          if (found.isNotEmpty) {
            currentPost = found.first;
          }
        }

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.ink,
                    size: 20,
                  ),
                ),
              ),
            ),
            title: const Text(
              'Post',
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            centerTitle: false,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post author row matching Figma Image 3
                      Row(
                        children: [
                          ClipOval(
                            child: Image.network(
                              currentPost.authorAvatar,
                              width: 46,
                              height: 46,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const CircleAvatar(
                                radius: 23,
                                backgroundColor: AppColors.purpleLight,
                                child: Icon(Icons.person,
                                    color: AppColors.primaryPurple),
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
                                        currentPost.authorName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: AppColors.ink,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF10B981), // Active green dot
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  currentPost.authorRole,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  _formatTimeAgo(currentPost.createdAt),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Post Content
                      Text(
                        currentPost.content,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: AppColors.ink,
                        ),
                      ),
                      if (currentPost.media.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _buildDetailMedia(currentPost.media.first),
                      ],
                      const SizedBox(height: 16),
                      // Actions Bar
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              context
                                  .read<FeedBloc>()
                                  .add(ToggleLikeEvent(currentPost.id));
                            },
                            child: Row(
                              children: [
                                Icon(
                                  currentPost.isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: currentPost.isLiked
                                      ? const Color(0xFFEF4444)
                                      : AppColors.textMuted,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${currentPost.likeCount}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: currentPost.isLiked
                                        ? const Color(0xFFEF4444)
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          InkWell(
                            onTap: () {
                              // Scroll to the comment input section when comment icon tapped
                              if (_scrollController.hasClients) {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              }
                            },
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: AppColors.textMuted,
                                  size: 19,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${currentPost.comments.length}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          InkWell(
                            onTap: () => SharePostModal.show(context, currentPost),
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.share_outlined,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Share',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              context
                                  .read<FeedBloc>()
                                  .add(ToggleBookmarkEvent(currentPost.id));
                            },
                            icon: Icon(
                              currentPost.isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: currentPost.isBookmarked
                                  ? AppColors.primaryPurple
                                  : AppColors.textMuted,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFFF1F5F9), height: 28),
                      // Comments Header
                      Text(
                        '${currentPost.comments.length} Comments',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Comments List
                      if (currentPost.comments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No comments yet. Be the first to share your thoughts!',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: currentPost.comments.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final comment = currentPost.comments[index];
                            return _buildCommentItem(
                                context, currentPost.id, comment);
                          },
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // Sticky Comment Input Bar matching Figma Image 3
              _buildCommentInputBar(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentItem(
      BuildContext context, int postId, Comment comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: Image.network(
            comment.authorAvatar,
            width: 38,
            height: 38,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const CircleAvatar(
              radius: 19,
              backgroundColor: AppColors.purpleLight,
              child: Icon(Icons.person, color: AppColors.primaryPurple, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: comment.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          color: AppColors.ink,
                        ),
                        children: [
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: comment.authorRole,
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      comment.content,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.ink,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Actions row: time ago · Likes count · Reply
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Text(
                      _formatTimeAgo(comment.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        context.read<FeedBloc>().add(
                              ToggleCommentLikeEvent(
                                postId: postId,
                                commentId: comment.id,
                              ),
                            );
                      },
                      child: Row(
                        children: [
                          Icon(
                            comment.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 13,
                            color: comment.isLiked
                                ? const Color(0xFFEF4444)
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.likeCount} Likes',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: comment.isLiked
                                  ? const Color(0xFFEF4444)
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        _commentController.text = '@${comment.authorName} ';
                      },
                      child: const Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentInputBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            ClipOval(
              child: Image.network(
                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.purpleLight,
                  child: Icon(Icons.person, color: AppColors.primaryPurple),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13.5,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onSubmitted: (_) => _sendComment(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _sendComment,
              icon: const Icon(
                Icons.send_rounded,
                color: AppColors.primaryPurple,
                size: 22,
              ),
              tooltip: 'Send',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailMedia(PostMedia media) {
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
                size: 28,
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
              size: 24,
            ),
          ],
        ),
      );
    }

    Widget imageWidget;
    if (url.startsWith('http') || url.startsWith('blob:')) {
      imageWidget = Image.network(
        url,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          height: 180,
          color: const Color(0xFF1E293B),
          child: const Center(
            child: Icon(Icons.image, color: Colors.white54, size: 48),
          ),
        ),
      );
    } else {
      if (!kIsWeb) {
        final f = File(url);
        if (f.existsSync()) {
          imageWidget = Image.file(
            f,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        } else {
          imageWidget = Container(
            height: 180,
            color: const Color(0xFF1E293B),
            child: const Center(
              child: Icon(Icons.image, color: Colors.white54, size: 48),
            ),
          );
        }
      } else {
        imageWidget = Container(
          height: 180,
          color: const Color(0xFF1E293B),
          child: const Center(
            child: Icon(Icons.image, color: Colors.white54, size: 48),
          ),
        );
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageWidget,
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
