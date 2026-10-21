import '../models/post_model.dart';
import '../../domain/entities/post.dart';
import '../services/story_like_service.dart';

abstract class FeedLocalDataSource {
  Future<List<PostModel>> getFeed({String? tag, PostType? type});
  Future<List<Story>> getStories();
  Future<List<RecommendedInvestor>> getRecommendedInvestors();
  Future<PostModel> toggleLike(int postId);
  Future<PostModel> toggleBookmark(int postId);
  Future<PostModel> votePoll(int postId, int pollOptionId);
  Future<PostModel> createPost({
    required String content,
    required PostType postType,
    List<String>? tags,
    List<String>? mediaUrls,
    String? pollQuestion,
    List<String>? pollOptions,
  });
  Future<CommentModel> addComment({
    required int postId,
    required String content,
  });
  Future<CommentModel> toggleCommentLike({
    required int postId,
    required int commentId,
  });
  Future<Story> addStory({
    required String caption,
    required String imageUrl,
  });
}

class FeedLocalDataSourceImpl implements FeedLocalDataSource {
  // In-memory mock database preserving state during app session
  final List<PostModel> _posts = [];
  final List<Story> _stories = [];
  final List<RecommendedInvestor> _recommendedInvestors = [];

  FeedLocalDataSourceImpl() {
    _initMockData();
  }

