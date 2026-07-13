abstract class AiRepository {
  /// Get AI-powered movie recommendations based on user profile data.
  Future<String> getPersonalizedRecommendations({
    required List<String> favoriteGenres,
    required List<String> watchedMovieTitles,
    required List<String> highlyRatedMovies,
  });

  /// Mood-based recommendations — user describes what they want.
  Future<String> getMoodBasedRecommendations(String moodPrompt);

  /// Compare two movies or shows.
  Future<String> compareMedia(String titleA, String titleB);

  /// Generate a review draft based on a rating and movie title.
  Future<String> generateReviewDraft(String movieTitle, double rating);
}
