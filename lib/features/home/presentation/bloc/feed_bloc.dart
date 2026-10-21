import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/feed_repository.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedRepository feedRepository;

  FeedBloc({required this.feedRepository}) : super(FeedInitialState()) {
    on<LoadFeedEvent>(_onLoadFeed);
    on<SelectTagEvent>(_onSelectTag);
    on<ToggleLikeEvent>(_onToggleLike);
    on<ToggleBookmarkEvent>(_onToggleBookmark);
    on<VotePollEvent>(_onVotePoll);
    on<CreatePostEvent>(_onCreatePost);
    on<AddCommentEvent>(_onAddComment);
    on<ToggleCommentLikeEvent>(_onToggleCommentLike);
    on<AddStoryEvent>(_onAddStory);
    on<MarkStoryAsViewedEvent>(_onMarkStoryAsViewed);
  }

  Future<void> _onLoadFeed(
    LoadFeedEvent event,
    Emitter<FeedState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(FeedLoadingState());
    }

    try {
      final stories = await feedRepository.getStories();
      final recommended = await feedRepository.getRecommendedInvestors();
      final tag = event.selectedTag == 'All' ? null : event.selectedTag;
      final posts = await feedRepository.getFeed(tag: tag);

      if (posts.isEmpty) {
        emit(FeedEmptyState(stories: stories));
      } else {
        emit(
          FeedLoadedState(
            posts: posts,
            stories: stories,
            recommendedInvestors: recommended,
            selectedTag: event.selectedTag ?? 'All',
          ),
        );
      }
    } catch (e) {
      emit(FeedErrorState(e.toString()));
    }
  }

  Future<void> _onSelectTag(
    SelectTagEvent event,
    Emitter<FeedState> emit,
  ) async {
    if (state is! FeedLoadedState && state is! FeedEmptyState) return;

    final currentStories = state is FeedLoadedState
        ? (state as FeedLoadedState).stories
        : (state as FeedEmptyState).stories;

    final currentInvestors = state is FeedLoadedState
        ? (state as FeedLoadedState).recommendedInvestors
        : await feedRepository.getRecommendedInvestors();

    try {
      final tag = event.tag == 'All' ? null : event.tag;
      final posts = await feedRepository.getFeed(tag: tag);

      if (posts.isEmpty) {
        emit(FeedEmptyState(stories: currentStories));
      } else {
        emit(
          FeedLoadedState(
            posts: posts,
            stories: currentStories,
            recommendedInvestors: currentInvestors,
            selectedTag: event.tag,
          ),
        );
      }
    } catch (e) {
      emit(FeedErrorState(e.toString()));
    }
  }

  Future<void> _onToggleLike(
    ToggleLikeEvent event,
    Emitter<FeedState> emit,
  ) async {
    if (state is! FeedLoadedState) return;
    final currentState = state as FeedLoadedState;

    try {
      final updatedPost = await feedRepository.toggleLike(event.postId);
      final updatedPosts = currentState.posts.map((p) {
        return p.id == updatedPost.id ? updatedPost : p;
      }).toList();

      emit(currentState.copyWith(posts: updatedPosts));
    } catch (_) {}
  }

  Future<void> _onToggleBookmark(
    ToggleBookmarkEvent event,
    Emitter<FeedState> emit,
  ) async {
    if (state is! FeedLoadedState) return;
    final currentState = state as FeedLoadedState;

    try {
      final updatedPost = await feedRepository.toggleBookmark(event.postId);
      final updatedPosts = currentState.posts.map((p) {
        return p.id == updatedPost.id ? updatedPost : p;
      }).toList();

      emit(
        currentState.copyWith(
          posts: updatedPosts,
          actionFeedbackMessage: updatedPost.isBookmarked
              ? 'Post saved to bookmarks'
              : 'Post removed from bookmarks',
        ),
      );
    } catch (_) {}
  }

  Future<void> _onVotePoll(
    VotePollEvent event,
    Emitter<FeedState> emit,
  ) async {
    if (state is! FeedLoadedState) return;
    final currentState = state as FeedLoadedState;

    try {
      final updatedPost =
          await feedRepository.votePoll(event.postId, event.pollOptionId);
      final updatedPosts = currentState.posts.map((p) {
        return p.id == updatedPost.id ? updatedPost : p;
      }).toList();

      emit(
        currentState.copyWith(
          posts: updatedPosts,
          actionFeedbackMessage: 'Your vote has been recorded!',
        ),
      );
    } catch (_) {}
  }

  Future<void> _onCreatePost(
    CreatePostEvent event,
    Emitter<FeedState> emit,
  ) async {
    if (state is! FeedLoadedState) return;
    final currentState = state as FeedLoadedState;

    emit(currentState.copyWith(isCreatingPost: true));

    try {
      final createdPost = await feedRepository.createPost(
        content: event.content,
        postType: event.postType,
        tags: event.tags,
        mediaUrls: event.mediaUrls,
        pollQuestion: event.pollQuestion,
        pollOptions: event.pollOptions,
      );

      final updatedPosts = [createdPost, ...currentState.posts];
      emit(
        currentState.copyWith(
          posts: updatedPosts,
          isCreatingPost: false,
          actionFeedbackMessage: 'Post published successfully!',
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          isCreatingPost: false,
          actionFeedbackMessage: 'Failed to create post. Please try again.',
        ),
      );
    }
  }

  Future<void> _onAddComment(
    AddCommentEvent event,
    Emitter<FeedState> emit,
  ) async {
    if (state is! FeedLoadedState) return;
    final currentState = state as FeedLoadedState;

    try {
      final newComment = await feedRepository.addComment(
        postId: event.postId,
        content: event.content,
      );

      final updatedPosts = currentState.posts.map((p) {
        if (p.id == event.postId) {
          final newComments = [...p.comments, newComment];
          return p.copyWith(
            comments: newComments,
            commentCount: p.commentCount + 1,
          );
        }
        return p;
      }).toList();

      emit(
        currentState.copyWith(
          posts: updatedPosts,
          actionFeedbackMessage: 'Comment added',
        ),
      );
    } catch (_) {}
  }

  Future<void> _onToggleCommentLike(
    ToggleCommentLikeEvent event,
    Emitter<FeedState> emit,
  ) async {
    if (state is! FeedLoadedState) return;
    final currentState = state as FeedLoadedState;

    try {
      final updatedComment = await feedRepository.toggleCommentLike(
        postId: event.postId,
        commentId: event.commentId,
      );

      final updatedPosts = currentState.posts.map((p) {
        if (p.id == event.postId) {
          final newComments = p.comments.map((c) {
            return c.id == updatedComment.id ? updatedComment : c;
          }).toList();
          return p.copyWith(comments: newComments);
        }
        return p;
      }).toList();

      emit(currentState.copyWith(posts: updatedPosts));
    } catch (_) {}
  }

  Future<void> _onAddStory(
    AddStoryEvent event,
    Emitter<FeedState> emit,
  ) async {
    if (state is! FeedLoadedState) return;
    final currentState = state as FeedLoadedState;

    try {
      final updatedStory = await feedRepository.addStory(
        caption: event.caption,
        imageUrl: event.imageUrl,
      );

      final currentStories = List<Story>.from(currentState.stories);
      final existingIdx = currentStories.indexWhere(
        (s) => s.isUserStory || s.name == 'Your Story',
      );

      if (existingIdx != -1) {
        currentStories[existingIdx] = updatedStory;
      } else {
        currentStories.insert(0, updatedStory);
      }

      emit(
        currentState.copyWith(
          stories: currentStories,
          actionFeedbackMessage: 'Story added successfully! 🚀',
        ),
      );
    } catch (_) {}
  }

  void _onMarkStoryAsViewed(
    MarkStoryAsViewedEvent event,
    Emitter<FeedState> emit,
  ) {
    if (state is! FeedLoadedState) return;
    final currentState = state as FeedLoadedState;

    final updatedStories = currentState.stories.map((s) {
      if (s.id == event.storyId) {
        if (s.isUserStory || s.name == 'Your Story') {
          return s; // Own story: never mark as unviewed/viewed or increment views
        }
        return s.copyWith(hasUnviewed: false);
      }
      return s;
    }).toList();

    emit(currentState.copyWith(stories: updatedStories));
  }
}
