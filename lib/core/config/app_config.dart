import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  /// Toggle this to switch between Mock/Local Data Mode and live Firebase/APIs.
  static const bool useMockRepositories = false;

  /// TMDB API Read Access Token (Bearer Token).
  /// Loaded from .env file — do NOT hardcode.
  static String get tmdbApiKey => _env('TMDB_API_KEY');

  /// TMDB API Base URL.
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';

  /// Gemini API Key.
  /// Loaded from .env file — do NOT hardcode.
  static String get geminiApiKey => _env('GEMINI_API_KEY');

  /// Google Sign-In Server Client ID (Web Client ID from Firebase console).
  /// Loaded from .env file — do NOT hardcode.
  static String get googleServerClientId => _env('GOOGLE_SERVER_CLIENT_ID');

  static String _env(String key) {
    return dotenv.get(key, fallback: '');
  }
}
