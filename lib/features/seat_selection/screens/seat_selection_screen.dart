import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/cinema.dart';
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
  final Cinema? cinema;

  const SeatSelectionScreen({
    super.key,
    required this.movie,
    required this.showtime,
    this.cinema,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  late final SeatSelectionController _controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

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
            // 1. Top Header (Cinema / Movie · Hall · Date · Time)
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
                        Text(
                          widget.cinema?.name ?? 'Meridian',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.movie.title} · ${widget.showtime.hallName} · ${widget.showtime.dateLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
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

            // 2. Curved Cinema Screen Indicator
            const SizedBox(height: 12),
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
