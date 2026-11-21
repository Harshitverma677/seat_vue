import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/mock_movies.dart';
import '../../../models/movie.dart';
import '../../../repositories/movie_repository.dart';
import '../../booking_selection/screens/booking_selection_screen.dart';
import '../../movie_details/screens/movie_details_screen.dart';
import '../widgets/movie_poster_carousel_card.dart';

/// Simplified, minimal Home Screen focusing entirely on sliding movie cards,
/// matching the exact video interaction from the reference:
/// - Prominent horizontally sliding movie cards carousel
/// - Active movie title, rounded genre pills, rating with vote counts
/// - Dedicated "Watch Trailer" option directly on the movie card and header
/// - Tapping the movie card navigates to Delhi cinema halls, date & showtime selection
/// - Minimal curved bottom navigation bar
class MovieDiscoveryDashboardScreen extends StatefulWidget {
  final MovieRepository? repository;
  final List<Movie>? initialMovies;

  const MovieDiscoveryDashboardScreen({
    super.key,
    this.repository,
    this.initialMovies,
  });

  @override
  State<MovieDiscoveryDashboardScreen> createState() => _MovieDiscoveryDashboardScreenState();
}

class _MovieDiscoveryDashboardScreenState extends State<MovieDiscoveryDashboardScreen> {
  late final PageController _pageController;
  int _currentPageIndex = 0;
  double _currentPageValue = 0.0;

  List<Movie> _movies = [];
  bool _isLoadingMovies = false;

  MovieRepository get _repository => widget.repository ?? MovieRepository.instance;

  // Bottom Navigation Index
  int _currentNavIndex = 0;

