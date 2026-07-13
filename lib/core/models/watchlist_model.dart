class WatchlistModel {
  final String userId;
  final String mediaId;
  final String mediaTitle;
  final String mediaPoster;
  final String mediaType; // 'movie' or 'tv'
  final bool isWatched;
  final DateTime? watchedAt;
  final DateTime createdAt;

  WatchlistModel({
    required this.userId,
    required this.mediaId,
    required this.mediaTitle,
    required this.mediaPoster,
    required this.mediaType,
    this.isWatched = false,
    this.watchedAt,
    required this.createdAt,
  });

  WatchlistModel copyWith({
    String? userId,
    String? mediaId,
    String? mediaTitle,
    String? mediaPoster,
    String? mediaType,
    bool? isWatched,
    DateTime? watchedAt,
    DateTime? createdAt,
  }) {
    return WatchlistModel(
      userId: userId ?? this.userId,
      mediaId: mediaId ?? this.mediaId,
      mediaTitle: mediaTitle ?? this.mediaTitle,
      mediaPoster: mediaPoster ?? this.mediaPoster,
      mediaType: mediaType ?? this.mediaType,
      isWatched: isWatched ?? this.isWatched,
      watchedAt: watchedAt ?? this.watchedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'mediaId': mediaId,
      'mediaTitle': mediaTitle,
      'mediaPoster': mediaPoster,
      'mediaType': mediaType,
      'isWatched': isWatched,
      'watchedAt': watchedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WatchlistModel.fromMap(Map<String, dynamic> map) {
    return WatchlistModel(
      userId: map['userId'] ?? '',
      mediaId: map['mediaId'] ?? '',
      mediaTitle: map['mediaTitle'] ?? '',
      mediaPoster: map['mediaPoster'] ?? '',
      mediaType: map['mediaType'] ?? 'movie',
      isWatched: map['isWatched'] ?? false,
      watchedAt: map['watchedAt'] != null ? DateTime.parse(map['watchedAt']) : null,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }
}
