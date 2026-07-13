import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/activity_model.dart';
import '../repositories/social_repository.dart';

class FirestoreSocialRepository implements SocialRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Followers ───────────────────────────────────────────────────────────────

  @override
  Future<void> followUser(String currentUserId, String targetUserId) async {
    final followId = '${currentUserId}_$targetUserId';
    final batch = _db.batch();

    batch.set(_db.collection('followers').doc(followId), {
      'followerUid': currentUserId,
      'followingUid': targetUserId,
      'createdAt': DateTime.now().toIso8601String(),
    });

    // Increment counts
    batch.set(_db.collection('users').doc(targetUserId), {
      'followersCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
    batch.set(_db.collection('users').doc(currentUserId), {
      'followingCount': FieldValue.increment(1),
    }, SetOptions(merge: true));

    await batch.commit();

    // ── Write follow notification for the target user ──────────────────────────
    try {
      final senderDoc = await _db.collection('users').doc(currentUserId).get();
      final senderName = (senderDoc.data()?['username'] as String?) ?? 'Someone';
      final senderPhoto = (senderDoc.data()?['photoUrl'] as String?) ?? '';

      await _db.collection('notifications').add({
        'receiverId': targetUserId,
        'senderId': currentUserId,
        'senderName': senderName,
        'senderPhotoUrl': senderPhoto,
        'type': 'follow',
        'targetId': currentUserId,
        'message': '@$senderName followed you',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Notification failure must never break the follow action
    }
  }

  @override
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    final followId = '${currentUserId}_$targetUserId';
    final batch = _db.batch();

    batch.delete(_db.collection('followers').doc(followId));

    batch.set(_db.collection('users').doc(targetUserId), {
      'followersCount': FieldValue.increment(-1),
    }, SetOptions(merge: true));
    batch.set(_db.collection('users').doc(currentUserId), {
      'followingCount': FieldValue.increment(-1),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  @override
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    final followId = '${currentUserId}_$targetUserId';
    final doc = await _db.collection('followers').doc(followId).get();
    return doc.exists;
  }

  @override
  Future<List<UserModel>> getFollowers(String userId) async {
    final snap = await _db
        .collection('followers')
        .where('followingUid', isEqualTo: userId)
        .get();

    final List<UserModel> users = [];
    for (final doc in snap.docs) {
      final followerUid = doc.data()['followerUid'] as String?;
      if (followerUid != null) {
        final userDoc = await _db.collection('users').doc(followerUid).get();
        if (userDoc.exists) {
          users.add(UserModel.fromMap(userDoc.data()!));
        }
      }
    }
    return users;
  }

  @override
  Future<List<UserModel>> getFollowing(String userId) async {
    final snap = await _db
        .collection('followers')
        .where('followerUid', isEqualTo: userId)
        .get();

    final List<UserModel> users = [];
    for (final doc in snap.docs) {
      final followingUid = doc.data()['followingUid'] as String?;
      if (followingUid != null) {
        final userDoc = await _db.collection('users').doc(followingUid).get();
        if (userDoc.exists) {
          users.add(UserModel.fromMap(userDoc.data()!));
        }
      }
    }
    return users;
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    final q = query.trim().toLowerCase();

    // Firestore prefix search on usernameLower field
    final snap = await _db
        .collection('users')
        .orderBy('usernameLower')
        .startAt([q])
        .endAt(['$q\uf8ff'])
        .limit(20)
        .get();

    return snap.docs.map((d) => UserModel.fromMap(d.data())).toList();
  }

  // ─── Activity Feed ───────────────────────────────────────────────────────────

  @override
  Future<List<ActivityModel>> getFriendActivity(String userId) async {
    // Get list of people the user follows
    final followingSnap = await _db
        .collection('followers')
        .where('followerUid', isEqualTo: userId)
        .get();

    final followingIds = followingSnap.docs
        .map((d) => d.data()['followingUid'] as String?)
        .whereType<String>()
        .toList();

    if (followingIds.isEmpty) return [];

    // Firestore 'whereIn' supports up to 30 items
    final chunks = <List<String>>[];
    for (int i = 0; i < followingIds.length; i += 30) {
      chunks.add(followingIds.sublist(
          i, i + 30 > followingIds.length ? followingIds.length : i + 30));
    }

    final List<ActivityModel> activities = [];
    for (final chunk in chunks) {
      final snap = await _db
          .collection('activities')
          .where('userId', whereIn: chunk)
          .limit(30)
          .get();
      activities.addAll(snap.docs.map((d) => ActivityModel.fromMap(d.data())));
    }

    activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return activities.take(30).toList();
  }

  @override
  Future<List<ActivityModel>> getUserActivity(String userId) async {
    final snap = await _db
        .collection('activities')
        .where('userId', isEqualTo: userId)
        .limit(20)
        .get();
    final activities = snap.docs.map((d) => ActivityModel.fromMap(d.data())).toList();
    activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return activities;
  }

  @override
  Future<void> postActivity(ActivityModel activity) async {
    await _db.collection('activities').doc(activity.id).set(activity.toMap());
  }
}
