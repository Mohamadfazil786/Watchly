import '../models/notification_model.dart';

abstract class NotificationRepository {
  /// Real-time stream of notifications for [userId], newest first.
  Stream<List<NotificationModel>> watchNotifications(String userId);

  /// Stream of unread notification count for [userId].
  Stream<int> watchUnreadCount(String userId);

  /// Write a notification document to Firestore.
  Future<void> createNotification(NotificationModel notification);

  /// Mark a single notification as read.
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications for [userId] as read.
  Future<void> markAllAsRead(String userId);
}
