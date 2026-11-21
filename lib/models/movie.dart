/// Typed data model representing a movie.
class Movie {
  final String id;
  final String title;
  final String posterUrl;
  final String backdropUrl;
  final List<String> genres;
  final String duration;
  final double rating;
  final int releaseYear;
  final String pgRating;
  final String synopsis;
  final String director;
  final List<String> cast;
  final bool isFeatured;
  final bool isNowShowing;
  final String language;
  final String certification;

  const Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.backdropUrl,
    required this.genres,
    required this.duration,
    required this.rating,
    required this.releaseYear,
    required this.pgRating,
    required this.synopsis,
    required this.director,
    required this.cast,
    this.isFeatured = false,
    this.isNowShowing = true,
    this.language = 'English',
    String? certification,
  }) : certification = certification ?? pgRating;

  Movie copyWith({
    String? id,
    String? title,
    String? posterUrl,
    String? backdropUrl,
    List<String>? genres,
    String? duration,
    double? rating,
    int? releaseYear,
    String? pgRating,
    String? synopsis,
    String? director,
    List<String>? cast,
    bool? isFeatured,
    bool? isNowShowing,
    String? language,
    String? certification,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      genres: genres ?? this.genres,
      duration: duration ?? this.duration,
      rating: rating ?? this.rating,
      releaseYear: releaseYear ?? this.releaseYear,
      pgRating: pgRating ?? this.pgRating,
      synopsis: synopsis ?? this.synopsis,
      director: director ?? this.director,
      cast: cast ?? this.cast,
      isFeatured: isFeatured ?? this.isFeatured,
      isNowShowing: isNowShowing ?? this.isNowShowing,
      language: language ?? this.language,
      certification: certification ?? this.certification,
    );
  }
}
