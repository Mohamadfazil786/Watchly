class AppConstants {
  static const String appName = 'Watchly';
  static const String tmdbImageBase = 'https://image.tmdb.org/t/p/';

  // Image sizes
  static const String posterW342 = '${tmdbImageBase}w342';
  static const String posterW500 = '${tmdbImageBase}w500';
  static const String backdropW1280 = '${tmdbImageBase}w1280';
  static const String profileW185 = '${tmdbImageBase}w185';
  static const String originalSize = '${tmdbImageBase}original';

  // Hive box names
  static const String onboardingBox = 'onboarding_box';
  static const String userPrefsBox = 'user_prefs_box';

  // Hive keys
  static const String hasSeenOnboardingKey = 'has_seen_onboarding';

  // Placeholder avatar URL (a gradient placeholder)
  static const String defaultAvatarUrl = '';

  static String posterUrl(String path, {String size = 'w342'}) {
    if (path.isEmpty) return '';
    // If already a full URL, return it as-is to avoid double-prefixing
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final p = path.startsWith('/') ? path : '/$path';
    return '${tmdbImageBase}$size$p';
  }

  static String backdropUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final p = path.startsWith('/') ? path : '/$path';
    return '${backdropW1280}$p';
  }

  static String profileUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final p = path.startsWith('/') ? path : '/$path';
    return '${profileW185}$p';
  }
}
