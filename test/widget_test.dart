import 'package:flutter_test/flutter_test.dart';
import 'package:watchly/core/models/user_model.dart';
import 'package:watchly/core/models/review_model.dart';
import 'package:watchly/core/models/custom_list_model.dart';

void main() {
  group('Model Serialization Tests', () {
    test('UserModel serialization and deserialization', () {
      final user = UserModel(
        uid: 'test_user_id',
        email: 'test@example.com',
        username: 'test_username',
        bio: 'Hello world',
        photoUrl: 'https://photo.url',
        favoriteGenres: ['Sci-Fi', 'Action'],
        followersCount: 10,
        followingCount: 12,
        reviewsCount: 5,
        moviesWatchedCount: 20,
        topMovies: ['m_1', 'm_2'],
        favoriteTvShows: ['t_1'],
        createdAt: DateTime(2026, 1, 1),
      );

      final map = user.toMap();
      expect(map['uid'], 'test_user_id');
      expect(map['email'], 'test@example.com');
      expect(map['username'], 'test_username');
      expect(map['bio'], 'Hello world');
      expect(map['favoriteGenres'], ['Sci-Fi', 'Action']);

      final deserializedUser = UserModel.fromMap(map);
      expect(deserializedUser.uid, user.uid);
      expect(deserializedUser.email, user.email);
      expect(deserializedUser.username, user.username);
      expect(deserializedUser.favoriteGenres, user.favoriteGenres);
    });

    test('ReviewModel serialization and deserialization', () {
      final review = ReviewModel(
        id: 'rev_1',
        userId: 'user_123',
        username: 'cinephile99',
        mediaId: '157336',
        mediaTitle: 'Interstellar',
        mediaPoster: '/path.jpg',
        mediaType: 'movie',
        rating: 9.5,
        reviewText: 'Hauntingly beautiful.',
        createdAt: DateTime(2026, 6, 1),
        updatedAt: DateTime(2026, 6, 2),
      );

      final map = review.toMap();
      expect(map['id'], 'rev_1');
      expect(map['userId'], 'user_123');
      expect(map['mediaTitle'], 'Interstellar');
      expect(map['rating'], 9.5);
      expect(map['reviewText'], 'Hauntingly beautiful.');

      final deserializedReview = ReviewModel.fromMap(map);
      expect(deserializedReview.id, review.id);
      expect(deserializedReview.userId, review.userId);
      expect(deserializedReview.mediaTitle, review.mediaTitle);
      expect(deserializedReview.rating, review.rating);
    });

    test('CustomListModel serialization and deserialization', () {
      final list = CustomListModel(
        id: 'list_1',
        userId: 'user_123',
        username: 'cinephile99',
        name: 'My Favs',
        description: 'Best movies ever',
        isPublic: false,
        isRanked: true,
        mediaItems: [
          CustomListItem(
            mediaId: '157336',
            mediaTitle: 'Interstellar',
            mediaPoster: '/path.jpg',
            mediaType: 'movie',
          ),
        ],
        createdAt: DateTime(2026, 6, 15),
      );

      final map = list.toMap();
      expect(map['id'], 'list_1');
      expect(map['isRanked'], true);
      expect(map['isPublic'], false);

      final deserialized = CustomListModel.fromMap(map);
      expect(deserialized.id, list.id);
      expect(deserialized.isRanked, list.isRanked);
      expect(deserialized.isPublic, list.isPublic);
      expect(deserialized.mediaItems.length, 1);
      expect(deserialized.mediaItems.first.mediaTitle, 'Interstellar');
    });
  });
}
