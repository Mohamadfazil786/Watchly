class UserModel {
  final String uid;
  final String email;
  final String username;
  final String bio;
  final String photoUrl;
  final List<String> favoriteGenres;
  final int followersCount;
  final int followingCount;
  final int reviewsCount;
  final int moviesWatchedCount;
  final List<String> topMovies; // List of TMDB Movie IDs
  final List<String> favoriteTvShows; // List of TMDB TV IDs
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.bio = '',
    this.photoUrl = '',
    this.favoriteGenres = const [],
    this.followersCount = 0,
    this.followingCount = 0,
    this.reviewsCount = 0,
    this.moviesWatchedCount = 0,
    this.topMovies = const [],
    this.favoriteTvShows = const [],
    required this.createdAt,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? bio,
    String? photoUrl,
    List<String>? favoriteGenres,
    int? followersCount,
    int? followingCount,
    int? reviewsCount,
    int? moviesWatchedCount,
    List<String>? topMovies,
    List<String>? favoriteTvShows,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      moviesWatchedCount: moviesWatchedCount ?? this.moviesWatchedCount,
      topMovies: topMovies ?? this.topMovies,
      favoriteTvShows: favoriteTvShows ?? this.favoriteTvShows,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'usernameLower': username.toLowerCase(),
      'bio': bio,
      'photoUrl': photoUrl,
      'favoriteGenres': favoriteGenres,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'reviewsCount': reviewsCount,
      'moviesWatchedCount': moviesWatchedCount,
      'topMovies': topMovies,
      'favoriteTvShows': favoriteTvShows,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      bio: map['bio'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      favoriteGenres: List<String>.from(map['favoriteGenres'] ?? []),
      followersCount: map['followersCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
      reviewsCount: map['reviewsCount'] ?? 0,
      moviesWatchedCount: map['moviesWatchedCount'] ?? 0,
      topMovies: List<String>.from(map['topMovies'] ?? []),
      favoriteTvShows: List<String>.from(map['favoriteTvShows'] ?? []),
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }
}
