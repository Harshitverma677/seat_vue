import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/mock_movies.dart';
import '../../../models/movie.dart';
import '../../../models/showtime.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../seat_selection/screens/seat_selection_screen.dart';
import '../widgets/showtime_selector.dart';

/// Detailed view for a movie including cast, synopsis, and showtime selection.
class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late final List<Showtime> _showtimes;
  Showtime? _selectedShowtime;

  @override
  void initState() {
    super.initState();
    _showtimes = MockMovies.getShowtimesForMovie(widget.movie.id);
    if (_showtimes.isNotEmpty) {
      _selectedShowtime = _showtimes.first;
    }
  }

  void _onProceedToSeats() {
    if (_selectedShowtime == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SeatSelectionScreen(
          movie: widget.movie,
          showtime: _selectedShowtime!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Scrollable Content
          CustomScrollView(
            slivers: [
              // Hero Backdrop with back button
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: AppColors.background,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.6),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        movie.backdropUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(color: AppColors.surfaceElevated),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                              AppColors.background.withValues(alpha: 0.8),
                              AppColors.background,
                            ],
                            stops: const [0.0, 0.35, 0.75, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Title and Meta Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(movie.title, style: AppTypography.displayLarge),
                      const SizedBox(height: AppSpacing.sm),
                      // Meta row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: AppSpacing.roundedXs,
                              border: Border.all(color: AppColors.surfaceBorder),
                              color: AppColors.surfaceElevated,
                            ),
                            child: Text(
                              movie.pgRating,
                              style: AppTypography.labelSmall.copyWith(color: AppColors.textPrimary),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '${movie.releaseYear}',
                            style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Text('•', style: TextStyle(color: AppColors.textMuted)),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            movie.duration,
                            style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Text('•', style: TextStyle(color: AppColors.textMuted)),
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(Icons.star_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            movie.rating.toStringAsFixed(1),
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Genre chips
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: movie.genres
                            .map((g) => StatusChip(
                                  label: g,
                                  backgroundColor: AppColors.surfaceElevated,
                                  textColor: AppColors.textSecondary,
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Synopsis
                      Text(
                        'SYNOPSIS',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        movie.synopsis,
                        style: AppTypography.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Cast & Crew
                      Text(
                        'DIRECTOR & CAST',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Director: ${movie.director}',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cast: ${movie.cast.join(', ')}',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.lg),
              ),

              // Showtime Selector
              SliverToBoxAdapter(
                child: ShowtimeSelector(
                  showtimes: _showtimes,
                  selectedShowtime: _selectedShowtime,
                  onShowtimeSelected: (st) => setState(() => _selectedShowtime = st),
                ),
              ),

              // Bottom padding for sticky button
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),

          // Bottom Floating Sticky CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.95),
                border: const Border(
                  top: BorderSide(color: AppColors.surfaceBorder, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    if (_selectedShowtime != null) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'From',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                          ),
                          Text(
                            '\$${_selectedShowtime!.basePrice.toStringAsFixed(2)}',
                            style: AppTypography.titleLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppSpacing.md),
                    ],
                    Expanded(
                      child: PrimaryButton(
                        label: 'Select Seats',
                        icon: Icons.event_seat_rounded,
                        onPressed: _selectedShowtime != null ? _onProceedToSeats : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
