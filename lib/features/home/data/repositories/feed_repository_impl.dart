import '../../domain/entities/post.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_local_data_source.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedLocalDataSource localDataSource;

  FeedRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Post>> getFeed({String? tag, PostType? type}) async {
    return await localDataSource.getFeed(tag: tag, type: type);
  }

  @override
  Future<List<Story>> getStories() async {
    return await localDataSource.getStories();
  }

  @override
  Future<List<RecommendedInvestor>> getRecommendedInvestors() async {
    return await localDataSource.getRecommendedInvestors();
  }

  @override
  Future<Post> toggleLike(int postId) async {
    return await localDataSource.toggleLike(postId);
  }

  @override
  Future<Post> toggleBookmark(int postId) async {
    return await localDataSource.toggleBookmark(postId);
  }

  @override
  Future<Post> votePoll(int postId, int pollOptionId) async {
    return await localDataSource.votePoll(postId, pollOptionId);
  }

  @override
  Future<Post> createPost({
    required String content,
    required PostType postType,
    List<String>? tags,
    List<String>? mediaUrls,
    String? pollQuestion,
    List<String>? pollOptions,
  }) async {
    return await localDataSource.createPost(
      content: content,
      postType: postType,
      tags: tags,
      mediaUrls: mediaUrls,
      pollQuestion: pollQuestion,
      pollOptions: pollOptions,
    );
  }

  @override
  Future<Comment> addComment({
    required int postId,
    required String content,
  }) async {
    return await localDataSource.addComment(
      postId: postId,
      content: content,
    );
  }

  @override
  Future<Comment> toggleCommentLike({
    required int postId,
    required int commentId,
  }) async {
    return await localDataSource.toggleCommentLike(
      postId: postId,
      commentId: commentId,
    );
  }

  @override
  Future<Story> addStory({
    required String caption,
    required String imageUrl,
  }) async {
    return await localDataSource.addStory(
      caption: caption,
      imageUrl: imageUrl,
    );
  }
}
