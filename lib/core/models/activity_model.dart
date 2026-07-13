class ActivityModel {
  final String id;
  final String userId;
  final String username;
  final String userPhotoUrl;
  final String type; // 'review', 'rating', 'watchlist', 'list'
  final String targetId; // TMDB Movie ID or Review ID or Custom List ID
  final String targetTitle; // Movie Title or Review Movie Title or List Name
  final String message; // E.g., "reviewed Inception", "added Dune to watchlist"
  final DateTime createdAt;

  ActivityModel({
    required this.id,
    required this.userId,
    required this.username,
    this.userPhotoUrl = '',
    required this.type,
    required this.targetId,
    required this.targetTitle,
    required this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'type': type,
      'targetId': targetId,
      'targetTitle': targetTitle,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userPhotoUrl: map['userPhotoUrl'] ?? '',
      type: map['type'] ?? '',
      targetId: map['targetId'] ?? '',
      targetTitle: map['targetTitle'] ?? '',
      message: map['message'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }
}
