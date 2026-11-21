import 'tmdb_credentials.dart';

/// Central configuration for The Movie Database (TMDB) API.
class TmdbConfig {
  TmdbConfig._();

  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';

  // Standard image size presets recommended by TMDB documentation
  static const String posterSmall = 'w185';
  static const String posterMedium = 'w342';
  static const String posterLarge = 'w500';
  static const String posterOriginal = 'original';

  static const String backdropMedium = 'w780';
  static const String backdropLarge = 'w1280';
  static const String backdropOriginal = 'original';

  static const String profileSmall = 'w185';
  static const String profileMedium = 'h632';

  static const String defaultRegion = 'IN';
  static const String defaultLanguage = 'en-US';

  /// TMDB attribution text required by TMDB API Terms of Use
  static const String attributionText =
      'This product uses the TMDB API but is not endorsed or certified by TMDB.';

  /// Helper to get full poster URL
  static String? getPosterUrl(String? path, {String size = posterLarge}) {
    if (path == null || path.isEmpty) return null;
    return '$imageBaseUrl/$size$path';
  }

  /// Helper to get full backdrop URL
  static String? getBackdropUrl(String? path, {String size = backdropLarge}) {
    if (path == null || path.isEmpty) return null;
    return '$imageBaseUrl/$size$path';
  }

  /// Helper to get full profile URL
  static String? getProfileUrl(String? path, {String size = profileSmall}) {
    if (path == null || path.isEmpty) return null;
    return '$imageBaseUrl/$size$path';
  }

  /// HTTP Headers for Bearer Token Authentication
  static Map<String, String> get authHeaders => {
        'Authorization': 'Bearer ${TmdbCredentials.readAccessToken}',
        'Content-Type': 'application/json;charset=utf-8',
        'Accept': 'application/json',
        'User-Agent': 'SeatVue/1.0',
      };
}
