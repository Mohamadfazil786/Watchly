class CommentModel {
  final String id;
  final String reviewId;
  final String userId;
  final String username;
  final String userPhotoUrl;
  final String commentText;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.reviewId,
    required this.userId,
    required this.username,
    this.userPhotoUrl = '',
    required this.commentText,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reviewId': reviewId,
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'commentText': commentText,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? '',
      reviewId: map['reviewId'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userPhotoUrl: map['userPhotoUrl'] ?? '',
      commentText: map['commentText'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }
}
