import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/mock_movies.dart';
import '../../../models/movie.dart';
import '../../../shared/widgets/movie_poster_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../movie_details/screens/movie_details_screen.dart';
import '../widgets/category_selector.dart';
import '../widgets/featured_carousel.dart';

/// Main movie discovery and home screen.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _categories = const ['All Movies', 'Now Showing', 'Coming Soon', 'IMAX 3D', 'Sci-Fi'];
  String _selectedCategory = 'All Movies';

  void _openMovieDetails(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MovieDetailsScreen(movie: movie),
      ),
    );
  }

  List<Movie> get _filteredNowShowing {
    final all = MockMovies.sampleMovies.where((m) => m.isNowShowing).toList();
    if (_selectedCategory == 'All Movies' || _selectedCategory == 'Now Showing') return all;
    if (_selectedCategory == 'Coming Soon') return [];
    if (_selectedCategory == 'IMAX 3D') return all.where((m) => m.isFeatured).toList();
    return all.where((m) => m.genres.contains(_selectedCategory)).toList();
  }

  List<Movie> get _filteredComingSoon {
    final all = MockMovies.sampleMovies.where((m) => !m.isNowShowing).toList();
    if (_selectedCategory == 'All Movies' || _selectedCategory == 'Coming Soon') return all;
    if (_selectedCategory == 'Now Showing') return [];
    return all.where((m) => m.genres.contains(_selectedCategory)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final featuredMovies = MockMovies.sampleMovies.where((m) => m.isFeatured).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Cinematic Top Header
          SliverAppBar(
            floating: true,
            pinned: false,
            snap: true,
            backgroundColor: AppColors.background.withValues(alpha: 0.95),
            elevation: 0,
            titleSpacing: AppSpacing.md,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs + 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppSpacing.roundedSm,
                  ),
                  child: const Icon(Icons.chair_alt_rounded, size: 20, color: AppColors.textInverse),
                ),
                const SizedBox(width: AppSpacing.sm),
                RichText(
                  text: const TextSpan(
                    style: AppTypography.titleLarge,
                    children: [
                      TextSpan(text: 'Seat'),
                      TextSpan(
                        text: 'Vue',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: AppSpacing.roundedFull,
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded, size: 13, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'IMAX Laser Cinema',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Featured Carousel
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.lg),
              child: FeaturedCarousel(
                movies: featuredMovies,
                onMovieSelected: _openMovieDetails,
              ),
            ),
          ),

          // Categories Filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: CategorySelector(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onSelected: (cat) => setState(() => _selectedCategory = cat),
              ),
            ),
          ),

          // Now Showing Section
          if (_filteredNowShowing.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Now Showing',
                subtitle: 'Select showtime & 3D seat preview',
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 290,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  scrollDirection: Axis.horizontal,
                  itemCount: _filteredNowShowing.length,
                  separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final movie = _filteredNowShowing[index];
                    return MoviePosterCard(
                      movie: movie,
                      onTap: () => _openMovieDetails(movie),
                    );
                  },
                ),
              ),
            ),
          ],

          // Coming Soon Section
          if (_filteredComingSoon.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: SectionHeader(
                  title: 'Coming Soon',
                  subtitle: 'Upcoming premieres & tickets',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 290,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  scrollDirection: Axis.horizontal,
                  itemCount: _filteredComingSoon.length,
                  separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final movie = _filteredComingSoon[index];
                    return MoviePosterCard(
                      movie: movie,
                      onTap: () => _openMovieDetails(movie),
                    );
                  },
                ),
              ),
            ),
          ],

          // Bottom Spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxl),
          ),
        ],
      ),
    );
  }
}
