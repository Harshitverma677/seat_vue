import '../models/movie.dart';
import '../models/showtime.dart';

/// Local mock movie catalog.
class MockMovies {
  MockMovies._();

  static const List<Movie> sampleMovies = [
    Movie(
      id: 'm1',
      title: 'Dune: Part Two',
      posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=800&auto=format&fit=crop',
      backdropUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=1600&auto=format&fit=crop',
      genres: ['Sci-Fi', 'Adventure', 'Action'],
      duration: '2h 46m',
      rating: 8.8,
      releaseYear: 2024,
      pgRating: 'PG-13',
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
      posterUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=800&auto=format&fit=crop',
      backdropUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?q=80&w=1600&auto=format&fit=crop',
      genres: ['Sci-Fi', 'Drama'],
      duration: '2h 49m',
      rating: 8.7,
      releaseYear: 2024,
      pgRating: 'PG-13',
      synopsis:
          'When Earth becomes uninhabitable in the future, a farmer and ex-NASA pilot, Joseph Cooper, is tasked to pilot a spacecraft, along with a team of researchers, to find a new planet for humans.',
      director: 'Christopher Nolan',
      cast: ['Matthew McConaughey', 'Anne Hathaway', 'Jessica Chastain', 'Michael Caine'],
      isFeatured: true,
      isNowShowing: true,
    ),
    Movie(
      id: 'm3',
      title: 'Cyberpunk: Neon Horizon',
      posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=800&auto=format&fit=crop',
      backdropUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=1600&auto=format&fit=crop',
      genres: ['Cyberpunk', 'Thriller', 'Mystery'],
      duration: '2h 15m',
      rating: 8.4,
      releaseYear: 2024,
      pgRating: 'R',
      synopsis:
          'In a sprawling rain-slicked metropolis powered by synthetic consciousness, an underground operative discovers a classified neural network altering the memories of the city elite.',
      director: 'Kavita Rao',
      cast: ['Alex Vance', 'Elena Rostova', 'Kenji Sato'],
      isFeatured: false,
      isNowShowing: true,
    ),
    Movie(
      id: 'm4',
      title: 'The Dark Odyssey',
      posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=800&auto=format&fit=crop',
      backdropUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=1600&auto=format&fit=crop',
      genres: ['Action', 'Fantasy'],
      duration: '2h 28m',
      rating: 7.9,
      releaseYear: 2024,
      pgRating: 'PG-13',
      synopsis:
          'A forgotten warrior embarks on a dangerous pilgrimage through the subterranean abysses to rekindle the ancient beacon of humanity.',
      director: 'Marcus Thorne',
      cast: ['David Chen', 'Sarah Blake', 'Idris Ward'],
      isFeatured: false,
      isNowShowing: false,
    ),
    Movie(
      id: 'm5',
      title: 'Starlight Symphony',
      posterUrl: 'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?q=80&w=800&auto=format&fit=crop',
      backdropUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=1600&auto=format&fit=crop',
      genres: ['Animation', 'Musical', 'Family'],
      duration: '1h 52m',
      rating: 8.6,
      releaseYear: 2024,
      pgRating: 'PG',
      synopsis:
          'A young prodigy discovers that cosmic radio frequencies produce melodies that harmonize planetary gravity and sets out to conduct the universe.',
      director: 'Amara Lopez',
      cast: ['Maya Lin', 'Chris Evans', 'Zoe Kravitz'],
      isFeatured: false,
      isNowShowing: false,
    ),
  ];

  static List<Showtime> getShowtimesForMovie(String movieId) {
    return [
      Showtime(
        id: 'st_1_$movieId',
        movieId: movieId,
        dateLabel: 'Today, Nov 12',
        time: '14:30',
        hallName: 'IMAX Laser Hall 1',
        experienceType: 'IMAX 3D Laser',
        basePrice: 16.50,
      ),
      Showtime(
        id: 'st_2_$movieId',
        movieId: movieId,
        dateLabel: 'Today, Nov 12',
        time: '17:45',
        hallName: 'Dolby Cinema Hall 3',
        experienceType: 'Dolby Atmos + Vision',
        basePrice: 18.00,
      ),
      Showtime(
        id: 'st_3_$movieId',
        movieId: movieId,
        dateLabel: 'Today, Nov 12',
        time: '20:30',
        hallName: 'IMAX Laser Hall 1',
        experienceType: 'IMAX 3D Laser',
        basePrice: 19.50,
      ),
      Showtime(
        id: 'st_4_$movieId',
        movieId: movieId,
        dateLabel: 'Tomorrow, Nov 13',
        time: '16:00',
        hallName: 'Prime Cinema Hall 2',
        experienceType: 'Digital 4K',
        basePrice: 14.00,
      ),
      Showtime(
        id: 'st_5_$movieId',
        movieId: movieId,
        dateLabel: 'Tomorrow, Nov 13',
        time: '19:15',
        hallName: 'IMAX Laser Hall 1',
        experienceType: 'IMAX 3D Laser',
        basePrice: 19.50,
      ),
    ];
  }
}
