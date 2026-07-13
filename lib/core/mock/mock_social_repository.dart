import '../models/user_model.dart';
import '../models/activity_model.dart';
import '../repositories/social_repository.dart';


class MockSocialRepository implements SocialRepository {
  final Set<String> _following = {'user_1_user_2', 'user_1_user_3', 'user_2_user_1'};

  final List<ActivityModel> _activities = [
    ActivityModel(id: 'act_1', userId: 'user_2', username: 'sara_watches', type: 'review', targetId: '157336', targetTitle: 'Interstellar', message: 'reviewed Interstellar', createdAt: DateTime.now().subtract(const Duration(hours: 2))),
    ActivityModel(id: 'act_2', userId: 'user_3', username: 'kai_reviews', type: 'rating', targetId: '496243', targetTitle: 'Parasite', message: 'rated Parasite 10/10', createdAt: DateTime.now().subtract(const Duration(hours: 4))),
    ActivityModel(id: 'act_3', userId: 'user_2', username: 'sara_watches', type: 'watchlist', targetId: '438631', targetTitle: 'Dune', message: 'added Dune to watchlist', createdAt: DateTime.now().subtract(const Duration(hours: 6))),
    ActivityModel(id: 'act_4', userId: 'user_3', username: 'kai_reviews', type: 'list', targetId: 'list_1', targetTitle: 'Top Nolan Films', message: 'created list Top Nolan Films', createdAt: DateTime.now().subtract(const Duration(days: 1))),
    ActivityModel(id: 'act_5', userId: 'user_2', username: 'sara_watches', type: 'review', targetId: 'tv_1396', targetTitle: 'Breaking Bad', message: 'reviewed Breaking Bad', createdAt: DateTime.now().subtract(const Duration(days: 2))),
  ];

  static final List<UserModel> _allUsers = [
    UserModel(uid: 'user_1', email: 'alex@cinesphere.com', username: 'alex_cinephile', bio: 'Movies are my religion.', favoriteGenres: ['Sci-Fi', 'Thriller'], followersCount: 248, followingCount: 112, reviewsCount: 87, moviesWatchedCount: 342, createdAt: DateTime(2024, 1, 15)),
    UserModel(uid: 'user_2', email: 'sara@cinesphere.com', username: 'sara_watches', bio: 'Horror & comedy lover.', favoriteGenres: ['Horror', 'Comedy'], followersCount: 510, followingCount: 89, reviewsCount: 134, moviesWatchedCount: 567, createdAt: DateTime(2023, 8, 3)),
    UserModel(uid: 'user_3', email: 'kai@cinesphere.com', username: 'kai_reviews', bio: 'Nolan fanboy. Kubrick worshipper.', favoriteGenres: ['Drama', 'Action'], followersCount: 193, followingCount: 220, reviewsCount: 52, moviesWatchedCount: 201, createdAt: DateTime(2024, 3, 22)),
  ];

  @override
  Future<void> followUser(String currentUserId, String targetUserId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _following.add('${currentUserId}_$targetUserId');
  }

  @override
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _following.remove('${currentUserId}_$targetUserId');
  }

  @override
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    return _following.contains('${currentUserId}_$targetUserId');
  }

  @override
  Future<List<UserModel>> getFollowers(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _allUsers.where((u) => _following.contains('${u.uid}_$userId')).toList();
  }

  @override
  Future<List<UserModel>> getFollowing(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _allUsers.where((u) => _following.contains('${userId}_${u.uid}')).toList();
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final q = query.toLowerCase();
    return _allUsers.where((u) => u.username.toLowerCase().contains(q) || u.email.toLowerCase().contains(q)).toList();
  }

  @override
  Future<List<ActivityModel>> getFriendActivity(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final friendIds = _allUsers.where((u) => _following.contains('${userId}_${u.uid}')).map((u) => u.uid).toSet();
    final friendActivity = _activities.where((a) => friendIds.contains(a.userId)).toList();
    return friendActivity.isEmpty ? _activities : friendActivity;
  }

  @override
  Future<List<ActivityModel>> getUserActivity(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _activities.where((a) => a.userId == userId).toList();
  }

  @override
  Future<void> postActivity(ActivityModel activity) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _activities.insert(0, activity);
  }
}
