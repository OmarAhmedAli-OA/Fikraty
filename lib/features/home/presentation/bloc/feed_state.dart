import 'package:equatable/equatable.dart';
import '../../domain/entities/post.dart';

abstract class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}

class FeedInitialState extends FeedState {}

class FeedLoadingState extends FeedState {}

class FeedLoadedState extends FeedState {
  final List<Post> posts;
  final List<Story> stories;
  final List<RecommendedInvestor> recommendedInvestors;
  final String selectedTag;
  final bool isCreatingPost;
  final String? actionFeedbackMessage;

  const FeedLoadedState({
    required this.posts,
    required this.stories,
    required this.recommendedInvestors,
    this.selectedTag = 'All',
    this.isCreatingPost = false,
    this.actionFeedbackMessage,
  });

  FeedLoadedState copyWith({
    List<Post>? posts,
    List<Story>? stories,
    List<RecommendedInvestor>? recommendedInvestors,
    String? selectedTag,
    bool? isCreatingPost,
    String? actionFeedbackMessage,
  }) {
    return FeedLoadedState(
      posts: posts ?? this.posts,
      stories: stories ?? this.stories,
      recommendedInvestors:
          recommendedInvestors ?? this.recommendedInvestors,
      selectedTag: selectedTag ?? this.selectedTag,
      isCreatingPost: isCreatingPost ?? this.isCreatingPost,
      actionFeedbackMessage: actionFeedbackMessage,
    );
  }

  @override
  List<Object?> get props => [
        posts,
        stories,
        recommendedInvestors,
        selectedTag,
        isCreatingPost,
        actionFeedbackMessage,
      ];
}

class FeedEmptyState extends FeedState {
  final String message;
  final List<Story> stories;

  const FeedEmptyState({
    this.message = 'No startup posts found for this filter.',
    this.stories = const [],
  });

  @override
  List<Object?> get props => [message, stories];
}

class FeedErrorState extends FeedState {
  final String errorMessage;

  const FeedErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
