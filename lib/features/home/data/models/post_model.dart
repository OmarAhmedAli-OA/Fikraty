import '../../domain/entities/post.dart';

class PostMediaModel extends PostMedia {
  const PostMediaModel({
    required super.id,
    required super.postId,
    required super.url,
    super.mediaType = MediaType.image,
    super.sortOrder = 0,
  });

  factory PostMediaModel.fromJson(Map<String, dynamic> json) {
    return PostMediaModel(
      id: json['id'] as int,
      postId: json['post_id'] as int,
      url: json['url'] as String,
      mediaType: MediaType.values.firstWhere(
        (e) => e.name == json['media_type'],
        orElse: () => MediaType.image,
      ),
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'post_id': postId,
        'url': url,
        'media_type': mediaType.name,
        'sort_order': sortOrder,
      };
}

class PollOptionModel extends PollOption {
  const PollOptionModel({
    required super.id,
    required super.pollId,
    required super.optionText,
    required super.voteCount,
  });

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    return PollOptionModel(
      id: json['id'] as int,
      pollId: json['poll_id'] as int,
      optionText: json['option_text'] as String,
      voteCount: json['vote_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'poll_id': pollId,
        'option_text': optionText,
        'vote_count': voteCount,
      };

  factory PollOptionModel.fromEntity(PollOption option) {
    return PollOptionModel(
      id: option.id,
      pollId: option.pollId,
      optionText: option.optionText,
      voteCount: option.voteCount,
    );
  }
}

class PollModel extends Poll {
  const PollModel({
    required super.id,
    required super.postId,
    required super.question,
    super.expiresAt,
    required super.totalVotes,
    required super.options,
    super.userVotedOptionId,
  });

  factory PollModel.fromJson(Map<String, dynamic> json) {
    return PollModel(
      id: json['id'] as int,
      postId: json['post_id'] as int,
      question: json['question'] as String,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      totalVotes: json['total_votes'] as int? ?? 0,
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => PollOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      userVotedOptionId: json['user_voted_option_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'post_id': postId,
        'question': question,
        'expires_at': expiresAt?.toIso8601String(),
        'total_votes': totalVotes,
        'options': options
            .map((e) => PollOptionModel.fromEntity(e).toJson())
            .toList(),
        'user_voted_option_id': userVotedOptionId,
      };

  factory PollModel.fromEntity(Poll poll) {
    return PollModel(
      id: poll.id,
      postId: poll.postId,
      question: poll.question,
      expiresAt: poll.expiresAt,
      totalVotes: poll.totalVotes,
      options: poll.options,
      userVotedOptionId: poll.userVotedOptionId,
    );
  }
}

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.postId,
    required super.authorUserId,
    required super.authorName,
    required super.authorRole,
    required super.authorAvatar,
    required super.content,
    super.likeCount = 0,
    super.isLiked = false,
    required super.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as int,
      postId: json['post_id'] as int,
      authorUserId: json['author_user_id'] as int,
      authorName: json['author_name'] as String,
      authorRole: json['author_role'] as String,
      authorAvatar: json['author_avatar'] as String,
      content: json['content'] as String,
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'post_id': postId,
        'author_user_id': authorUserId,
        'author_name': authorName,
        'author_role': authorRole,
        'author_avatar': authorAvatar,
        'content': content,
        'like_count': likeCount,
        'is_liked': isLiked,
        'created_at': createdAt.toIso8601String(),
      };

  factory CommentModel.fromEntity(Comment comment) {
    return CommentModel(
      id: comment.id,
      postId: comment.postId,
      authorUserId: comment.authorUserId,
      authorName: comment.authorName,
      authorRole: comment.authorRole,
      authorAvatar: comment.authorAvatar,
      content: comment.content,
      likeCount: comment.likeCount,
      isLiked: comment.isLiked,
      createdAt: comment.createdAt,
    );
  }
}

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.authorUserId,
    required super.authorName,
    required super.authorRole,
    required super.authorAvatar,
    super.isVerified = false,
    required super.postType,
    required super.content,
    super.tags = const [],
    super.media = const [],
    super.poll,
    super.likeCount = 0,
    super.commentCount = 0,
    super.shareCount = 0,
    super.isLiked = false,
    super.isBookmarked = false,
    required super.createdAt,
    super.comments = const [],
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int,
      authorUserId: json['author_user_id'] as int,
      authorName: json['author_name'] as String,
      authorRole: json['author_role'] as String,
      authorAvatar: json['author_avatar'] as String,
      isVerified: json['is_verified'] as bool? ?? false,
      postType: PostType.values.firstWhere(
        (e) => e.name == json['post_type'],
        orElse: () => PostType.update,
      ),
      content: json['content'] as String,
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      media: (json['media'] as List<dynamic>? ?? [])
          .map((e) => PostMediaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      poll: json['poll'] != null
          ? PollModel.fromJson(json['poll'] as Map<String, dynamic>)
          : null,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      shareCount: json['share_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'author_user_id': authorUserId,
        'author_name': authorName,
        'author_role': authorRole,
        'author_avatar': authorAvatar,
        'is_verified': isVerified,
        'post_type': postType.name,
        'content': content,
        'tags': tags,
        'media': media.map((e) => (e as PostMediaModel).toJson()).toList(),
        'poll': poll != null ? PollModel.fromEntity(poll!).toJson() : null,
        'like_count': likeCount,
        'comment_count': commentCount,
        'share_count': shareCount,
        'is_liked': isLiked,
        'is_bookmarked': isBookmarked,
        'created_at': createdAt.toIso8601String(),
        'comments': comments
            .map((e) => CommentModel.fromEntity(e).toJson())
            .toList(),
      };

  factory PostModel.fromEntity(Post post) {
    return PostModel(
      id: post.id,
      authorUserId: post.authorUserId,
      authorName: post.authorName,
      authorRole: post.authorRole,
      authorAvatar: post.authorAvatar,
      isVerified: post.isVerified,
      postType: post.postType,
      content: post.content,
      tags: post.tags,
      media: post.media,
      poll: post.poll,
      likeCount: post.likeCount,
      commentCount: post.commentCount,
      shareCount: post.shareCount,
      isLiked: post.isLiked,
      isBookmarked: post.isBookmarked,
      createdAt: post.createdAt,
      comments: post.comments,
    );
  }
}
