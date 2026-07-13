import '../models/movie_model.dart';

abstract class MoviesRepository {
  Future<List<MovieModel>> searchMovies(String query);
  
  Future<List<MovieModel>> searchTvShows(String query);

  Future<MovieModel> getMovieDetails(String movieId);

  Future<MovieModel> getTvShowDetails(String tvId);

  Future<List<MovieModel>> getTrendingMovies();

  Future<List<MovieModel>> getPopularTvShows();

  Future<List<MovieModel>> getNewReleases();

  Future<List<MovieModel>> getSimilarMovies(String movieId, {bool isTv = false});

  Future<List<MovieModel>> getRecommendedMovies(String movieId, {bool isTv = false});

  Future<List<CastMember>> getMediaCast(String mediaId, {bool isTv = false});

  Future<String> getMediaTrailer(String mediaId, {bool isTv = false});
}
