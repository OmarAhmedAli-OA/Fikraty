import 'package:equatable/equatable.dart';
import '../../domain/entities/post.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeedEvent extends FeedEvent {
  final String? selectedTag;
  final bool isRefresh;

  const LoadFeedEvent({this.selectedTag, this.isRefresh = false});

  @override
  List<Object?> get props => [selectedTag, isRefresh];
}

class SelectTagEvent extends FeedEvent {
  final String tag;

  const SelectTagEvent(this.tag);

  @override
  List<Object?> get props => [tag];
}

class ToggleLikeEvent extends FeedEvent {
  final int postId;

  const ToggleLikeEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}

class ToggleBookmarkEvent extends FeedEvent {
  final int postId;

  const ToggleBookmarkEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}

class VotePollEvent extends FeedEvent {
  final int postId;
  final int pollOptionId;

  const VotePollEvent({required this.postId, required this.pollOptionId});

  @override
  List<Object?> get props => [postId, pollOptionId];
}

class CreatePostEvent extends FeedEvent {
  final String content;
  final PostType postType;
  final List<String> tags;
  final List<String> mediaUrls;
  final String? pollQuestion;
  final List<String>? pollOptions;

  const CreatePostEvent({
    required this.content,
    required this.postType,
    this.tags = const [],
    this.mediaUrls = const [],
    this.pollQuestion,
    this.pollOptions,
  });

  @override
  List<Object?> get props => [
        content,
        postType,
        tags,
        mediaUrls,
        pollQuestion,
        pollOptions,
      ];
}

class AddCommentEvent extends FeedEvent {
  final int postId;
  final String content;

  const AddCommentEvent({required this.postId, required this.content});

  @override
  List<Object?> get props => [postId, content];
}

class ToggleCommentLikeEvent extends FeedEvent {
  final int postId;
  final int commentId;

  const ToggleCommentLikeEvent({required this.postId, required this.commentId});

  @override
  List<Object?> get props => [postId, commentId];
}

class AddStoryEvent extends FeedEvent {
  final String caption;
  final String imageUrl;

  const AddStoryEvent({required this.caption, required this.imageUrl});

  @override
  List<Object?> get props => [caption, imageUrl];
}

class MarkStoryAsViewedEvent extends FeedEvent {
  final int storyId;

  const MarkStoryAsViewedEvent(this.storyId);

  @override
  List<Object?> get props => [storyId];
}
