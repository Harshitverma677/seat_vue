/// Standard TMDB genre ID to name lookup helper.
class TmdbGenres {
  TmdbGenres._();

  static const Map<int, String> genreMap = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Sci-Fi',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };

  static List<String> getGenreNames(List<int> ids) {
    return ids.map((id) => genreMap[id] ?? 'Cinema').toList();
  }
}
