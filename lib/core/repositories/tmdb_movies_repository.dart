import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/movie_model.dart';
import 'movies_repository.dart';

class TmdbMoviesRepository implements MoviesRepository {
  final Map<String, String> _headers = {
    'Authorization': 'Bearer ${AppConfig.tmdbApiKey}',
    'Content-Type': 'application/json;charset=utf-8',
  };

  Future<dynamic> _getJson(String url) async {
    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('TMDB API Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  @override
  Future<List<MovieModel>> searchMovies(String query) async {
    final data = await _getJson('${AppConfig.tmdbBaseUrl}/search/movie?query=${Uri.encodeComponent(query)}&language=en-US');
    final List results = data['results'] ?? [];
    return results.map((item) => MovieModel.fromTmdbJson(item, isTv: false)).toList();
  }

  @override
  Future<List<MovieModel>> searchTvShows(String query) async {
    final data = await _getJson('${AppConfig.tmdbBaseUrl}/search/tv?query=${Uri.encodeComponent(query)}&language=en-US');
    final List results = data['results'] ?? [];
    return results.map((item) => MovieModel.fromTmdbJson(item, isTv: true)).toList();
  }

  @override
  Future<MovieModel> getMovieDetails(String movieId) async {
    final data = await _getJson('${AppConfig.tmdbBaseUrl}/movie/$movieId?language=en-US');
    final cast = await getMediaCast(movieId, isTv: false);
    final trailer = await getMediaTrailer(movieId, isTv: false);
    
    final movie = MovieModel.fromTmdbJson(data, isTv: false);
    // Find director from cast endpoint credits if needed, or set placeholders
    String directorName = '';
    try {
      final creditsData = await _getJson('${AppConfig.tmdbBaseUrl}/movie/$movieId/credits');
      final List crewList = creditsData['crew'] ?? [];
      final directorInfo = crewList.firstWhere(
        (crew) => crew['job'] == 'Director',
        orElse: () => null,
      );
      if (directorInfo != null) {
        directorName = directorInfo['name'] ?? '';
      }
    } catch (_) {}

    return movie.copyWith(
      cast: cast,
      director: directorName,
      trailerUrl: trailer,
    );
  }

  @override
  Future<MovieModel> getTvShowDetails(String tvId) async {
    final data = await _getJson('${AppConfig.tmdbBaseUrl}/tv/$tvId?language=en-US');
    final cast = await getMediaCast(tvId, isTv: true);
    final trailer = await getMediaTrailer(tvId, isTv: true);

    final show = MovieModel.fromTmdbJson(data, isTv: true);
    // For TV show, get the creator name as "director" representation
    String creatorName = '';
    if (data['created_by'] != null && (data['created_by'] as List).isNotEmpty) {
      creatorName = data['created_by'][0]['name'] ?? '';
    }

    return show.copyWith(
      cast: cast,
      director: creatorName,
      trailerUrl: trailer,
    );
  }

  @override
  Future<List<MovieModel>> getTrendingMovies() async {
    final data = await _getJson('${AppConfig.tmdbBaseUrl}/trending/movie/day?language=en-US');
    final List results = data['results'] ?? [];
    return results.map((item) => MovieModel.fromTmdbJson(item, isTv: false)).toList();
  }

  @override
  Future<List<MovieModel>> getPopularTvShows() async {
    final data = await _getJson('${AppConfig.tmdbBaseUrl}/tv/popular?language=en-US');
    final List results = data['results'] ?? [];
    return results.map((item) => MovieModel.fromTmdbJson(item, isTv: true)).toList();
  }

  @override
  Future<List<MovieModel>> getNewReleases() async {
    final data = await _getJson('${AppConfig.tmdbBaseUrl}/movie/now_playing?language=en-US');
    final List results = data['results'] ?? [];
    return results.map((item) => MovieModel.fromTmdbJson(item, isTv: false)).toList();
  }

  @override
  Future<List<MovieModel>> getSimilarMovies(String movieId, {bool isTv = false}) async {
    final typePath = isTv ? 'tv' : 'movie';
    final data = await _getJson('${AppConfig.tmdbBaseUrl}/$typePath/$movieId/similar?language=en-US');
    final List results = data['results'] ?? [];
    return results.map((item) => MovieModel.fromTmdbJson(item, isTv: isTv)).toList();
  }

  @override
  Future<List<MovieModel>> getRecommendedMovies(String movieId, {bool isTv = false}) async {
    final typePath = isTv ? 'tv' : 'movie';
    final data = await _getJson('${AppConfig.tmdbBaseUrl}/$typePath/$movieId/recommendations?language=en-US');
    final List results = data['results'] ?? [];
    return results.map((item) => MovieModel.fromTmdbJson(item, isTv: isTv)).toList();
  }

  @override
  Future<List<CastMember>> getMediaCast(String mediaId, {bool isTv = false}) async {
    final typePath = isTv ? 'tv' : 'movie';
    final data = await _getJson('${AppConfig.tmdbBaseUrl}/$typePath/$mediaId/credits?language=en-US');
    final List castList = data['cast'] ?? [];
    return castList.map((item) => CastMember.fromMap(item)).toList();
  }

  @override
  Future<String> getMediaTrailer(String mediaId, {bool isTv = false}) async {
    final typePath = isTv ? 'tv' : 'movie';
    try {
      final data = await _getJson('${AppConfig.tmdbBaseUrl}/$typePath/$mediaId/videos?language=en-US');
      final List videoList = data['results'] ?? [];
      
      // Look for a YouTube Trailer
      final trailer = videoList.firstWhere(
        (video) => video['site']?.toString().toLowerCase() == 'youtube' && video['type']?.toString().toLowerCase() == 'trailer',
        orElse: () => videoList.firstWhere(
          (video) => video['site']?.toString().toLowerCase() == 'youtube',
          orElse: () => null,
        ),
      );

      if (trailer != null) {
        return trailer['key'] ?? '';
      }
    } catch (_) {}
    return '';
  }
}
