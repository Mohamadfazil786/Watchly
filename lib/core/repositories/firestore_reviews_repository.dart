import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import '../models/comment_model.dart';
import '../repositories/reviews_repository.dart';

class FirestoreReviewsRepository implements ReviewsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Reviews ────────────────────────────────────────────────────────────────

  @override
  Future<List<ReviewModel>> getMediaReviews(String mediaId) async {
    final snap = await _db
        .collection('reviews')
        .where('mediaId', isEqualTo: mediaId)
        .get();
    final reviews = snap.docs.map((d) => ReviewModel.fromMap(d.data())).toList();
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews;
  }

  @override
  Future<void> writeReview(ReviewModel review) async {
    await _db.collection('reviews').doc(review.id).set(review.toMap());
    // Increment user review count
    await _db.collection('users').doc(review.userId).set({
      'reviewsCount': FieldValue.increment(1),
    }, SetOptions(merge: true));

    // ── Notify all followers of this reviewer ──────────────────────────────────
    try {
      final followersSnap = await _db
          .collection('followers')
          .where('followingUid', isEqualTo: review.userId)
          .get();

      if (followersSnap.docs.isNotEmpty) {
        // Chunk into batches of 500 (Firestore limit)
        final followerIds = followersSnap.docs
            .map((d) => d.data()['followerUid'] as String?)
            .whereType<String>()
            .toList();

        final chunks = <List<String>>[];
        for (int i = 0; i < followerIds.length; i += 400) {
          chunks.add(followerIds.sublist(
            i,
            i + 400 > followerIds.length ? followerIds.length : i + 400,
          ));
        }

        for (final chunk in chunks) {
          final batch = _db.batch();
          for (final followerId in chunk) {
            final ref = _db.collection('notifications').doc();
            batch.set(ref, {
              'receiverId': followerId,
              'senderId': review.userId,
              'senderName': review.username,
              'senderPhotoUrl': review.userPhotoUrl,
              'type': 'review',
              'targetId': review.mediaId,
              'message': '@${review.username} reviewed ${review.mediaTitle}',
              'isRead': false,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
          await batch.commit();
        }
      }
    } catch (_) {
      // Notification failure must never break the review submission
    }
  }


  @override
  Future<void> updateReview(ReviewModel review) async {
    await _db.collection('reviews').doc(review.id).update({
      'rating': review.rating,
      'reviewText': review.reviewText,
      'updatedAt': review.updatedAt.toIso8601String(),
    });
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    final doc = await _db.collection('reviews').doc(reviewId).get();
    if (doc.exists) {
      final userId = doc.data()?['userId'] as String?;
      await _db.collection('reviews').doc(reviewId).delete();
      if (userId != null) {
        await _db.collection('users').doc(userId).set({
          'reviewsCount': FieldValue.increment(-1),
        }, SetOptions(merge: true));
      }
    }
  }

  @override
  Future<List<ReviewModel>> getUserReviews(String userId) async {
    final snap = await _db
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .get();
    final reviews = snap.docs.map((d) => ReviewModel.fromMap(d.data())).toList();
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews;
  }

  @override
  Future<List<ReviewModel>> getPopularReviews({int limit = 10}) async {
    final snap = await _db
        .collection('reviews')
        .orderBy('likesCount', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => ReviewModel.fromMap(d.data())).toList();
  }

  // ─── Likes ──────────────────────────────────────────────────────────────────

  @override
  Future<void> likeReview(String userId, String reviewId) async {
    final likeId = '${userId}_$reviewId';
    final batch = _db.batch();
    batch.set(_db.collection('likes').doc(likeId), {
      'userId': userId,
      'reviewId': reviewId,
      'createdAt': DateTime.now().toIso8601String(),
    });
    batch.update(_db.collection('reviews').doc(reviewId), {
      'likesCount': FieldValue.increment(1),
    });
    await batch.commit();
  }

  @override
  Future<void> unlikeReview(String userId, String reviewId) async {
    final likeId = '${userId}_$reviewId';
    final batch = _db.batch();
    batch.delete(_db.collection('likes').doc(likeId));
    batch.update(_db.collection('reviews').doc(reviewId), {
      'likesCount': FieldValue.increment(-1),
    });
    await batch.commit();
  }

  @override
  Future<bool> isReviewLiked(String userId, String reviewId) async {
    final likeId = '${userId}_$reviewId';
    final doc = await _db.collection('likes').doc(likeId).get();
    return doc.exists;
  }

  // ─── Comments ───────────────────────────────────────────────────────────────

  @override
  Future<List<CommentModel>> getReviewComments(String reviewId) async {
    final snap = await _db
        .collection('reviews')
        .doc(reviewId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .get();
    return snap.docs.map((d) => CommentModel.fromMap(d.data())).toList();
  }

  @override
  Future<void> addComment(CommentModel comment) async {
    final batch = _db.batch();
    batch.set(
      _db.collection('reviews').doc(comment.reviewId).collection('comments').doc(comment.id),
      comment.toMap(),
    );
    batch.update(_db.collection('reviews').doc(comment.reviewId), {
      'commentsCount': FieldValue.increment(1),
    });
    await batch.commit();
  }

  @override
  Future<void> deleteComment(String reviewId, String commentId) async {
    final batch = _db.batch();
    batch.delete(_db.collection('reviews').doc(reviewId).collection('comments').doc(commentId));
    batch.update(_db.collection('reviews').doc(reviewId), {
      'commentsCount': FieldValue.increment(-1),
    });
    await batch.commit();
  }

  // ─── Rating Distribution ────────────────────────────────────────────────────

  @override
  Future<Map<int, int>> getRatingDistribution(String mediaId) async {
    final snap = await _db
        .collection('reviews')
        .where('mediaId', isEqualTo: mediaId)
        .get();

    final Map<int, int> dist = {for (int i = 1; i <= 10; i++) i: 0};
    for (final doc in snap.docs) {
      final rating = (doc.data()['rating'] as num?)?.toDouble() ?? 0;
      final key = rating.round().clamp(1, 10);
      dist[key] = (dist[key] ?? 0) + 1;
    }
    return dist;
  }

  @override
  Future<double> getAverageCommunityRating(String mediaId) async {
    final snap = await _db
        .collection('reviews')
        .where('mediaId', isEqualTo: mediaId)
        .get();
    if (snap.docs.isEmpty) return 0.0;
    final ratings = snap.docs
        .map((d) => (d.data()['rating'] as num?)?.toDouble() ?? 0.0)
        .toList();
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  @override
  Future<int> getTotalRatingsCount(String mediaId) async {
    final snap = await _db
        .collection('reviews')
        .where('mediaId', isEqualTo: mediaId)
        .get();
    return snap.docs.length;
  }
}
