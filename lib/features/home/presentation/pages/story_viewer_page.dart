import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/chat_service.dart';
import '../../data/services/story_like_service.dart';
import '../../domain/entities/post.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import 'chat_detail_page.dart';

class StoryViewerPage extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;
  final Story? story;

  const StoryViewerPage({
    super.key,
    this.stories = const [],
    this.initialIndex = 0,
    this.story,
  });

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage>
    with SingleTickerProviderStateMixin {
  late List<Story> _stories;
  late int _currentUserIndex;
  int _currentSlideIndex = 0;

  late PageController _pageController;

  double _progress = 0.0;
  Timer? _timer;
  bool _isPaused = false;
  bool _isTyping = false;
  bool _isPageAnimating = false;

  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();

  double _heartScale = 1.0;
  bool _showBigHeart = false;

  final List<String> _quickReactions = [
    '❤️', '🔥', '👏', '🚀', '😍', '💡', '💯'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.stories.isNotEmpty) {
      _stories = List<Story>.from(widget.stories);
      _currentUserIndex = widget.initialIndex.clamp(0, _stories.length - 1);
    } else if (widget.story != null) {
      _stories = [widget.story!];
      _currentUserIndex = 0;
    } else {
      _stories = [];
      _currentUserIndex = 0;
    }

    _pageController = PageController(initialPage: _currentUserIndex);

    _replyFocusNode.addListener(() {
      setState(() {
        _isTyping = _replyFocusNode.hasFocus;
      });
      if (_isTyping) {
        _pauseTimer();
      } else {
        _resumeTimer();
      }
    });

    _markStoryAsViewed(_currentUserIndex);
    _startStoryTimer();
  }

  void _markStoryAsViewed(int userIndex) {
    if (_stories.isEmpty || userIndex < 0 || userIndex >= _stories.length) return;
    final story = _stories[userIndex];
    if (story.isUserStory || story.name == 'Your Story') {
      // Do NOT increment views or mark own story as viewed
      return;
    }
    try {
      context.read<FeedBloc>().add(MarkStoryAsViewedEvent(story.id));
    } catch (_) {}
  }

  List<String> _getSlidesForUser(int index) {
    if (index < 0 || index >= _stories.length) return [];
    final story = _stories[index];
    if (story.slides.isNotEmpty) {
      return story.slides;
    }
    return [story.storyImageUrl];
  }

  void _startStoryTimer() {
    _timer?.cancel();
    if (_stories.isEmpty) return;

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      if (_isPaused || _isTyping || _isPageAnimating) return;

      setState(() {
        _progress += 0.01;
        if (_progress >= 1.0) {
          _progress = 0.0;
          _nextSlideOrUser();
        }
      });
    });
  }

  void _pauseTimer() {
    _isPaused = true;
  }

  void _resumeTimer() {
    _isPaused = false;
  }

  void _nextSlideOrUser() {
    final slides = _getSlidesForUser(_currentUserIndex);
    if (_currentSlideIndex < slides.length - 1) {
      // Advance to next slide of current user
      setState(() {
        _currentSlideIndex++;
        _progress = 0.0;
      });
    } else {
      // Last slide of current user: advance to next user!
      _goToNextUser();
    }
  }

  void _goToNextUser() {
    if (_currentUserIndex < _stories.length - 1) {
      final nextUser = _currentUserIndex + 1;
      _markStoryAsViewed(nextUser);
      _isPageAnimating = true;
      setState(() {
        _progress = 0.0;
        _currentSlideIndex = 0;
      });
      _pageController.animateToPage(
        nextUser,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      ).then((_) {
        if (mounted) {
          setState(() {
            _isPageAnimating = false;
            _progress = 0.0;
            _currentSlideIndex = 0;
          });
          _resumeTimer();
        }
      });
    } else {
      // Reached the end of all stories
      _timer?.cancel();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _previousSlideOrUser() {
    if (_currentSlideIndex > 0) {
      // Go back one slide in current user's story
      setState(() {
        _currentSlideIndex--;
        _progress = 0.0;
      });
    } else {
      // Go to previous user's last slide
      if (_currentUserIndex > 0) {
        final prevUser = _currentUserIndex - 1;
        final prevSlides = _getSlidesForUser(prevUser);
        _isPageAnimating = true;
        setState(() {
          _currentSlideIndex = prevSlides.isNotEmpty ? prevSlides.length - 1 : 0;
          _progress = 0.0;
        });
        _pageController.animateToPage(
          prevUser,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        ).then((_) {
          if (mounted) {
            setState(() {
              _isPageAnimating = false;
              _progress = 0.0;
            });
            _resumeTimer();
          }
        });
      } else {
        setState(() {
          _progress = 0.0;
        });
      }
    }
  }

  void _toggleLike() {
    if (_stories.isEmpty) return;
    final currentStory = _stories[_currentUserIndex];
    if (currentStory.isUserStory || currentStory.name == 'Your Story') {
      // Cannot like own story
      return;
    }

    final isNowLiked = StoryLikeService.instance.toggleSlideLike(
      currentStory.id,
      _currentSlideIndex,
    );

    setState(() {
      if (isNowLiked) {
        _triggerBigHeart();
      }
      _heartScale = 1.4;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _heartScale = 1.0;
        });
      }
    });
  }

  void _triggerBigHeart() {
    setState(() {
      _showBigHeart = true;
    });
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        setState(() {
          _showBigHeart = false;
        });
      }
    });
  }

  void _sendReply([String? textToSend]) {
    final text = (textToSend ?? _replyController.text).trim();
    if (text.isEmpty || _stories.isEmpty) return;

    final currentStory = _stories[_currentUserIndex];
    _replyController.clear();
    _replyFocusNode.unfocus();
    _resumeTimer();

    // Persist story reply in chat service
    final conversation = ChatService.instance.addStoryReply(
      story: currentStory,
      replyText: text,
    );

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
            Expanded(
              child: Text(
                'Reply sent to ${currentStory.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatDetailPage(
                      conversationId: conversation.id,
                      userName: currentStory.name,
                      userAvatar: currentStory.avatarUrl,
                      isOnline: true,
                    ),
                  ),
                );
              },
              child: const Text(
                'View Chat',
                style: TextStyle(
                  color: AppColors.purpleGlow,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showViewersSheet(Story story) {
    _pauseTimer();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.remove_red_eye_rounded,
                    color: AppColors.primaryPurple, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${story.viewsCount} Viewers',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Seen by founders, angel investors, and venture partners across MENA.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ).then((_) => _resumeTimer());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_stories.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'No stories available',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: _stories.length,
        onPageChanged: (newIndex) {
          setState(() {
            _currentUserIndex = newIndex;
            _currentSlideIndex = 0;
            _progress = 0.0;
            _isPageAnimating = false;
          });
          _markStoryAsViewed(newIndex);
          _resumeTimer();
        },
        itemBuilder: (context, userIndex) {
          final currentStory = _stories[userIndex];
          final isOwnStory = currentStory.isUserStory || currentStory.name == 'Your Story';
          final slides = _getSlidesForUser(userIndex);
          final int slideIndex = (userIndex == _currentUserIndex)
              ? _currentSlideIndex.clamp(0, slides.isNotEmpty ? slides.length - 1 : 0)
              : 0;
          final slideUrl = (slides.isNotEmpty && slideIndex < slides.length)
              ? slides[slideIndex]
              : currentStory.storyImageUrl;
          final slideCaption = currentStory.getSlideCaption(slideIndex);
          final isLiked = StoryLikeService.instance.isSlideLiked(currentStory.id, slideIndex);

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTap: isOwnStory ? null : _toggleLike,
            onLongPressStart: (_) => _pauseTimer(),
            onLongPressEnd: (_) => _resumeTimer(),
            onTapDown: (details) {
              if (details.globalPosition.dy <= screenHeight - 120) {
                _pauseTimer();
              }
            },
            onTapCancel: _resumeTimer,
            onTapUp: (details) {
              if (_isTyping) {
                _replyFocusNode.unfocus();
                _resumeTimer();
                return;
              }

              final dy = details.globalPosition.dy;
              final dx = details.globalPosition.dx;

              // Don't trigger story navigation if tap is on top bar or bottom reply bar
              if (dy > screenHeight - 120 || dy < 100) {
                _resumeTimer();
                return;
              }

              if (dx > screenWidth * 0.65) {
                // Tap on right side -> Next slide or next user
                _nextSlideOrUser();
              } else if (dx < screenWidth * 0.35) {
                // Tap on left side -> Previous slide or user
                _previousSlideOrUser();
              } else {
                _resumeTimer();
              }
            },
            onVerticalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity > 300) {
                Navigator.pop(context);
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Story Image / Media
                _buildStoryMedia(slideUrl, currentStory, slideCaption),

                // Top & Bottom Gradient Overlays
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black87,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black87,
                      ],
                      stops: [0.0, 0.20, 0.65, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // Floating Big Heart Animation (Double tap or Love tap)
                if (_showBigHeart)
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.4, end: 1.2),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: const Icon(
                            Icons.favorite,
                            color: Color(0xFFEF4444),
                            size: 100,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 24,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                // Top Section (Progress bars + Header with views & timestamp)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Segmented Progress Bar for the user's slides
                        Row(
                          children: List.generate(slides.length, (sIndex) {
                            double value;
                            if (userIndex == _currentUserIndex) {
                              if (sIndex < _currentSlideIndex) {
                                value = 1.0;
                              } else if (sIndex == _currentSlideIndex) {
                                value = _progress;
                              } else {
                                value = 0.0;
                              }
                            } else {
                              value = (userIndex < _currentUserIndex) ? 1.0 : 0.0;
                            }

                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: value,
                                    backgroundColor: Colors.white24,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    minHeight: 2.5,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),

                        // Header: Avatar, Name, Views Count, Time, and Close Button
                        Row(
                          children: [
                            ClipOval(
                              child: Image.network(
                                currentStory.avatarUrl,
                                width: 38,
                                height: 38,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const CircleAvatar(
                                  radius: 19,
                                  backgroundColor: AppColors.purpleLight,
                                  child: Icon(
                                    Icons.person,
                                    color: AppColors.primaryPurple,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      currentStory.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Relative Timestamp (e.g. 2h ago)
                                    Text(
                                      _formatTimeAgo(currentStory.createdAt),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                // Views Count Pill
                                GestureDetector(
                                  onTap: () => _showViewersSheet(currentStory),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.remove_red_eye_outlined,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${currentStory.viewsCount} views',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Section: Caption + Quick Reactions + Reply Bar & Love Button
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Story Caption
                        if (slideCaption.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Text(
                              slideCaption,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                              ),
                            ),
                          ),

                        // Own Story: Display Viewers & Activity (No reply bar, No love button)
                        if (isOwnStory)
                          Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(color: Colors.white24, width: 1.2),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _showViewersSheet(currentStory),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.visibility_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${currentStory.viewsCount} Viewers',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => _showViewersSheet(currentStory),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryPurple
                                          .withValues(alpha: 0.28),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: AppColors.primaryPurple),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.insights_rounded,
                                          color: AppColors.purpleGlow,
                                          size: 16,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Activity',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          // Quick Reactions (Visible when user focuses input or typing)
                          if (_isTyping)
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B)
                                    .withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: _quickReactions.map((emoji) {
                                  return GestureDetector(
                                    onTap: () => _sendReply(emoji),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      child: Text(
                                        emoji,
                                        style: const TextStyle(fontSize: 22),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                          // Reply Input + Love Button
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: _isTyping
                                          ? AppColors.primaryPurple
                                          : Colors.white.withValues(alpha: 0.3),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      inputDecorationTheme: const InputDecorationTheme(
                                        filled: false,
                                        fillColor: Colors.transparent,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _replyController,
                                            focusNode: _replyFocusNode,
                                            cursorColor: Colors.white,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                            decoration: InputDecoration(
                                              filled: false,
                                              fillColor: Colors.transparent,
                                              hintText:
                                                  'Reply to ...',
                                              hintStyle: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13.5,
                                              ),
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                            ),
                                            onSubmitted: (_) => _sendReply(),
                                          ),
                                        ),
                                        if (_replyController.text.trim().isNotEmpty)
                                          GestureDetector(
                                            onTap: () => _sendReply(),
                                            child: const Padding(
                                              padding: EdgeInsets.only(left: 8),
                                              child: Icon(
                                                Icons.send_rounded,
                                                color: AppColors.purpleGlow,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: _toggleLike,
                                child: AnimatedScale(
                                  scale: _heartScale,
                                  duration: const Duration(milliseconds: 150),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isLiked
                                          ? const Color(0xFFEF4444)
                                          : Colors.white
                                              .withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isLiked
                                            ? const Color(0xFFEF4444)
                                            : Colors.white24,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoryMedia(String pathOrUrl, Story currentStory, String caption) {
    if (pathOrUrl.startsWith('data:image')) {
      try {
        final commaIndex = pathOrUrl.indexOf(',');
        if (commaIndex != -1) {
          final base64Str = pathOrUrl.substring(commaIndex + 1);
          final bytes = base64Decode(base64Str);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => _buildFallbackStoryCanvas(currentStory, caption),
          );
        }
      } catch (_) {}
    }

    if (pathOrUrl.startsWith('gradient:')) {
      final idxStr = pathOrUrl.replaceFirst('gradient:', '');
      final idx = int.tryParse(idxStr) ?? 0;
      final gradients = [
        [const Color(0xFF8B5CF6), const Color(0xFF6366F1), const Color(0xFF3B82F6)],
        [const Color(0xFFEC4899), const Color(0xFF8B5CF6), const Color(0xFF3B82F6)],
        [const Color(0xFF10B981), const Color(0xFF06B6D4), const Color(0xFF3B82F6)],
        [const Color(0xFFF59E0B), const Color(0xFFEF4444), const Color(0xFF8B5CF6)],
        [const Color(0xFF0F172A), const Color(0xFF1E293B), const Color(0xFF334155)],
      ];
      final grad = gradients[idx % gradients.length];
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: grad,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              caption.isNotEmpty ? caption : currentStory.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    if (pathOrUrl.startsWith('http') ||
        pathOrUrl.startsWith('blob:')) {
      return Image.network(
        pathOrUrl,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFF0F172A),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white54,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (_, _, _) => _buildFallbackStoryCanvas(currentStory, caption),
      );
    } else {
      if (!kIsWeb) {
        final f = File(pathOrUrl);
        if (f.existsSync()) {
          return Image.file(
            f,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => _buildFallbackStoryCanvas(currentStory, caption),
          );
        }
      }
      return _buildFallbackStoryCanvas(currentStory, caption);
    }
  }

  Widget _buildFallbackStoryCanvas(Story currentStory, String caption) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: NetworkImage(currentStory.avatarUrl),
            ),
            const SizedBox(height: 16),
            Text(
              currentStory.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (caption.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
