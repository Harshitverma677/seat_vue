import '../models/movie.dart';
import '../models/showtime.dart';

/// Local mock movie catalog with rich Delhi theatrical data.
class MockMovies {
  MockMovies._();

  static const List<Movie> sampleMovies = [
    Movie(
      id: 'm1',
      title: 'Dune: Part Two',
      language: 'English',
      certification: 'U/A 16+',
      posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=800&auto=format&fit=crop',
      backdropUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=1600&auto=format&fit=crop',
      genres: ['Sci-Fi', 'Adventure', 'Action'],
      duration: '2h 46m',
      rating: 8.8,
      releaseYear: 2024,
      pgRating: 'U/A 16+',
      synopsis:
          'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family. Facing a choice between the love of his life and the fate of the known universe, he endeavors to prevent a terrible future only he can foresee.',
      director: 'Denis Villeneuve',
      cast: ['Timothée Chalamet', 'Zendaya', 'Rebecca Ferguson', 'Javier Bardem'],
      isFeatured: true,
      isNowShowing: true,
    ),
    Movie(
      id: 'm2',
      title: 'Interstellar: 10th Anniversary',
      language: 'English',
      certification: 'U/A',
      posterUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=800&auto=format&fit=crop',
      backdropUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?q=80&w=1600&auto=format&fit=crop',
      genres: ['Sci-Fi', 'Drama', 'Adventure'],
      duration: '2h 49m',
      rating: 8.7,
      releaseYear: 2024,
      pgRating: 'U/A',
      synopsis:
          'When Earth becomes uninhabitable in the future, a farmer and ex-NASA pilot, Joseph Cooper, is tasked to pilot a spacecraft, along with a team of researchers, to find a new planet for humans.',
      director: 'Christopher Nolan',
      cast: ['Matthew McConaughey', 'Anne Hathaway', 'Jessica Chastain', 'Michael Caine'],
      isFeatured: true,
      isNowShowing: true,
    ),
    Movie(
      id: 'm3',
      title: 'Jawan',
      language: 'Hindi',
      certification: 'U/A',
      posterUrl: 'https://images.unsplash.com/photo-1578328819058-b69f3a3b0f6b?q=80&w=800&auto=format&fit=crop',
      backdropUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=1600&auto=format&fit=crop',
      genres: ['Action', 'Thriller', 'Drama'],
      duration: '2h 49m',
      rating: 8.1,
      releaseYear: 2023,
      pgRating: 'U/A',
      synopsis:
          'A high-octane action thriller which outlines the emotional journey of a man who is set to rectify the wrongs in the society, backed by a band of fierce women fighters.',
      director: 'Atlee Kumar',
      cast: ['Shah Rukh Khan', 'Nayanthara', 'Vijay Sethupathi', 'Deepika Padukone'],
      isFeatured: true,
      isNowShowing: true,
    ),
    Movie(
      id: 'm4',
      title: 'Fighter',
      language: 'Hindi',
      certification: 'U/A 16+',
      posterUrl: 'https://images.unsplash.com/photo-1517976487507-5b3b1451f496?q=80&w=800&auto=format&fit=crop',
      backdropUrl: 'https://images.unsplash.com/photo-1517976487507-5b3b1451f496?q=80&w=1600&auto=format&fit=crop',
      genres: ['Action', 'Thriller', 'War'],
      duration: '2h 46m',
      rating: 7.8,
      releaseYear: 2024,
      pgRating: 'U/A 16+',
      synopsis:
          'Top IAF aviators come together in the face of imminent danger to form Air Dragons, forging bonds of brotherhood and defending India\'s skies with valor.',
      director: 'Siddharth Anand',
      cast: ['Hrithik Roshan', 'Deepika Padukone', 'Anil Kapoor', 'Karan Singh Grover'],
      isFeatured: false,
      isNowShowing: true,
    ),
    Movie(
      id: 'm5',
      title: 'Oppenheimer',
      language: 'English',
      certification: 'A',
      posterUrl: 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?q=80&w=800&auto=format&fit=crop',
      backdropUrl: 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?q=80&w=1600&auto=format&fit=crop',
      genres: ['Biography', 'Drama', 'History'],
      duration: '3h 00m',
      rating: 8.9,
      releaseYear: 2023,
      pgRating: 'A',
      synopsis:
          'The story of American scientist J. Robert Oppenheimer and his role in the development of the atomic bomb during the Manhattan Project.',
      director: 'Christopher Nolan',
      cast: ['Cillian Murphy', 'Emily Blunt', 'Matt Damon', 'Robert Downey Jr.'],
      isFeatured: false,
      isNowShowing: true,
    ),
    Movie(
      id: 'm6',
      title: 'Starlight Symphony',
      language: 'English',
      certification: 'U',
      posterUrl: 'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?q=80&w=800&auto=format&fit=crop',
      backdropUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=1600&auto=format&fit=crop',
      genres: ['Animation', 'Musical', 'Family'],
      duration: '1h 52m',
      rating: 8.6,
      releaseYear: 2024,
      pgRating: 'U',
      synopsis:
          'A young prodigy discovers that cosmic radio frequencies produce melodies that harmonize planetary gravity and sets out to conduct the universe.',
      director: 'Amara Lopez',
      cast: ['Maya Lin', 'Chris Evans', 'Zoe Kravitz'],
      isFeatured: false,
      isNowShowing: true,
    ),
    Movie(
      id: 'm7',
      title: 'Cyberpunk: Neon Horizon',
      language: 'English',
      certification: 'A',
      posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=800&auto=format&fit=crop',
      backdropUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=1600&auto=format&fit=crop',
      genres: ['Cyberpunk', 'Thriller', 'Mystery'],
      duration: '2h 15m',
      rating: 8.4,
      releaseYear: 2024,
      pgRating: 'A',
      synopsis:
          'In a sprawling rain-slicked metropolis powered by synthetic consciousness, an underground operative discovers a classified neural network altering the memories of the city elite.',
      director: 'Kavita Rao',
      cast: ['Alex Vance', 'Elena Rostova', 'Kenji Sato'],
      isFeatured: false,
      isNowShowing: true,
    ),
    Movie(
      id: 'm8',
      title: 'Kalki 2898 AD',
      language: 'Hindi',
      certification: 'U/A',
      posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=800&auto=format&fit=crop',
      backdropUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=1600&auto=format&fit=crop',
      genres: ['Sci-Fi', 'Mythology', 'Action'],
      duration: '3h 01m',
      rating: 8.2,
      releaseYear: 2024,
      pgRating: 'U/A',
      synopsis:
          'Set in a post-apocalyptic world in the year 2898 AD, a modern avatar of Vishnu descends to Earth to protect humanity from dark forces.',
      director: 'Nag Ashwin',
      cast: ['Prabhas', 'Amitabh Bachchan', 'Kamal Haasan', 'Deepika Padukone'],
      isFeatured: false,
      isNowShowing: true,
    ),
  ];

