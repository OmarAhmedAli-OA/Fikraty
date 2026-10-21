import '../entities/post.dart';

abstract class FeedRepository {
  /// Fetches posts for the feed, optionally filtered by tag or type
  Future<List<Post>> getFeed({String? tag, PostType? type});

  /// Fetches top stories
  Future<List<Story>> getStories();

  /// Fetches recommended investors matching user profile
  Future<List<RecommendedInvestor>> getRecommendedInvestors();

  /// Toggle like on a post (post_likes)
  Future<Post> toggleLike(int postId);

  /// Toggle bookmark on a post (user_bookmarks)
  Future<Post> toggleBookmark(int postId);

  /// Vote on a poll option (poll_votes)
  Future<Post> votePoll(int postId, int pollOptionId);

  /// Create a new post (posts, post_tags, post_media, polls)
  Future<Post> createPost({
    required String content,
    required PostType postType,
    List<String>? tags,
    List<String>? mediaUrls,
    String? pollQuestion,
    List<String>? pollOptions,
  });

  /// Add a comment to a post (comments)
  Future<Comment> addComment({
    required int postId,
    required String content,
  });

  /// Toggle like on a comment
  Future<Comment> toggleCommentLike({
    required int postId,
    required int commentId,
  });

  /// Add a new story to stories tray
  Future<Story> addStory({
    required String caption,
    required String imageUrl,
  });
}