  // Search State
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82);
    _pageController.addListener(() {
      if (_pageController.hasClients) {
        setState(() {
          _currentPageValue = _pageController.page ?? 0.0;
        });
      }
    });

    if (widget.initialMovies != null && widget.initialMovies!.isNotEmpty) {
      _movies = widget.initialMovies!;
      _isLoadingMovies = false;
      _enrichMovies(_movies);
    } else {
      _movies = MockMovies.sampleMovies;
      _fetchNowPlayingMovies();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Movie? get _currentMovie =>
      _movies.isNotEmpty && _currentPageIndex < _movies.length
          ? _movies[_currentPageIndex]
          : null;

  Future<void> _fetchNowPlayingMovies() async {
    setState(() => _isLoadingMovies = true);
    try {
      final tmdbList = await _repository.getNowPlaying();
      if (mounted) {
        final converted = tmdbList.map((m) => m.toMovie()).toList();
        setState(() {
          _movies = converted.isNotEmpty ? converted : MockMovies.sampleMovies;
          _isLoadingMovies = false;
        });
        _enrichMovies(_movies);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _movies = MockMovies.sampleMovies;
          _isLoadingMovies = false;
        });
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  void _onMovieCardTapped(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingSelectionScreen(movie: movie),
      ),
    );
  }

  void _openMovieDetails(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MovieDetailsScreen(movie: movie),
      ),
    );
  }

  /// Asynchronously enriches loaded movies with their real TMDB runtime (e.g. 148m -> 2h 28m)
  /// and Indian release certification, reusing cached details.
  Future<void> _enrichMovies(List<Movie> list) async {
    for (int i = 0; i < list.length; i++) {
      final m = list[i];
      final tmdbId = int.tryParse(m.id);
      if (tmdbId != null) {
        try {
          final details = await _repository.getDetails(tmdbId);
          final releaseInfo = await _repository.getIndianReleaseInfo(tmdbId);
          if (mounted) {
            setState(() {
              if (i < _movies.length && _movies[i].id == m.id) {
                _movies[i] = _movies[i].copyWith(
                  duration: details.formattedRuntime.isNotEmpty ? details.formattedRuntime : _movies[i].duration,
                  certification: releaseInfo.certification ?? _movies[i].certification,
                  releaseYear: details.releaseYear > 0 ? details.releaseYear : _movies[i].releaseYear,
                );
              }
            });
          }
        } catch (_) {}
      }
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.trim().isEmpty) {
      _fetchNowPlayingMovies();
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _isLoadingMovies = true);
      try {
        final results = await _repository.search(query);
        if (mounted) {
          final converted = results.map((m) => m.toMovie()).toList();
          setState(() {
            _movies = converted;
            _currentPageIndex = 0;
            _isLoadingMovies = false;
          });
          if (_pageController.hasClients) {
            _pageController.jumpToPage(0);
          }
        }
      } catch (_) {
        if (mounted) setState(() => _isLoadingMovies = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final movie = _currentMovie;

    return Scaffold(
      backgroundColor: AppColors.background, // #141721
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Header: Movie Title & Icons (Search + Notification)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        movie?.title ?? 'SeatVue',
                        key: ValueKey<String>(movie?.id ?? 'title'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),

                  // Search Icon Button
                  IconButton(
                    icon: Icon(
                      _isSearching ? Icons.close_rounded : Icons.search_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _searchController.clear();
                          _fetchNowPlayingMovies();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            // Search Field (if searching)
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Search TMDB movies...',
                      hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

            // 2. Genre Pills Row matching video reference
            if (movie != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Wrap(
                    key: ValueKey<String>('genres_${movie.id}'),
                    spacing: 8,
                    runSpacing: 6,
                    children: movie.genres.map((g) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.0),
                        ),
                        child: Text(
                          g,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            // 3. Rating & Watch Trailer Action Row matching video
            if (movie != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
                child: Row(
                  children: [
                    // Rating with Underline
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 19, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${movie.rating.toStringAsFixed(1)}/10',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white54,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Info Pill Button (replaces Watch Trailer)
                    GestureDetector(
                      onTap: () => _openMovieDetails(movie),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.info_outline_rounded, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Info',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 4. Center Main Horizontally Sliding Movie Carousel
            Expanded(
              child: _isLoadingMovies && _movies.isEmpty
                  ? const Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
                      ),
                    )
                  : _movies.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.movie_filter_outlined, size: 48, color: AppColors.textMuted),
                              SizedBox(height: 10),
                              Text('No movies found', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                            ],
                          ),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: _movies.length,
                          onPageChanged: _onPageChanged,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final itemMovie = _movies[index];
                            final isActive = index == _currentPageIndex;

                            // Smooth scale and transformation calculation
                            final pageOffset = (_currentPageValue - index).abs();
                            final scale = (1.0 - (pageOffset * 0.08)).clamp(0.88, 1.0);
                            final opacity = (1.0 - (pageOffset * 0.25)).clamp(0.65, 1.0);

                            return Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: opacity,
                                child: MoviePosterCarouselCard(
                                  movie: itemMovie,
                                  isActive: isActive,
                                  onTap: () => _onMovieCardTapped(itemMovie),
                                ),
                              ),
                            );
                          },
                        ),
            ),

            // 5. Minimal Curved Bottom Navigation Bar matching the video
            Container(
              margin: const EdgeInsets.fromLTRB(28, 4, 28, 8),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface, // #1F2433
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Movie Reel / Cinema (Active)
                  _buildBottomNavItem(
                    0,
                    Icons.motion_photos_on_rounded,
                    isActive: _currentNavIndex == 0,
                  ),
                  // Tickets
                  _buildBottomNavItem(
                    1,
                    Icons.confirmation_number_outlined,
                    isActive: _currentNavIndex == 1,
                  ),
                  // Profile
                  _buildBottomNavItem(
                    2,
                    Icons.person_outline_rounded,
                    isActive: _currentNavIndex == 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, {required bool isActive}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentNavIndex = index;
        });
        if (index == 1 && _currentMovie != null) {
          _onMovieCardTapped(_currentMovie!);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Icon(
          icon,
          size: 24,
          color: isActive ? Colors.white : AppColors.textMuted,
        ),
      ),
    );
  }
}