  void _initMockData() {
    // Stories matching Figma (Image 1 & 2)
    _stories.addAll([
      Story(
        id: 0,
        name: 'Your Story',
        avatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        storyImageUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
        caption: 'Share your startup journey with the community',
        createdAt: DateTime.now(),
        isUserStory: true,
        hasUnviewed: false,
        viewsCount: 0,
        slides: const [],
        slideCaptions: const [],
      ),
      Story(
        id: 1,
        name: 'NovaMed AI',
        avatarUrl:
            'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=150',
        storyImageUrl:
            'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800',
        caption:
            'We just closed our Seed round 🚀 \$2.4M to revolutionize AI diagnostics in MENA clinics.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isUserStory: false,
        hasUnviewed: true,
        viewsCount: 524,
        slides: const [
          'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800',
          'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?w=800',
        ],
        slideCaptions: const [
          'We just closed our Seed round 🚀 \$2.4M to revolutionize AI diagnostics in MENA clinics.',
          'Welcoming our lead investors from Sanabil & 500 Global aboard! 🎉',
        ],
      ),
      Story(
        id: 2,
        name: 'GreenStack',
        avatarUrl:
            'https://images.unsplash.com/photo-1509391365360-2e959784a276?w=150',
        storyImageUrl:
            'https://images.unsplash.com/photo-1497435334941-8c899ee9e8e9?w=800',
        caption: 'Scaling clean solar tech to 50+ new agricultural sites.',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        isUserStory: false,
        hasUnviewed: true,
        viewsCount: 312,
        slides: const [
          'https://images.unsplash.com/photo-1497435334941-8c899ee9e8e9?w=800',
        ],
        slideCaptions: const [
          'Scaling clean solar tech to 50+ new agricultural sites.',
        ],
      ),
      Story(
        id: 3,
        name: 'Wamda',
        avatarUrl:
            'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=150',
        storyImageUrl:
            'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800',
        caption: 'Q3 Venture Capital Report is now live! Read key highlights.',
        createdAt: DateTime.now().subtract(const Duration(hours: 7)),
        isUserStory: false,
        hasUnviewed: true,
        viewsCount: 890,
        slides: const [
          'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800',
          'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=800',
        ],
      ),
      Story(
        id: 4,
        name: 'FlowSync',
        avatarUrl:
            'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
        storyImageUrl:
            'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800',
        caption: 'Automated 100K workflows this month alone! 📈',
        createdAt: DateTime.now().subtract(const Duration(hours: 9)),
        isUserStory: false,
        hasUnviewed: false,
        viewsCount: 174,
        slides: const [
          'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800',
        ],
      ),
    ]);

    // Recommended Investors matching Figma (Image 4)
    _recommendedInvestors.addAll([
      const RecommendedInvestor(
        id: 101,
        name: 'Omar Khalil',
        role: 'Principal · Wamda Capital',
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        matchPercentage: 92,
      ),
      const RecommendedInvestor(
        id: 102,
        name: 'Ingrid Larsen',
        role: 'Partner · Nordic Ventures',
        avatarUrl:
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
        matchPercentage: 85,
      ),
    ]);

    // Posts matching Figma screenshots 1, 3, 4
    _posts.addAll([
      // Post 1: Sarah Al-Mansouri (Funding)
      PostModel(
        id: 1,
        authorUserId: 10,
        authorName: 'Sarah Al-Mansouri',
        authorRole: 'Founder & CEO · NovaMed AI',
        authorAvatar:
            'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=150',
        isVerified: true,
        postType: PostType.funding,
        content:
            'Thrilled to announce NovaMed AI has just closed our Seed round — \$2.4M led by Sequoia Arabia. Building AI diagnostics for underserved clinics across MENA. This is just the beginning.',
        tags: const ['#SeedRound', '#AIStartups', '#HealthTech', '#MENA'],
        likeCount: 284,
        commentCount: 47,
        shareCount: 19,
        isLiked: false,
        isBookmarked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        comments: [
          CommentModel(
            id: 1001,
            postId: 1,
            authorUserId: 101,
            authorName: 'Omar Khalil',
            authorRole: 'Principal @ Wamda Capital',
            authorAvatar:
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
            content:
                'This is exactly the kind of insight MENA founders need. The regulatory landscape has shifted dramatically and most early-stage teams underestimate compliance costs in their runway planning.',
            likeCount: 14,
            isLiked: false,
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          CommentModel(
            id: 1002,
            postId: 1,
            authorUserId: 103,
            authorName: 'Lena Bergström',
            authorRole: 'CEO @ GreenStack',
            authorAvatar:
                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
            content:
                'We learned this the hard way when entering the EU market. Adding a dedicated compliance advisor early saved us 6 months of headache.',
            likeCount: 8,
            isLiked: false,
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          CommentModel(
            id: 1003,
            postId: 1,
            authorUserId: 104,
            authorName: 'Youssef El-Shenawy',
            authorRole: 'Investment Analyst',
            authorAvatar:
                'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
            content:
                'Congratulations Sarah! Inspiring milestone for the whole regional ecosystem.',
            likeCount: 5,
            isLiked: false,
            createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
          ),
        ],
      ),

      // Post 2: Omar Khalil (Insight + Dashboard Media)
      PostModel(
        id: 2,
        authorUserId: 101,
        authorName: 'Omar Khalil',
        authorRole: 'Principal · Wamda Capital',
        authorAvatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        isVerified: true,
        postType: PostType.insight,
        content:
            'What I look for in a founder pitch: clarity of problem, size of opportunity and unfair advantage. The deck is just a conversation starter — the founder\'s grasp on unit economics and retention metrics is what closes the check.',
        tags: const ['#FinTech', '#Fundraising', '#Founders'],
        media: const [
          PostMediaModel(
            id: 201,
            postId: 2,
            url:
                'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800',
            mediaType: MediaType.image,
            sortOrder: 1,
          ),
        ],
        likeCount: 921,
        commentCount: 134,
        shareCount: 52,
        isLiked: false,
        isBookmarked: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        comments: [
          CommentModel(
            id: 2001,
            postId: 2,
            authorUserId: 105,
            authorName: 'Nouran Mostafa',
            authorRole: 'Product Lead @ PayFast',
            authorAvatar:
                'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
            content:
                'Completely agree. Vanity metrics will never replace true cohort retention.',
            likeCount: 22,
            isLiked: true,
            createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          ),
        ],
      ),

      // Post 3: Interactive Poll Post (ARD Table: polls, poll_options, poll_votes)
      PostModel(
        id: 3,
        authorUserId: 108,
        authorName: 'Dr. Khaled Fawzy',
        authorRole: 'Co-Founder & CTO · HealthSync',
        authorAvatar:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        isVerified: true,
        postType: PostType.poll,
        content:
            'MENA Founders: As you scale tech operations in 2026, what has been your most critical hurdle?',
        tags: const ['#AIStartups', '#TechTalent', '#Founders'],
        poll: const PollModel(
          id: 301,
          postId: 3,
          question: 'What is your biggest operational bottleneck right now?',
          totalVotes: 320,
          options: [
            PollOptionModel(
              id: 1,
              pollId: 301,
              optionText: 'Acquiring high-quality localized data',
              voteCount: 138,
            ),
            PollOptionModel(
              id: 2,
              pollId: 301,
              optionText: 'Retaining senior engineering talent',
              voteCount: 104,
            ),
            PollOptionModel(
              id: 3,
              pollId: 301,
              optionText: 'Local regulatory & cross-border compliance',
              voteCount: 52,
            ),
            PollOptionModel(
              id: 4,
              pollId: 301,
              optionText: 'GPU cloud & compute infrastructure costs',
              voteCount: 26,
            ),
          ],
          userVotedOptionId: null,
        ),
        likeCount: 145,
        commentCount: 28,
        shareCount: 11,
        isLiked: false,
        isBookmarked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        comments: const [],
      ),

      // Post 4: Tariq Hassan (Opportunity)
      PostModel(
        id: 4,
        authorUserId: 109,
        authorName: 'Tariq Hassan',
        authorRole: 'Angel Investor · Independent',
        authorAvatar:
            'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
        isVerified: false,
        postType: PostType.opportunity,
        content:
            'Open to co-investing in Series A rounds across EdTech and FinTech. DM me if your startup crossed \$500K ARR and is looking for a hands-on angel with GTM experience.',
        tags: const ['#FinTech', '#EdTech', '#Opportunity'],
        likeCount: 178,
        commentCount: 31,
        shareCount: 14,
        isLiked: false,
        isBookmarked: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        comments: const [],
      ),
    ]);
  }

  @override
  Future<List<PostModel>> getFeed({String? tag, PostType? type}) async {
    // Simulate real network delay for UX
    await Future.delayed(const Duration(milliseconds: 300));
    var result = List<PostModel>.from(_posts);

    if (tag != null && tag.isNotEmpty && tag != 'All') {
      result = result.where((p) => p.tags.contains(tag)).toList();
    }

    if (type != null) {
      result = result.where((p) => p.postType == type).toList();
    }

    return result;
  }

  @override
  Future<List<Story>> getStories() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _stories
        .map((s) => s.copyWith(isLiked: StoryLikeService.instance.isSlideLiked(s.id, 0)))
        .toList();
  }

  @override
  Future<List<RecommendedInvestor>> getRecommendedInvestors() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List<RecommendedInvestor>.from(_recommendedInvestors);
  }

