class CustomListItem {
  final String mediaId;
  final String mediaTitle;
  final String mediaPoster;
  final String mediaType; // 'movie' or 'tv'

  CustomListItem({
    required this.mediaId,
    required this.mediaTitle,
    required this.mediaPoster,
    required this.mediaType,
  });

  Map<String, dynamic> toMap() {
    return {
      'mediaId': mediaId,
      'mediaTitle': mediaTitle,
      'mediaPoster': mediaPoster,
      'mediaType': mediaType,
    };
  }

  factory CustomListItem.fromMap(Map<String, dynamic> map) {
    return CustomListItem(
      mediaId: map['mediaId'] ?? '',
      mediaTitle: map['mediaTitle'] ?? '',
      mediaPoster: map['mediaPoster'] ?? '',
      mediaType: map['mediaType'] ?? 'movie',
    );
  }
}

class CustomListModel {
  final String id;
  final String userId;
  final String username;
  final String name;
  final String description;
  final bool isPublic;
  final bool isRanked;
  final List<CustomListItem> mediaItems;
  final DateTime createdAt;

  CustomListModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.name,
    this.description = '',
    this.isPublic = true,
    this.isRanked = true,
    required this.mediaItems,
    required this.createdAt,
  });

  CustomListModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? name,
    String? description,
    bool? isPublic,
    bool? isRanked,
    List<CustomListItem>? mediaItems,
    DateTime? createdAt,
  }) {
    return CustomListModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      name: name ?? this.name,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      isRanked: isRanked ?? this.isRanked,
      mediaItems: mediaItems ?? this.mediaItems,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'name': name,
      'description': description,
      'isPublic': isPublic,
      'isRanked': isRanked,
      'mediaItems': mediaItems.map((item) => item.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomListModel.fromMap(Map<String, dynamic> map) {
    return CustomListModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      isPublic: map['isPublic'] ?? true,
      isRanked: map['isRanked'] ?? true,
      mediaItems: (map['mediaItems'] as List?)
              ?.map((item) => CustomListItem.fromMap(item))
              .toList() ??
          [],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}
