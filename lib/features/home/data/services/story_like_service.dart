class StoryLikeService {
  StoryLikeService._();
  static final StoryLikeService instance = StoryLikeService._();

  // Stores '${storyId}_$slideIndex' for each individual slide!
  final Set<String> _likedSlideKeys = {};

  String _getKey(int storyId, int slideIndex) => '${storyId}_$slideIndex';

  bool isSlideLiked(int storyId, int slideIndex) {
    return _likedSlideKeys.contains(_getKey(storyId, slideIndex));
  }

  bool toggleSlideLike(int storyId, int slideIndex) {
    final key = _getKey(storyId, slideIndex);
    if (_likedSlideKeys.contains(key)) {
      _likedSlideKeys.remove(key);
      return false;
    } else {
      _likedSlideKeys.add(key);
      return true;
    }
  }

  void setSlideLiked(int storyId, int slideIndex, bool liked) {
    final key = _getKey(storyId, slideIndex);
    if (liked) {
      _likedSlideKeys.add(key);
    } else {
      _likedSlideKeys.remove(key);
    }
  }

  // Backwards compatibility if called with just storyId (maps to slide 0)
  bool isLiked(int storyId) => isSlideLiked(storyId, 0);

  bool toggleLike(int storyId) => toggleSlideLike(storyId, 0);

  Set<String> get likedSlideKeys => Set.unmodifiable(_likedSlideKeys);
}
