import 'dart:convert';
import '../core/config/tmdb_config.dart';
import '../models/cast_member.dart';
import '../models/movie_details.dart';
import '../models/movie_video.dart';
import '../models/tmdb_movie.dart';
import 'tmdb_http_client.dart';

/// Custom exception for TMDB API errors.
class TmdbApiException implements Exception {
  final int statusCode;
  final String message;

  const TmdbApiException(this.statusCode, this.message);

  @override
  String toString() => 'TmdbApiException($statusCode): $message';
}

/// Service handling all API communication with The Movie Database (TMDB).
class TmdbService {
  final TmdbHttpClient _client;

  // Simple in-memory response cache: cacheKey -> (timestamp, responseData)
  final Map<String, (DateTime, dynamic)> _cache = {};
  static const Duration _cacheTtl = Duration(minutes: 10);

  TmdbService({TmdbHttpClient? client}) : _client = client ?? TmdbHttpClient();

  Future<dynamic> _getJson(String path, {Map<String, String>? queryParams, bool useCache = true}) async {
    final uri = Uri.parse('${TmdbConfig.baseUrl}$path').replace(queryParameters: queryParams);
    final cacheKey = uri.toString();

    if (useCache && _cache.containsKey(cacheKey)) {
      final (timestamp, cachedData) = _cache[cacheKey]!;
      if (DateTime.now().difference(timestamp) < _cacheTtl) {
        return cachedData;
      }
    }

    final response = await _client.get(uri, headers: TmdbConfig.authHeaders);

    if (response.isSuccess) {
      final data = json.decode(response.body);
      if (useCache) {
        _cache[cacheKey] = (DateTime.now(), data);
      }
      return data;
    } else {
      String errorMessage = 'Failed to fetch from TMDB';
      try {
        final errorJson = json.decode(response.body) as Map<String, dynamic>;
        errorMessage = errorJson['status_message'] as String? ?? errorMessage;
      } catch (_) {}
      throw TmdbApiException(response.statusCode, errorMessage);
    }
  }

  /// GET /movie/now_playing (region=IN)
  Future<List<TmdbMovie>> getNowPlayingMovies({int page = 1, String region = TmdbConfig.defaultRegion}) async {
    final data = await _getJson(
      '/movie/now_playing',
      queryParams: {
        'region': region,
        'page': page.toString(),
        'language': TmdbConfig.defaultLanguage,
      },
    );

    final results = data['results'] as List<dynamic>? ?? [];
    return results.map((e) => TmdbMovie.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /movie/upcoming (region=IN)
  Future<List<TmdbMovie>> getUpcomingMovies({int page = 1, String region = TmdbConfig.defaultRegion}) async {
    final data = await _getJson(
      '/movie/upcoming',
      queryParams: {
        'region': region,
        'page': page.toString(),
        'language': TmdbConfig.defaultLanguage,
      },
    );

    final results = data['results'] as List<dynamic>? ?? [];
    return results.map((e) => TmdbMovie.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /movie/popular (region=IN)
  Future<List<TmdbMovie>> getPopularMovies({int page = 1, String region = TmdbConfig.defaultRegion}) async {
    final data = await _getJson(
      '/movie/popular',
      queryParams: {
        'region': region,
        'page': page.toString(),
        'language': TmdbConfig.defaultLanguage,
      },
    );

    final results = data['results'] as List<dynamic>? ?? [];
    return results.map((e) => TmdbMovie.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /search/movie (query)
  Future<List<TmdbMovie>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];

    final data = await _getJson(
      '/search/movie',
      queryParams: {
        'query': query.trim(),
        'page': page.toString(),
        'language': TmdbConfig.defaultLanguage,
      },
      useCache: false, // Don't cache transient search queries
    );

    final results = data['results'] as List<dynamic>? ?? [];
    return results.map((e) => TmdbMovie.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /movie/{movie_id}
  Future<MovieDetails> getMovieDetails(int movieId) async {
    final data = await _getJson(
      '/movie/$movieId',
      queryParams: {'language': TmdbConfig.defaultLanguage},
    );
    return MovieDetails.fromJson(data as Map<String, dynamic>);
  }

  /// GET /movie/{movie_id}/credits
  Future<List<CastMember>> getMovieCredits(int movieId) async {
    final data = await _getJson(
      '/movie/$movieId/credits',
      queryParams: {'language': TmdbConfig.defaultLanguage},
    );
    final cast = data['cast'] as List<dynamic>? ?? [];
    return cast.map((e) => CastMember.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /movie/{movie_id}/videos
  Future<List<MovieVideo>> getMovieVideos(int movieId) async {
    final data = await _getJson(
      '/movie/$movieId/videos',
      queryParams: {'language': TmdbConfig.defaultLanguage},
    );
    final results = data['results'] as List<dynamic>? ?? [];
    return results.map((e) => MovieVideo.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /movie/{movie_id}/release_dates
  /// Fetches release date certifications and dates grouped by country (e.g. IN for India).
  Future<Map<String, dynamic>> getMovieReleaseDates(int movieId) async {
    final data = await _getJson('/movie/$movieId/release_dates');
    return data as Map<String, dynamic>;
  }

  void clearCache() {
    _cache.clear();
  }

  void dispose() {
    _client.close();
  }
}
