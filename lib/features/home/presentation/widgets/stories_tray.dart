import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/post.dart';
import '../bloc/feed_bloc.dart';
import '../pages/create_story_page.dart';
import '../pages/story_viewer_page.dart';

class StoriesTray extends StatelessWidget {
  final List<Story> stories;

  const StoriesTray({super.key, required this.stories});

  List<Story> _getGroupedStories() {
    // 1. Combine all user stories into a single 'Your Story' entry with multiple slides!
    final userStories =
        stories.where((s) => s.isUserStory || s.name == 'Your Story').toList();

    final List<String> combinedSlides = [];
    final List<String> combinedCaptions = [];
    String latestImageUrl =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800';
    String latestCaption = '';
    bool anyUnviewed = false;
    int totalViews = 0;
    int userStoryId = 0;

    for (final s in userStories) {
      if (s.slides.isNotEmpty) {
        combinedSlides.addAll(s.slides);
        if (s.slideCaptions.isNotEmpty) {
          combinedCaptions.addAll(s.slideCaptions);
          while (combinedCaptions.length < combinedSlides.length) {
            combinedCaptions.add(s.caption);
          }
        } else {
          combinedCaptions.addAll(List.filled(s.slides.length, s.caption));
        }
        latestImageUrl = s.slides.last;
      } else if (s.id != 0 && s.storyImageUrl.isNotEmpty) {
        combinedSlides.add(s.storyImageUrl);
        combinedCaptions.add(s.caption);
        latestImageUrl = s.storyImageUrl;
      }
      if (s.caption.isNotEmpty) latestCaption = s.caption;
      if (s.hasUnviewed) anyUnviewed = true;
      totalViews += s.viewsCount;
      if (s.id != 0) userStoryId = s.id;
    }

    while (combinedCaptions.length < combinedSlides.length) {
      combinedCaptions.add(latestCaption);
    }

    final userStory = Story(
      id: userStoryId,
      name: 'Your Story',
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      storyImageUrl: latestImageUrl,
      caption: latestCaption,
      createdAt: DateTime.now(),
      isUserStory: true,
      hasUnviewed: anyUnviewed,
      viewsCount: totalViews,
      slides: combinedSlides,
      slideCaptions: combinedCaptions,
    );

    // 2. Keep unique entries for all other users
    final Map<String, Story> otherUsersMap = {};
    for (final s in stories) {
      if (!s.isUserStory && s.name != 'Your Story') {
        if (!otherUsersMap.containsKey(s.name)) {
          final sCaptions = s.slideCaptions.isNotEmpty
              ? List<String>.from(s.slideCaptions)
              : (s.slides.isNotEmpty
                  ? List.filled(s.slides.length, s.caption)
                  : [s.caption]);
          otherUsersMap[s.name] = s.copyWith(slideCaptions: sCaptions);
        } else {
          // If duplicate user exists, append slides & captions
          final existing = otherUsersMap[s.name]!;
          final mergedSlides = List<String>.from(existing.slides);
          final mergedCaptions = List<String>.from(existing.slideCaptions);
          if (s.slides.isNotEmpty) {
            mergedSlides.addAll(s.slides);
            if (s.slideCaptions.isNotEmpty) {
              mergedCaptions.addAll(s.slideCaptions);
            } else {
              mergedCaptions.addAll(List.filled(s.slides.length, s.caption));
            }
          } else {
            mergedSlides.add(s.storyImageUrl);
            mergedCaptions.add(s.caption);
          }
          otherUsersMap[s.name] = existing.copyWith(
            slides: mergedSlides,
            slideCaptions: mergedCaptions,
            hasUnviewed: existing.hasUnviewed || s.hasUnviewed,
          );
        }
      }
    }

    return [userStory, ...otherUsersMap.values];
  }

  void _openCreateStory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<FeedBloc>(),
          child: const CreateStoryPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedStories = _getGroupedStories();
    final userStory = groupedStories.first;

    // Viewable stories for the viewer
    final viewableStories = groupedStories
        .where((s) => s.slides.isNotEmpty || s.id != 0)
        .toList();

    return Container(
      height: 105,
      color: AppColors.white,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: groupedStories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final story = groupedStories[index];
          if (index == 0) {
            return _buildYourStoryItem(context, userStory, viewableStories);
          }
          return _buildStoryItem(context, story, viewableStories);
        },
      ),
    );
  }

  Widget _buildYourStoryItem(
    BuildContext context,
    Story userStory,
    List<Story> allViewableStories,
  ) {
    final hasSlides = userStory.slides.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (hasSlides) {
          // View your stories
          final initialIdx = allViewableStories.indexOf(userStory);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<FeedBloc>(),
                child: StoryViewerPage(
                  stories: allViewableStories,
                  initialIndex: initialIdx >= 0 ? initialIdx : 0,
                ),
              ),
            ),
          );
        } else {
          // No story posted yet -> Open Create Story
          _openCreateStory(context);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 62,
                height: 62,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hasSlides && userStory.hasUnviewed
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF06B6D4), // Cyan
                            Color(0xFF6366F1), // Indigo
                            Color(0xFFA855F7), // Purple
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  border: hasSlides && !userStory.hasUnviewed
                      ? Border.all(color: const Color(0xFF94A3B8), width: 2.2)
                      : (!hasSlides
                          ? Border.all(
                              color: AppColors.purpleGlow.withValues(alpha: 0.6),
                              width: 2,
                            )
                          : null),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                    child: Image.network(
                      userStory.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: AppColors.purpleLight,
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Plus icon badge (always accessible to add more stories!)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => _openCreateStory(context),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.add, color: Colors.white, size: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Your Story',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem(
    BuildContext context,
    Story story,
    List<Story> viewableStories,
  ) {
    return GestureDetector(
      onTap: () {
        final initialIdx = viewableStories.indexOf(story);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<FeedBloc>(),
              child: StoryViewerPage(
                stories: viewableStories,
                initialIndex: initialIdx >= 0 ? initialIdx : 0,
              ),
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: story.hasUnviewed
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF06B6D4), // Cyan
                        Color(0xFF6366F1), // Indigo
                        Color(0xFFA855F7), // Purple
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: story.hasUnviewed ? null : const Color(0xFFE2E8F0),
              border: story.hasUnviewed
                  ? null
                  : Border.all(
                      color: const Color(0xFF94A3B8),
                      width: 2.2,
                    ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
              ),
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: Image.network(
                  story.avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.purpleLight,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 68,
            child: Text(
              story.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
