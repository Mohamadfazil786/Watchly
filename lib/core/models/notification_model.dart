class NotificationModel {
  final String id;
  final String receiverId;
  final String senderId;
  final String senderUsername; // maps to 'senderName' in Firestore
  final String senderPhotoUrl;
  final String type; // 'follow', 'review', 'list'
  final String targetId; // ID of the user or movie/review being referenced
  final String message;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.receiverId,
    required this.senderId,
    required this.senderUsername,
    this.senderPhotoUrl = '',
    required this.type,
    this.targetId = '',
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  NotificationModel copyWith({
    String? id,
    String? receiverId,
    String? senderId,
    String? senderUsername,
    String? senderPhotoUrl,
    String? type,
    String? targetId,
    String? message,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      receiverId: receiverId ?? this.receiverId,
      senderId: senderId ?? this.senderId,
      senderUsername: senderUsername ?? this.senderUsername,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      type: type ?? this.type,
      targetId: targetId ?? this.targetId,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'receiverId': receiverId,
      'senderId': senderId,
      'senderName': senderUsername,
      'senderPhotoUrl': senderPhotoUrl,
      'type': type,
      'targetId': targetId,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      receiverId: map['receiverId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderUsername: map['senderName'] ?? map['senderUsername'] ?? '',
      senderPhotoUrl: map['senderPhotoUrl'] ?? '',
      type: map['type'] ?? '',
      targetId: map['targetId'] ?? '',
      message: map['message'] ?? '',
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }
}