  /// Returns only upcoming available showtimes for the given date, cinema, and movie,
  /// strictly filtering out any showtimes that have already passed relative to local time.
  static List<Showtime> getAvailableUpcomingShowtimes({
    required String movieId,
    required String cinemaId,
    required DateTime targetDate,
    required String dateLabel,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final all = getShowtimesFor(
      movieId: movieId,
      cinemaId: cinemaId,
      dateLabel: dateLabel,
    );

    final isPastDate = targetDate.year < current.year ||
        (targetDate.year == current.year && targetDate.month < current.month) ||
        (targetDate.year == current.year && targetDate.month == current.month && targetDate.day < current.day);
    if (isPastDate) return [];

    final isToday = targetDate.year == current.year &&
        targetDate.month == current.month &&
        targetDate.day == current.day;

    if (!isToday) {
      return all;
    }

    return all.where((st) => !st.isPast(targetDate, now: current)).toList();
  }

  /// Backward-compatible query for a single movie's default showtimes.
  static List<Showtime> getShowtimesForMovie(String movieId) {
    return [
      Showtime(
        id: 'st_1_$movieId',
        movieId: movieId,
        cinemaId: 'c1',
        dateLabel: 'Fri 14 Nov',
        time: '17:30',
        hallName: 'Hall 3',
        experienceType: '2D',
        basePrice: 12.50,
        period: ShowtimePeriod.evening,
      ),
      Showtime(
        id: 'st_2_$movieId',
        movieId: movieId,
        cinemaId: 'c1',
        dateLabel: 'Fri 14 Nov',
        time: '16:45',
        hallName: 'Hall 3',
        experienceType: 'IMAX',
        basePrice: 12.50,
        period: ShowtimePeriod.evening,
      ),
      Showtime(
        id: 'st_3_$movieId',
        movieId: movieId,
        cinemaId: 'c1',
        dateLabel: 'Fri 14 Nov',
        time: '22:15',
        hallName: 'Hall 3',
        experienceType: '2D',
        basePrice: 12.50,
        period: ShowtimePeriod.night,
      ),
    ];
  }

  /// Comprehensive dynamic showtimes for (Movie x Cinema x Date) grouped into periods.
  static List<Showtime> getShowtimesFor({
    required String movieId,
    required String cinemaId,
    required String dateLabel,
  }) {
    // Determine variation seed from cinema and movie
    final seed = (movieId.hashCode ^ cinemaId.hashCode ^ dateLabel.hashCode).abs();

    final isImaxAvailable = cinemaId == 'c1' || cinemaId == 'c3' || cinemaId == 'c7';
    final is4dxAvailable = cinemaId == 'c1' || cinemaId == 'c4' || cinemaId == 'c6';
    final hallPrimary = 'Audi ${(seed % 5) + 1}';

    final result = <Showtime>[
      // Morning
      Showtime(
        id: 'st_${movieId}_${cinemaId}_m1',
        movieId: movieId,
        cinemaId: cinemaId,
        dateLabel: dateLabel,
        time: '09:45 AM',
        hallName: hallPrimary,
        experienceType: '2D',
        basePrice: 10.50,
        period: ShowtimePeriod.morning,
      ),
      Showtime(
        id: 'st_${movieId}_${cinemaId}_m2',
        movieId: movieId,
        cinemaId: cinemaId,
        dateLabel: dateLabel,
        time: '11:15 AM',
        hallName: hallPrimary,
        experienceType: isImaxAvailable ? 'IMAX 2D' : 'Dolby 7.1',
        basePrice: isImaxAvailable ? 14.00 : 11.50,
        period: ShowtimePeriod.morning,
      ),

      // Afternoon
      Showtime(
        id: 'st_${movieId}_${cinemaId}_a1',
        movieId: movieId,
        cinemaId: cinemaId,
        dateLabel: dateLabel,
        time: '01:30 PM',
        hallName: hallPrimary,
        experienceType: is4dxAvailable ? '4DX' : '2D',
        basePrice: is4dxAvailable ? 16.50 : 12.00,
        period: ShowtimePeriod.afternoon,
      ),
      Showtime(
        id: 'st_${movieId}_${cinemaId}_a2',
        movieId: movieId,
        cinemaId: cinemaId,
        dateLabel: dateLabel,
        time: '03:45 PM',
        hallName: hallPrimary,
        experienceType: isImaxAvailable ? 'IMAX 3D' : '3D',
        basePrice: isImaxAvailable ? 16.00 : 13.00,
        period: ShowtimePeriod.afternoon,
      ),

      // Evening
      Showtime(
        id: 'st_${movieId}_${cinemaId}_e1',
        movieId: movieId,
        cinemaId: cinemaId,
        dateLabel: dateLabel,
        time: '06:15 PM',
        hallName: hallPrimary,
        experienceType: isImaxAvailable ? 'IMAX 3D' : 'Dolby Atmos',
        basePrice: isImaxAvailable ? 17.50 : 13.50,
        period: ShowtimePeriod.evening,
      ),
      Showtime(
        id: 'st_${movieId}_${cinemaId}_e2',
        movieId: movieId,
        cinemaId: cinemaId,
        dateLabel: dateLabel,
        time: '07:30 PM',
        hallName: hallPrimary,
        experienceType: '2D',
        basePrice: 12.50,
        period: ShowtimePeriod.evening,
      ),

      // Night
      Showtime(
        id: 'st_${movieId}_${cinemaId}_n1',
        movieId: movieId,
        cinemaId: cinemaId,
        dateLabel: dateLabel,
        time: '09:20 PM',
        hallName: hallPrimary,
        experienceType: isImaxAvailable ? 'IMAX 2D' : 'Dolby Atmos',
        basePrice: isImaxAvailable ? 16.50 : 13.00,
        period: ShowtimePeriod.night,
      ),
      Showtime(
        id: 'st_${movieId}_${cinemaId}_n2',
        movieId: movieId,
        cinemaId: cinemaId,
        dateLabel: dateLabel,
        time: '10:45 PM',
        hallName: hallPrimary,
        experienceType: '2D',
        basePrice: 11.50,
        period: ShowtimePeriod.night,
      ),
    ];

    return result;
  }
}
