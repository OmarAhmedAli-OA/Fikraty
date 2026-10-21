import 'package:equatable/equatable.dart';

enum PostType {
  update,
  milestone,
  launch,
  funding,
  founderStory,
  insight,
  opportunity,
  discussion,
  question,
  poll;

  String get displayName {
    switch (this) {
      case PostType.funding:
        return 'Funding';
      case PostType.insight:
      case PostType.founderStory:
        return 'Insight';
      case PostType.opportunity:
        return 'Opportunity';
      case PostType.milestone:
        return 'Milestone';
      case PostType.poll:
        return 'Poll';
      case PostType.launch:
        return 'Launch';
      case PostType.update:
        return 'Update';
      case PostType.discussion:
        return 'Discussion';
      case PostType.question:
        return 'Question';
    }
  }
}

enum ContentStatus { draft, published, hidden, removed }

enum MediaType {
  logo,
  coverPhoto,
  image,
  pitchDeck,
  demoVideo,
  businessDocument,
}

class PostMedia extends Equatable {
  final int id;
  final int postId;
  final String url;
  final MediaType mediaType;
  final int sortOrder;

  const PostMedia({
    required this.id,
    required this.postId,
    required this.url,
    this.mediaType = MediaType.image,
    this.sortOrder = 0,
  });

  @override
  List<Object?> get props => [id, postId, url, mediaType, sortOrder];
}

class PollOption extends Equatable {
  final int id;
  final int pollId;
  final String optionText;
  final int voteCount;

  const PollOption({
    required this.id,
    required this.pollId,
    required this.optionText,
    required this.voteCount,
  });

  PollOption copyWith({int? voteCount}) {
    return PollOption(
      id: id,
      pollId: pollId,
      optionText: optionText,
      voteCount: voteCount ?? this.voteCount,
    );
  }

  @override
  List<Object?> get props => [id, pollId, optionText, voteCount];
}

class Poll extends Equatable {
  final int id;
  final int postId;
  final String question;
  final DateTime? expiresAt;
  final int totalVotes;
  final List<PollOption> options;
  final int? userVotedOptionId;

  const Poll({
    required this.id,
    required this.postId,
    required this.question,
    this.expiresAt,
    required this.totalVotes,
    required this.options,
    this.userVotedOptionId,
  });

  Poll copyWith({
    int? totalVotes,
    List<PollOption>? options,
    int? userVotedOptionId,
  }) {
    return Poll(
      id: id,
      postId: postId,
      question: question,
      expiresAt: expiresAt,
      totalVotes: totalVotes ?? this.totalVotes,
      options: options ?? this.options,
      userVotedOptionId: userVotedOptionId ?? this.userVotedOptionId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        postId,
        question,
        expiresAt,
        totalVotes,
        options,
        userVotedOptionId,
      ];
}

class Comment extends Equatable {
  final int id;
  final int postId;
  final int authorUserId;
  final String authorName;
  final String authorRole;
  final String authorAvatar;
  final String content;
  final int likeCount;
  final bool isLiked;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.postId,
    required this.authorUserId,
    required this.authorName,
    required this.authorRole,
    required this.authorAvatar,
    required this.content,
    this.likeCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  Comment copyWith({
    int? likeCount,
    bool? isLiked,
  }) {
    return Comment(
      id: id,
      postId: postId,
      authorUserId: authorUserId,
      authorName: authorName,
      authorRole: authorRole,
      authorAvatar: authorAvatar,
      content: content,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        postId,
        authorUserId,
        authorName,
        authorRole,
        authorAvatar,
        content,
        likeCount,
        isLiked,
        createdAt,
      ];
}

class Post extends Equatable {
  final int id;
  final int authorUserId;
  final String authorName;
  final String authorRole;
  final String authorAvatar;
  final bool isVerified;
  final PostType postType;
  final String content;
  final List<String> tags;
  final List<PostMedia> media;
  final Poll? poll;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;
  final bool isBookmarked;
  final DateTime createdAt;
  final List<Comment> comments;

  const Post({
    required this.id,
    required this.authorUserId,
    required this.authorName,
    required this.authorRole,
    required this.authorAvatar,
    this.isVerified = false,
    required this.postType,
    required this.content,
    this.tags = const [],
    this.media = const [],
    this.poll,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    required this.createdAt,
    this.comments = const [],
  });

  Post copyWith({
    int? likeCount,
    int? commentCount,
    int? shareCount,
    bool? isLiked,
    bool? isBookmarked,
    Poll? poll,
    List<Comment>? comments,
  }) {
    return Post(
      id: id,
      authorUserId: authorUserId,
      authorName: authorName,
      authorRole: authorRole,
      authorAvatar: authorAvatar,
      isVerified: isVerified,
      postType: postType,
      content: content,
      tags: tags,
      media: media,
      poll: poll ?? this.poll,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt,
      comments: comments ?? this.comments,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorUserId,
        authorName,
        authorRole,
        authorAvatar,
        isVerified,
        postType,
        content,
        tags,
        media,
        poll,
        likeCount,
        commentCount,
        shareCount,
        isLiked,
        isBookmarked,
        createdAt,
        comments,
      ];
}

class Story extends Equatable {
  final int id;
  final String name;
  final String avatarUrl;
  final String storyImageUrl;
  final String caption;
  final DateTime createdAt;
  final bool isUserStory;
  final bool hasUnviewed;
  final int viewsCount;
  final List<String> slides;
  final List<String> slideCaptions;
  final bool isLiked;

  const Story({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.storyImageUrl,
    required this.caption,
    required this.createdAt,
    this.isUserStory = false,
    this.hasUnviewed = true,
    this.viewsCount = 142,
    this.slides = const [],
    this.slideCaptions = const [],
    this.isLiked = false,
  });

  String getSlideCaption(int index) {
    if (slideCaptions.isNotEmpty && index >= 0 && index < slideCaptions.length) {
      return slideCaptions[index];
    }
    return caption;
  }

  Story copyWith({
    int? id,
    String? name,
    String? avatarUrl,
    String? storyImageUrl,
    String? caption,
    DateTime? createdAt,
    bool? isUserStory,
    bool? hasUnviewed,
    int? viewsCount,
    List<String>? slides,
    List<String>? slideCaptions,
    bool? isLiked,
  }) {
    return Story(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      storyImageUrl: storyImageUrl ?? this.storyImageUrl,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      isUserStory: isUserStory ?? this.isUserStory,
      hasUnviewed: hasUnviewed ?? this.hasUnviewed,
      viewsCount: viewsCount ?? this.viewsCount,
      slides: slides ?? this.slides,
      slideCaptions: slideCaptions ?? this.slideCaptions,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        avatarUrl,
        storyImageUrl,
        caption,
        createdAt,
        isUserStory,
        hasUnviewed,
        viewsCount,
        slides,
        slideCaptions,
        isLiked,
      ];
}

class RecommendedInvestor extends Equatable {
  final int id;
  final String name;
  final String role;
  final String avatarUrl;
  final int matchPercentage;

  const RecommendedInvestor({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.matchPercentage,
  });

  @override
  List<Object?> get props => [id, name, role, avatarUrl, matchPercentage];
}
