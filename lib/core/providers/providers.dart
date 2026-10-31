import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/app_config.dart';
import '../repositories/auth_repository.dart';
import '../repositories/movies_repository.dart';
import '../repositories/reviews_repository.dart';
import '../repositories/social_repository.dart';
import '../repositories/lists_repository.dart';
import '../repositories/ai_repository.dart';
import '../repositories/notification_repository.dart';
// Mock repositories
import '../mock/mock_auth_repository.dart';
import '../mock/mock_movies_repository.dart';
import '../mock/mock_reviews_repository.dart';
import '../mock/mock_social_repository.dart';
import '../mock/mock_lists_repository.dart';
import '../mock/mock_ai_repository.dart';
// Live repositories
import '../repositories/firebase_auth_repository.dart';
import '../repositories/tmdb_movies_repository.dart';
import '../repositories/firestore_reviews_repository.dart';
import '../repositories/firestore_social_repository.dart';
import '../repositories/firestore_lists_repository.dart';
import '../repositories/firestore_notification_repository.dart';
import '../repositories/gemini_ai_repository.dart';
import '../models/user_model.dart';
import '../models/custom_list_model.dart';
import '../models/watchlist_model.dart';
import '../models/notification_model.dart';
import '../models/comment_model.dart';
import '../constants/app_constants.dart';

// ─── Repository Providers ────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppConfig.useMockRepositories || Firebase.apps.isEmpty) {
    if (Firebase.apps.isEmpty && !AppConfig.useMockRepositories) {
      debugPrint('Watchly Warning: Firebase not initialized. Falling back to MockAuthRepository.');
    }
    return MockAuthRepository();
  }
  return FirebaseAuthRepository();
});

final moviesRepositoryProvider = Provider<MoviesRepository>((ref) {
  if (AppConfig.useMockRepositories) return MockMoviesRepository();
  return TmdbMoviesRepository();
});

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  if (AppConfig.useMockRepositories || Firebase.apps.isEmpty) {
    if (Firebase.apps.isEmpty && !AppConfig.useMockRepositories) {
      debugPrint('Watchly Warning: Firebase not initialized. Falling back to MockReviewsRepository.');
    }
    return MockReviewsRepository();
  }
  return FirestoreReviewsRepository();
});

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  if (AppConfig.useMockRepositories || Firebase.apps.isEmpty) {
    if (Firebase.apps.isEmpty && !AppConfig.useMockRepositories) {
      debugPrint('Watchly Warning: Firebase not initialized. Falling back to MockSocialRepository.');
    }
    return MockSocialRepository();
  }
  return FirestoreSocialRepository();
});

final listsRepositoryProvider = Provider<ListsRepository>((ref) {
  if (AppConfig.useMockRepositories || Firebase.apps.isEmpty) {
    if (Firebase.apps.isEmpty && !AppConfig.useMockRepositories) {
      debugPrint('Watchly Warning: Firebase not initialized. Falling back to MockListsRepository.');
    }
    return MockListsRepository();
  }
  return FirestoreListsRepository();
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  if (AppConfig.useMockRepositories) return MockAiRepository();
  return GeminiAiRepository();
});

// ─── Auth State Provider ─────────────────────────────────────────────────────

final authStateProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// Streams the logged-in user's Firestore document in real time so that
/// counters (followers, reviews, films watched) update immediately after
/// any write — without needing to log out and back in.
final currentUserStreamProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  final uid = authState.value?.uid;
  if (uid == null || uid.isEmpty) return Stream.value(null);
  return ref.read(authRepositoryProvider).watchUserProfile(uid);
});

final currentUserProvider = Provider<UserModel?>((ref) {
  // Prefer real-time Firestore stream so counters stay up-to-date
  final streamState = ref.watch(currentUserStreamProvider);
  if (streamState.value != null) return streamState.value;
  // Fall back to auth-state value or in-memory cache while the stream initialises
  final authState = ref.watch(authStateProvider);
  return authState.value ?? ref.watch(authRepositoryProvider).currentUser;
});

// ─── Theme Provider ───────────────────────────────────────────────────────────

final themeModeProvider = StateProvider<bool>((ref) {
  final box = Hive.box(AppConstants.userPrefsBox);
  return box.get('is_dark_mode', defaultValue: true) as bool;
});

// ─── User Lists & Watchlist Providers ────────────────────────────────────────

final userListsProvider = FutureProvider.autoDispose.family<List<CustomListModel>, String>((ref, uid) {
  return ref.watch(listsRepositoryProvider).getUserLists(uid);
});

final userWatchlistProvider = FutureProvider.autoDispose.family<List<WatchlistModel>, String>((ref, uid) {
  return ref.watch(listsRepositoryProvider).getWatchlist(uid);
});

// ─── Notification Providers ───────────────────────────────────────────────────

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  if (AppConfig.useMockRepositories || Firebase.apps.isEmpty) {
    return _MockNotificationRepository();
  }
  return FirestoreNotificationRepository();
});

/// Real-time stream of the current user's notifications.
final notificationsStreamProvider = StreamProvider<List<NotificationModel>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null || uid.isEmpty) return Stream.value([]);
  return ref.read(notificationRepositoryProvider).watchNotifications(uid);
});

/// Live count of unread notifications for badge display.
final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null || uid.isEmpty) return Stream.value(0);
  return ref.read(notificationRepositoryProvider).watchUnreadCount(uid);
});

// Minimal no-op mock so the app runs without Firebase
class _MockNotificationRepository implements NotificationRepository {
  @override
  Stream<List<NotificationModel>> watchNotifications(String userId) => Stream.value([]);
  @override
  Stream<int> watchUnreadCount(String userId) => Stream.value(0);
  @override
  Future<void> createNotification(NotificationModel notification) async {}
  @override
  Future<void> markAsRead(String notificationId) async {}
  @override
  Future<void> markAllAsRead(String userId) async {}
}

final hasShownSplashProvider = StateProvider<bool>((ref) => false);

// ─── Review Reaction & Comment Providers ─────────────────────────────────────

final reviewLikesProvider = StateNotifierProvider<ReviewLikesNotifier, Map<String, bool>>((ref) {
  return ReviewLikesNotifier();
});

class ReviewLikesNotifier extends StateNotifier<Map<String, bool>> {
  ReviewLikesNotifier() : super({});

  void setLiked(String reviewId, bool isLiked) {
    state = {...state, reviewId: isLiked};
  }

  void toggleLike(String reviewId) {
    final current = state[reviewId] ?? false;
    state = {...state, reviewId: !current};
  }
}

final reviewCommentsProvider = FutureProvider.autoDispose.family<List<CommentModel>, String>((ref, reviewId) {
  return ref.watch(reviewsRepositoryProvider).getReviewComments(reviewId);
});


