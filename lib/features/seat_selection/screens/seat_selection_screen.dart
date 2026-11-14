import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/movie.dart';
import '../../../models/showtime.dart';
import '../../seat_preview/screens/seat_preview_screen.dart';
import '../state/seat_selection_controller.dart';
import '../widgets/screen_curve_indicator.dart';
import '../widgets/seat_grid.dart';
import '../widgets/seat_legend.dart';
import '../widgets/seat_summary_bar.dart';

/// Seat Selection Screen matching 01_PRODUCT_SPEC.md and 05_STEP_03_SEAT_SELECTION.md.
class SeatSelectionScreen extends StatefulWidget {
  final Movie movie;
  final Showtime showtime;

  const SeatSelectionScreen({
    super.key,
    required this.movie,
    required this.showtime,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  late final SeatSelectionController _controller;
  int _selectedShowtimeIndex = 1; // Default to 16:45 IMAX (specified in product spec)

  // Showtime pills in the required order
  final List<String> _showtimes = ['17:30 2D', '16:45 IMAX', '22:15 2D'];

  @override
  void initState() {
    super.initState();
    _controller = SeatSelectionController(
      basePrice: widget.showtime.basePrice,
      reclinerPrice: 16.00,
    );
    // Pre-select Row I Seat 12 by default as shown in reference recording
    _controller.toggleSeat('I12');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToPreview() {
    final activeSeat = _controller.activePreviewSeat ??
        (_controller.selectedSeats.isNotEmpty ? _controller.selectedSeats.last : null);

    if (activeSeat == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SeatPreviewScreen(
          movie: widget.movie,
          showtime: widget.showtime,
          seatController: _controller,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold, // #0A0A0C
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Top Header (Meridian / Hall 3 · Fri 14 Nov)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.surface, // #16161A
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Meridian',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hall 3 · Fri 14 Nov',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: AppColors.surface,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // 2. Rounded Showtime Selection Pill Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: AppColors.surface, // #16161A
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.surfaceBorder, width: 1.0), // #26262C
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_showtimes.length, (index) {
                    final isSelected = index == _selectedShowtimeIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedShowtimeIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.activePill : Colors.transparent, // #FFFFFF
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _showtimes[index],
                          style: TextStyle(
                            color: isSelected ? AppColors.activePillText : AppColors.textSecondary,
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // 3. Curved Cinema Screen Indicator
            const SizedBox(height: 6),
            const ScreenCurveIndicator(),
            const SizedBox(height: 12),

            // 4. Interactive 9-Row x 14-Col Seat Grid
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: SeatGrid(
                    controller: _controller,
                    onSeatSelected: (_) {
                      // Handled by controller single-seat toggle
                    },
                  ),
                ),
              ),
            ),

            // 5. Seat Status Legend (Available, Taken, Recliner, Selected)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: SeatLegend(),
            ),

            // 6. Sticky Bottom Checkout Bar
            SafeArea(
              top: false,
              child: SeatSummaryBar(
                controller: _controller,
                onContinue: _navigateToPreview,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
