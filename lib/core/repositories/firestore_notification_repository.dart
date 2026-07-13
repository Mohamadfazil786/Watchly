import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'notification_repository.dart';

class FirestoreNotificationRepository implements NotificationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  NotificationModel _fromDoc(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    DateTime createdAt = DateTime.now();
    final raw = map['createdAt'];
    if (raw is Timestamp) {
      createdAt = raw.toDate();
    } else if (raw is String) {
      createdAt = DateTime.parse(raw);
    }
    return NotificationModel(
      id: doc.id,
      receiverId: map['receiverId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderUsername: map['senderName'] ?? '',
      senderPhotoUrl: map['senderPhotoUrl'] ?? '',
      type: map['type'] ?? 'follow',
      targetId: map['targetId'] ?? '',
      message: map['message'] ?? '',
      isRead: map['isRead'] ?? false,
      createdAt: createdAt,
    );
  }

  // ─── Streams ─────────────────────────────────────────────────────────────────

  @override
  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map(_fromDoc).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list.take(50).toList();
        });
  }

  @override
  Stream<int> watchUnreadCount(String userId) {
    return _db
        .collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // ─── Writes ───────────────────────────────────────────────────────────────────

  @override
  Future<void> createNotification(NotificationModel notification) async {
    await _db.collection('notifications').add({
      'receiverId': notification.receiverId,
      'senderId': notification.senderId,
      'senderName': notification.senderUsername,
      'senderPhotoUrl': notification.senderPhotoUrl,
      'type': notification.type,
      'targetId': notification.targetId,
      'message': notification.message,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final snap = await _db
        .collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    if (snap.docs.isEmpty) return;

    // Batch update in chunks of 500 (Firestore limit)
    final chunks = <List<DocumentSnapshot>>[];
    for (int i = 0; i < snap.docs.length; i += 500) {
      chunks.add(snap.docs.sublist(
        i,
        i + 500 > snap.docs.length ? snap.docs.length : i + 500,
      ));
    }
    for (final chunk in chunks) {
      final batch = _db.batch();
      for (final doc in chunk) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    }
  }
}
