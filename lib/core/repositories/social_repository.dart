import '../models/user_model.dart';
import '../models/activity_model.dart';

abstract class SocialRepository {
  Future<void> followUser(String currentUserId, String targetUserId);
  Future<void> unfollowUser(String currentUserId, String targetUserId);
  Future<bool> isFollowing(String currentUserId, String targetUserId);
  Future<List<UserModel>> getFollowers(String userId);
  Future<List<UserModel>> getFollowing(String userId);
  Future<List<UserModel>> searchUsers(String query);
  Future<List<ActivityModel>> getFriendActivity(String userId);
  Future<List<ActivityModel>> getUserActivity(String userId);
  Future<void> postActivity(ActivityModel activity);
}