  @override
  Future<PostModel> toggleLike(int postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) throw Exception('Post not found');

    final post = _posts[index];
    final isLiked = !post.isLiked;
    final likeCount = isLiked ? post.likeCount + 1 : post.likeCount - 1;

    final updated = PostModel.fromEntity(
      post.copyWith(
        isLiked: isLiked,
        likeCount: likeCount < 0 ? 0 : likeCount,
      ),
    );

    _posts[index] = updated;
    return updated;
  }

  @override
  Future<PostModel> toggleBookmark(int postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) throw Exception('Post not found');

    final post = _posts[index];
    final updated = PostModel.fromEntity(
      post.copyWith(isBookmarked: !post.isBookmarked),
    );

    _posts[index] = updated;
    return updated;
  }

  @override
  Future<PostModel> votePoll(int postId, int pollOptionId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) throw Exception('Post not found');

    final post = _posts[index];
    if (post.poll == null) throw Exception('No poll found on post');

    final poll = post.poll!;
    if (poll.userVotedOptionId != null) {
      // Already voted
      return post;
    }

    final updatedOptions = poll.options.map((opt) {
      if (opt.id == pollOptionId) {
        return opt.copyWith(voteCount: opt.voteCount + 1);
      }
      return opt;
    }).toList();

    final updatedPoll = poll.copyWith(
      totalVotes: poll.totalVotes + 1,
      options: updatedOptions,
      userVotedOptionId: pollOptionId,
    );

    final updatedPost = PostModel.fromEntity(
      post.copyWith(poll: updatedPoll),
    );

    _posts[index] = updatedPost;
    return updatedPost;
  }

  @override
  Future<PostModel> createPost({
    required String content,
    required PostType postType,
    List<String>? tags,
    List<String>? mediaUrls,
    String? pollQuestion,
    List<String>? pollOptions,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newId = DateTime.now().millisecondsSinceEpoch;

    PollModel? poll;
    if (postType == PostType.poll &&
        pollQuestion != null &&
        pollOptions != null &&
        pollOptions.isNotEmpty) {
      poll = PollModel(
        id: newId + 10,
        postId: newId,
        question: pollQuestion,
        totalVotes: 0,
        options: pollOptions
            .asMap()
            .entries
            .map(
              (e) => PollOptionModel(
                id: e.key + 1,
                pollId: newId + 10,
                optionText: e.value,
                voteCount: 0,
              ),
            )
            .toList(),
      );
    }

    final List<PostMediaModel> media = [];
    if (mediaUrls != null) {
      for (int i = 0; i < mediaUrls.length; i++) {
        final u = mediaUrls[i].toLowerCase();
        final isPdf = u.endsWith('.pdf') || u.contains('.pdf');
        final isDoc = u.endsWith('.doc') || u.endsWith('.docx') || u.endsWith('.xls') || u.endsWith('.xlsx') || u.endsWith('.txt');
        final mediaType = isPdf
            ? MediaType.businessDocument
            : (isDoc ? MediaType.businessDocument : MediaType.image);

        media.add(
          PostMediaModel(
            id: newId + 20 + i,
            postId: newId,
            url: mediaUrls[i],
            mediaType: mediaType,
            sortOrder: i,
          ),
        );
      }
    }

    final newPost = PostModel(
      id: newId,
      authorUserId: 999,
      authorName: 'You (Founder)',
      authorRole: 'Founder @ Fikraty Startup',
      authorAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      isVerified: true,
      postType: postType,
      content: content,
      tags: tags ?? ['#StartupUpdate'],
      media: media,
      poll: poll,
      likeCount: 0,
      commentCount: 0,
      shareCount: 0,
      isLiked: false,
      isBookmarked: false,
      createdAt: DateTime.now(),
      comments: const [],
    );

    _posts.insert(0, newPost);
    return newPost;
  }

  @override
  Future<CommentModel> addComment({
    required int postId,
    required String content,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) throw Exception('Post not found');

    final post = _posts[index];
    final commentId = DateTime.now().millisecondsSinceEpoch;

    final newComment = CommentModel(
      id: commentId,
      postId: postId,
      authorUserId: 999,
      authorName: 'You (Founder)',
      authorRole: 'Founder @ Fikraty Startup',
      authorAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      content: content,
      likeCount: 0,
      isLiked: false,
      createdAt: DateTime.now(),
    );

    final updatedComments = List<Comment>.from(post.comments)..add(newComment);
    final updatedPost = PostModel.fromEntity(
      post.copyWith(
        comments: updatedComments,
        commentCount: post.commentCount + 1,
      ),
    );

    _posts[index] = updatedPost;
    return newComment;
  }

  @override
  Future<CommentModel> toggleCommentLike({
    required int postId,
    required int commentId,
  }) async {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) throw Exception('Post not found');

    final post = _posts[postIndex];
    final commentIndex = post.comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) throw Exception('Comment not found');

    final comment = post.comments[commentIndex];
    final isLiked = !comment.isLiked;
    final likeCount = isLiked ? comment.likeCount + 1 : comment.likeCount - 1;

    final updatedComment = CommentModel.fromEntity(
      comment.copyWith(
        isLiked: isLiked,
        likeCount: likeCount < 0 ? 0 : likeCount,
      ),
    );

    final newComments = List<Comment>.from(post.comments);
    newComments[commentIndex] = updatedComment;

    _posts[postIndex] = PostModel.fromEntity(
      post.copyWith(comments: newComments),
    );

    return updatedComment;
  }

  @override
  Future<Story> addStory({
    required String caption,
    required String imageUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final existingIdx = _stories.indexWhere((s) => s.isUserStory || s.name == 'Your Story');
    if (existingIdx != -1) {
      final existing = _stories[existingIdx];
      final List<String> updatedSlides = [];
      final List<String> updatedCaptions = [];

      if (existing.slides.isNotEmpty) {
        updatedSlides.addAll(existing.slides);
        if (existing.slideCaptions.isNotEmpty) {
          updatedCaptions.addAll(existing.slideCaptions);
          while (updatedCaptions.length < existing.slides.length) {
            updatedCaptions.add(existing.caption);
          }
        } else {
          updatedCaptions.addAll(List.filled(existing.slides.length, existing.caption));
        }
      }

      updatedSlides.add(imageUrl);
      updatedCaptions.add(caption);

      final updated = existing.copyWith(
        id: existing.id == 0 ? DateTime.now().millisecondsSinceEpoch : existing.id,
        storyImageUrl: imageUrl,
        slides: updatedSlides,
        slideCaptions: updatedCaptions,
        caption: caption,
        hasUnviewed: false,
        isUserStory: true,
        viewsCount: existing.viewsCount, // Keep same views count! Never increment on self-upload
        createdAt: DateTime.now(),
      );
      _stories[existingIdx] = updated;
      return updated;
    } else {
      final newStory = Story(
        id: DateTime.now().millisecondsSinceEpoch,
        name: 'Your Story',
        avatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        storyImageUrl: imageUrl,
        caption: caption,
        createdAt: DateTime.now(),
        isUserStory: true,
        hasUnviewed: false,
        viewsCount: 0, // Starts at 0 views
        slides: [imageUrl],
        slideCaptions: [caption],
      );
      _stories.insert(0, newStory);
      return newStory;
    }
  }
}
