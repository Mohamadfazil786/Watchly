import '../models/review_model.dart';
import '../models/comment_model.dart';
import '../repositories/reviews_repository.dart';

class MockReviewsRepository implements ReviewsRepository {
  final List<ReviewModel> _reviews = [
    ReviewModel(
      id: 'rev_1',
      userId: 'user_1',
      username: 'alex_cinephile',
      userPhotoUrl: '',
      mediaId: '27205',
      mediaTitle: 'Inception',
      mediaPoster: '/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
      mediaType: 'movie',
      rating: 9.5,
      reviewText: 'A mind-bending masterpiece that rewards multiple viewings. Nolan at his absolute peak — the rotating hallway scene alone deserves an Oscar. The score by Hans Zimmer elevates every moment to pure cinema.',
      likesCount: 142,
      commentsCount: 18,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    ReviewModel(
      id: 'rev_2',
      userId: 'user_2',
      username: 'sara_watches',
      userPhotoUrl: '',
      mediaId: '157336',
      mediaTitle: 'Interstellar',
      mediaPoster: '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
      mediaType: 'movie',
      rating: 8.0,
      reviewText: 'Epic in scale and emotional in execution. The docking scene is one of the most tense sequences I\'ve ever witnessed. The third act is divisive but I find it hauntingly beautiful.',
      likesCount: 89,
      commentsCount: 24,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    ReviewModel(
      id: 'rev_3',
      userId: 'user_3',
      username: 'kai_reviews',
      userPhotoUrl: '',
      mediaId: '496243',
      mediaTitle: 'Parasite',
      mediaPoster: '/7IiTTgloROVKhWhzoXebK9joJeU.jpg',
      mediaType: 'movie',
      rating: 10.0,
      reviewText: 'A perfect film. Bong Joon-ho crafts a razor-sharp class commentary wrapped inside the most satisfying genre rollercoaster. Every frame is deliberate, every beat earned. Cinema.',
      likesCount: 234,
      commentsCount: 41,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    ReviewModel(
      id: 'rev_4',
      userId: 'user_1',
      username: 'alex_cinephile',
      userPhotoUrl: '',
      mediaId: '872585',
      mediaTitle: 'Oppenheimer',
      mediaPoster: '/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
      mediaType: 'movie',
      rating: 9.0,
      reviewText: 'Cillian Murphy delivers a career-defining performance. The Trinity test sequence is pure visceral cinema. Nolan proves he can do restrained, intimate storytelling while still being bombastic.',
      likesCount: 178,
      commentsCount: 32,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ReviewModel(
      id: 'rev_5',
      userId: 'user_2',
      username: 'sara_watches',
      userPhotoUrl: '',
      mediaId: 'tv_1396',
      mediaTitle: 'Breaking Bad',
      mediaPoster: '/ggFHVNu6YYI5L9pCfOacjizRGt.jpg',
      mediaType: 'tv',
      rating: 10.0,
      reviewText: 'The greatest television series ever made. Period. Walter White\'s transformation is the most compelling character arc in the history of the medium. Every season better than the last.',
      likesCount: 312,
      commentsCount: 67,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];

  final Map<String, List<CommentModel>> _comments = {
    'rev_1': [
      CommentModel(id: 'c1', reviewId: 'rev_1', userId: 'user_2', username: 'sara_watches', commentText: 'Totally agree! The limbo sequence is haunting.', createdAt: DateTime.now().subtract(const Duration(hours: 6))),
      CommentModel(id: 'c2', reviewId: 'rev_1', userId: 'user_3', username: 'kai_reviews', commentText: 'My favourite Nolan film. The ending still gives me chills.', createdAt: DateTime.now().subtract(const Duration(hours: 3))),
    ],
    'rev_3': [
      CommentModel(id: 'c3', reviewId: 'rev_3', userId: 'user_1', username: 'alex_cinephile', commentText: 'The stairs scene is on another level. Bong is a genius.', createdAt: DateTime.now().subtract(const Duration(hours: 8))),
    ],
  };

  final Set<String> _likes = {'user_2_rev_1', 'user_3_rev_1', 'user_1_rev_3'};

  @override
  Future<List<ReviewModel>> getMediaReviews(String mediaId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _reviews.where((r) => r.mediaId == mediaId).toList();
  }

  @override
  Future<void> writeReview(ReviewModel review) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _reviews.add(review);
  }

  @override
  Future<void> updateReview(ReviewModel review) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = _reviews.indexWhere((r) => r.id == review.id);
    if (idx != -1) _reviews[idx] = review;
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _reviews.removeWhere((r) => r.id == reviewId);
  }

  @override
  Future<List<ReviewModel>> getUserReviews(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _reviews.where((r) => r.userId == userId).toList();
  }

  @override
  Future<List<ReviewModel>> getPopularReviews({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final sorted = List<ReviewModel>.from(_reviews)
      ..sort((a, b) => b.likesCount.compareTo(a.likesCount));
    return sorted.take(limit).toList();
  }

  @override
  Future<void> likeReview(String userId, String reviewId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _likes.add('${userId}_$reviewId');
    final idx = _reviews.indexWhere((r) => r.id == reviewId);
    if (idx != -1) {
      _reviews[idx] = _reviews[idx].copyWith(likesCount: _reviews[idx].likesCount + 1);
    }
  }

  @override
  Future<void> unlikeReview(String userId, String reviewId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _likes.remove('${userId}_$reviewId');
    final idx = _reviews.indexWhere((r) => r.id == reviewId);
    if (idx != -1 && _reviews[idx].likesCount > 0) {
      _reviews[idx] = _reviews[idx].copyWith(likesCount: _reviews[idx].likesCount - 1);
    }
  }

  @override
  Future<bool> isReviewLiked(String userId, String reviewId) async {
    return _likes.contains('${userId}_$reviewId');
  }

  @override
  Future<List<CommentModel>> getReviewComments(String reviewId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _comments[reviewId] ?? [];
  }

  @override
  Future<void> addComment(CommentModel comment) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _comments.putIfAbsent(comment.reviewId, () => []).add(comment);
    final idx = _reviews.indexWhere((r) => r.id == comment.reviewId);
    if (idx != -1) {
      _reviews[idx] = _reviews[idx].copyWith(commentsCount: _reviews[idx].commentsCount + 1);
    }
  }

  @override
  Future<void> deleteComment(String reviewId, String commentId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _comments[reviewId]?.removeWhere((c) => c.id == commentId);
  }

  @override
  Future<Map<int, int>> getRatingDistribution(String mediaId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final reviews = _reviews.where((r) => r.mediaId == mediaId).toList();
    final Map<int, int> dist = {};
    for (int i = 1; i <= 10; i++) dist[i] = 0;
    for (final r in reviews) {
      final key = r.rating.round().clamp(1, 10);
      dist[key] = (dist[key] ?? 0) + 1;
    }
    // Add some mock distribution data
    if (dist.values.every((v) => v == 0)) {
      dist[7] = 3; dist[8] = 5; dist[9] = 8; dist[10] = 4; dist[6] = 2;
    }
    return dist;
  }

  @override
  Future<double> getAverageCommunityRating(String mediaId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final reviews = _reviews.where((r) => r.mediaId == mediaId).toList();
    if (reviews.isEmpty) return 7.8;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
  }

  @override
  Future<int> getTotalRatingsCount(String mediaId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _reviews.where((r) => r.mediaId == mediaId).length + 128;
  }
}
