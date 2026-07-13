class MovieModel {
  final String id;
  final String title;
  final String posterPath;
  final String backdropPath;
  final String overview;
  final String releaseDate;
  final double rating;
  final int ratingCount;
  final double popularity;
  final int runtime; // In minutes
  final List<String> genres;
  final List<CastMember> cast;
  final String director;
  final String trailerUrl; // YouTube video ID or full URL
  final bool isTvShow;

  MovieModel({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.backdropPath,
    required this.overview,
    required this.releaseDate,
    required this.rating,
    this.ratingCount = 0,
    required this.popularity,
    required this.runtime,
    required this.genres,
    this.cast = const [],
    this.director = '',
    this.trailerUrl = '',
    this.isTvShow = false,
  });

  MovieModel copyWith({
    String? id,
    String? title,
    String? posterPath,
    String? backdropPath,
    String? overview,
    String? releaseDate,
    double? rating,
    int? ratingCount,
    double? popularity,
    int? runtime,
    List<String>? genres,
    List<CastMember>? cast,
    String? director,
    String? trailerUrl,
    bool? isTvShow,
  }) {
    return MovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      overview: overview ?? this.overview,
      releaseDate: releaseDate ?? this.releaseDate,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      popularity: popularity ?? this.popularity,
      runtime: runtime ?? this.runtime,
      genres: genres ?? this.genres,
      cast: cast ?? this.cast,
      director: director ?? this.director,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      isTvShow: isTvShow ?? this.isTvShow,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'overview': overview,
      'releaseDate': releaseDate,
      'rating': rating,
      'ratingCount': ratingCount,
      'popularity': popularity,
      'runtime': runtime,
      'genres': genres,
      'cast': cast.map((c) => c.toMap()).toList(),
      'director': director,
      'trailerUrl': trailerUrl,
      'isTvShow': isTvShow,
    };
  }

  factory MovieModel.fromMap(Map<String, dynamic> map) {
    return MovieModel(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? map['name'] ?? '',
      posterPath: map['posterPath'] ?? map['poster_path'] ?? '',
      backdropPath: map['backdropPath'] ?? map['backdrop_path'] ?? '',
      overview: map['overview'] ?? '',
      releaseDate: map['releaseDate'] ?? map['release_date'] ?? map['first_air_date'] ?? '',
      rating: (map['rating'] ?? map['vote_average'] ?? 0.0).toDouble(),
      ratingCount: map['ratingCount'] ?? map['vote_count'] ?? 0,
      popularity: (map['popularity'] ?? 0.0).toDouble(),
      runtime: map['runtime'] ?? 0,
      genres: List<String>.from(map['genres'] ?? []),
      cast: (map['cast'] as List?)?.map((c) => CastMember.fromMap(c)).toList() ?? [],
      director: map['director'] ?? '',
      trailerUrl: map['trailerUrl'] ?? '',
      isTvShow: map['isTvShow'] ?? false,
    );
  }

  factory MovieModel.fromTmdbJson(Map<String, dynamic> json, {bool isTv = false}) {
    // TMDB genre mapping if genres are returned as IDs instead of objects
    final List<String> genresList = [];
    if (json['genres'] != null) {
      for (var g in json['genres']) {
        genresList.add(g['name'] ?? '');
      }
    } else if (json['genre_ids'] != null) {
      // Map basic genres for fallback
      final genreMap = {
        28: 'Action', 12: 'Adventure', 16: 'Animation', 35: 'Comedy', 80: 'Crime',
        99: 'Documentary', 18: 'Drama', 10751: 'Family', 14: 'Fantasy', 36: 'History',
        27: 'Horror', 10402: 'Music', 9648: 'Mystery', 10749: 'Romance', 878: 'Sci-Fi',
        10770: 'TV Movie', 53: 'Thriller', 10752: 'War', 37: 'Western',
        10759: 'Action & Adventure', 10762: 'Kids', 10763: 'News', 10764: 'Reality',
        10765: 'Sci-Fi & Fantasy', 10766: 'Soap', 10767: 'Talk', 10768: 'War & Politics'
      };
      for (var id in json['genre_ids']) {
        if (genreMap.containsKey(id)) {
          genresList.add(genreMap[id]!);
        }
      }
    }

    return MovieModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      overview: json['overview'] ?? '',
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
      rating: (json['vote_average'] ?? 0.0).toDouble(),
      ratingCount: json['vote_count'] ?? 0,
      popularity: (json['popularity'] ?? 0.0).toDouble(),
      runtime: json['runtime'] ?? (json['episode_run_time'] != null && (json['episode_run_time'] as List).isNotEmpty ? json['episode_run_time'][0] : 0),
      genres: genresList,
      cast: [], // Populated separately via cast credit endpoints
      director: '',
      trailerUrl: '',
      isTvShow: isTv,
    );
  }
}

class CastMember {
  final String name;
  final String character;
  final String profilePath;

  CastMember({
    required this.name,
    required this.character,
    required this.profilePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'character': character,
      'profilePath': profilePath,
    };
  }

  factory CastMember.fromMap(Map<String, dynamic> map) {
    return CastMember(
      name: map['name'] ?? '',
      character: map['character'] ?? '',
      profilePath: map['profilePath'] ?? map['profile_path'] ?? '',
    );
  }
}
