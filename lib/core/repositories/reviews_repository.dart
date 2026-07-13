import '../models/review_model.dart';
import '../models/comment_model.dart';

abstract class ReviewsRepository {
  Future<List<ReviewModel>> getMediaReviews(String mediaId);

  Future<void> writeReview(ReviewModel review);

  Future<void> updateReview(ReviewModel review);

  Future<void> deleteReview(String reviewId);

  Future<List<ReviewModel>> getUserReviews(String userId);

  Future<List<ReviewModel>> getPopularReviews({int limit = 10});

  // Like operations
  Future<void> likeReview(String userId, String reviewId);

  Future<void> unlikeReview(String userId, String reviewId);

  Future<bool> isReviewLiked(String userId, String reviewId);

  // Comment operations
  Future<List<CommentModel>> getReviewComments(String reviewId);

  Future<void> addComment(CommentModel comment);

  Future<void> deleteComment(String reviewId, String commentId);

  // Stats operations
  Future<Map<int, int>> getRatingDistribution(String mediaId);

  Future<double> getAverageCommunityRating(String mediaId);

  Future<int> getTotalRatingsCount(String mediaId);
}
