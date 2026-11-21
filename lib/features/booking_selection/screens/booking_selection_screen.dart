import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/mock_cinemas.dart';
import '../../../data/mock_movies.dart';
import '../../../models/cinema.dart';
import '../../../models/movie.dart';
import '../../../models/showtime.dart';
import '../../movie_discovery/widgets/cinema_selection_card.dart';
import '../../movie_discovery/widgets/date_selector_strip.dart';
import '../../seat_selection/screens/seat_selection_screen.dart';

/// Pre-cinema Booking Selection Screen:
/// - Fixed to Delhi theatres only (no other city options).
/// - Displays Delhi cinema halls.
/// - Automatically displays and highlights the earliest upcoming available showtime
///   embedded directly within the selected cinema card.
/// - Strictly eliminates past showtimes relative to device local time.
/// - Removed redundant separate bottom showtime strip.
class BookingSelectionScreen extends StatefulWidget {
  final Movie movie;

  const BookingSelectionScreen({
    super.key,
    required this.movie,
  });

  @override
  State<BookingSelectionScreen> createState() => _BookingSelectionScreenState();
}

class _BookingSelectionScreenState extends State<BookingSelectionScreen> {
  static const String fixedCity = 'Delhi';
  late final List<DateItem> _dates;
  int _selectedDateIndex = 0;

  late final List<Cinema> _availableCinemas;
  Cinema? _selectedCinema;

  List<Showtime> _availableShowtimes = [];
  Showtime? _selectedShowtime;

  @override
  void initState() {
    super.initState();
    _initializeDates();
    _availableCinemas = MockCinemas.delhiCinemas;
    if (_availableCinemas.isNotEmpty) {
      _selectedCinema = _availableCinemas.first;
    }
    _refreshShowtimes(preserveSelection: false);
  }

  void _initializeDates() {
    final now = DateTime.now();
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    _dates = List.generate(7, (i) {
      final date = now.add(Duration(days: i));
      String label;
      if (i == 0) {
        label = 'Today';
      } else if (i == 1) {
        label = 'Tomorrow';
      } else {
        label = days[date.weekday - 1];
      }

      return DateItem(
        date: date,
        label: label,
        dayNumber: date.day.toString().padLeft(2, '0'),
        month: months[date.month - 1],
      );
    });
  }

  void _onDateChanged(int index) {
    setState(() {
      _selectedDateIndex = index;
      _refreshShowtimes(preserveSelection: false);
    });
  }

  void _onCinemaSelected(Cinema cinema) {
    setState(() {
      _selectedCinema = cinema;
      _refreshShowtimes(preserveSelection: false);
    });
  }

  void _onShowtimeSelected(Showtime showtime) {
    setState(() {
      _selectedShowtime = showtime;
    });
  }

  /// Refreshes showtimes for selected movie, cinema, and date:
  /// - Strictly filters out past showtimes for today based on device local time.
  /// - Automatically selects and highlights the earliest upcoming showtime.
  void _refreshShowtimes({bool preserveSelection = true}) {
    if (_selectedCinema == null) {
      _availableShowtimes = [];
      _selectedShowtime = null;
      return;
    }

    final targetDateItem = _dates[_selectedDateIndex];
    final newShowtimes = MockMovies.getAvailableUpcomingShowtimes(
      movieId: widget.movie.id,
      cinemaId: _selectedCinema!.id,
      targetDate: targetDateItem.date,
      dateLabel: targetDateItem.fullDateLabel,
    );

    _availableShowtimes = newShowtimes;

    if (preserveSelection && _selectedShowtime != null) {
      final exists = newShowtimes.any((s) => s.id == _selectedShowtime!.id);
      if (exists) {
        // Current selection remains valid
        return;
      }
    }

    // Automatically highlight the earliest upcoming showtime
    _selectedShowtime = newShowtimes.isNotEmpty ? newShowtimes.first : null;
  }

  bool get _isBookingReady => _selectedCinema != null && _selectedShowtime != null;

  void _proceedToSeatSelection() {
    if (!_isBookingReady) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SeatSelectionScreen(
          movie: widget.movie,
          showtime: _selectedShowtime!,
          cinema: _selectedCinema!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final selectedDate = _dates[_selectedDateIndex];

    return Scaffold(
      backgroundColor: AppColors.background, // #141721
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.surface,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${movie.language} • ${movie.duration}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  // Fixed Delhi Location Badge (Non-switchable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.location_on_rounded, size: 13, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          fixedCity,
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Date Selector Strip
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                      child: Row(
                        children: [
                          const Text(
                            'Select Date',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          Text(
                            selectedDate.fullDateLabel,
                            style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    DateSelectorStrip(
                      dates: _dates,
                      selectedIndex: _selectedDateIndex,
                      onDateSelected: _onDateChanged,
                    ),

                    const SizedBox(height: 20),

                    // 2. Cinema Hall Selection (Delhi Theatres) with Embedded Showtimes
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text(
                            'Cinema Halls in Delhi',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          Text(
                            '${_availableCinemas.length} Halls',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: _availableCinemas.map((cinema) {
                          final isSelected = _selectedCinema?.id == cinema.id;
                          return CinemaSelectionCard(
                            cinema: cinema,
                            isSelected: isSelected,
                            showtimesCount: 8,
                            showtimes: isSelected ? _availableShowtimes : null,
                            selectedShowtime: isSelected ? _selectedShowtime : null,
                            onShowtimeSelected: _onShowtimeSelected,
                            onTap: () => _onCinemaSelected(cinema),
                          );
                        }).toList(),
                      ),
                    ),

                    // Redundant bottom showtime strip removed as requested.
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Sticky Bottom CTA: Continue to Seat Selection
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface, // #1F2433
                border: const Border(
                  top: BorderSide(color: AppColors.surfaceBorder, width: 1.2),
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
                    // Summary: Selected Cinema & Earliest Upcoming Showtime
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isBookingReady) ...[
                            Text(
                              _selectedCinema!.name.split(':').first,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_selectedShowtime!.time} (${_selectedShowtime!.experienceType})',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ] else ...[
                            const Text(
                              'Select an upcoming showtime',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Golden Continue Button
                    ElevatedButton(
                      onPressed: _isBookingReady ? _proceedToSeatSelection : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, // #F5B935
                        disabledBackgroundColor: AppColors.surfaceBorder,
                        foregroundColor: AppColors.textInverse, // #0F172A
                        disabledForegroundColor: AppColors.textMuted,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: _isBookingReady ? 4 : 0,
                        shadowColor: AppColors.primary.withValues(alpha: 0.35),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Continue to Seat Selection',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
