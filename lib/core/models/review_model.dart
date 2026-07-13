class ReviewModel {
  final String id;
  final String userId;
  final String username;
  final String userPhotoUrl;
  final String mediaId;
  final String mediaTitle;
  final String mediaPoster;
  final String mediaType; // 'movie' or 'tv'
  final double rating; // 1 to 10 rating
  final String reviewText;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.username,
    this.userPhotoUrl = '',
    required this.mediaId,
    required this.mediaTitle,
    required this.mediaPoster,
    required this.mediaType,
    required this.rating,
    required this.reviewText,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  ReviewModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? userPhotoUrl,
    String? mediaId,
    String? mediaTitle,
    String? mediaPoster,
    String? mediaType,
    double? rating,
    String? reviewText,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      mediaId: mediaId ?? this.mediaId,
      mediaTitle: mediaTitle ?? this.mediaTitle,
      mediaPoster: mediaPoster ?? this.mediaPoster,
      mediaType: mediaType ?? this.mediaType,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'mediaId': mediaId,
      'mediaTitle': mediaTitle,
      'mediaPoster': mediaPoster,
      'mediaType': mediaType,
      'rating': rating,
      'reviewText': reviewText,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userPhotoUrl: map['userPhotoUrl'] ?? '',
      mediaId: map['mediaId'] ?? '',
      mediaTitle: map['mediaTitle'] ?? '',
      mediaPoster: map['mediaPoster'] ?? '',
      mediaType: map['mediaType'] ?? 'movie',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewText: map['reviewText'] ?? '',
      likesCount: map['likesCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
    );
  }
}
