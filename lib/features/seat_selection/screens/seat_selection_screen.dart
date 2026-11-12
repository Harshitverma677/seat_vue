import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/movie.dart';
import '../../../models/showtime.dart';
import '../../seat_preview/screens/seat_preview_screen.dart';
import '../state/seat_selection_controller.dart';
import '../widgets/screen_curve_indicator.dart';
import '../widgets/seat_grid.dart';
import '../widgets/seat_legend.dart';
import '../widgets/seat_summary_bar.dart';

/// Screen for interactive 2D auditorium seat selection.
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
  late final SeatSelectionController _seatController;

  @override
  void initState() {
    super.initState();
    _seatController = SeatSelectionController(basePrice: widget.showtime.basePrice);
    // Select a popular sweet-spot seat by default for immediate preview gratification (e.g. C3 or D4)
    _seatController.toggleSeat('D4');
  }

  @override
  void dispose() {
    _seatController.dispose();
    super.dispose();
  }

  void _open3DSeatPreview([String? targetSeatId]) {
    if (targetSeatId != null) {
      _seatController.setActivePreviewSeat(targetSeatId);
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SeatPreviewScreen(
          movie: widget.movie,
          showtime: widget.showtime,
          seatController: _seatController,
        ),
      ),
    );
  }

  void _showMockBookingConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBorder,
                    borderRadius: AppSpacing.roundedFull,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Icon(Icons.check_circle_rounded, size: 56, color: AppColors.primary),
                const SizedBox(height: AppSpacing.md),
                Text('Ready for Booking', style: AppTypography.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'This is a local prototype preview.\nSelected: ${_seatController.selectedSeats.map((s) => s.id).join(', ')} • Total: \$${_seatController.totalPrice.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Back to Seat Selection'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          children: [
            Text(widget.movie.title, style: AppTypography.titleMedium),
            Text(
              '${widget.showtime.dateLabel} • ${widget.showtime.time} • ${widget.showtime.hallName}',
              style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Reset selection',
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: () => _seatController.clearSelection(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Seat Map Layout
          Positioned.fill(
            bottom: 120, // space for summary bar
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                // Screen Indicator
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: ScreenCurveIndicator(),
                ),

                const SizedBox(height: AppSpacing.md),

                // Seat Grid inside interactive pinch/scroll viewer
                Expanded(
                  child: InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(AppSpacing.lg),
                    minScale: 0.8,
                    maxScale: 2.0,
                    child: Center(
                      child: SeatGrid(
                        controller: _seatController,
                        onSeatDoubleTap: (seatId) => _open3DSeatPreview(seatId),
                      ),
                    ),
                  ),
                ),

                // Seat Legend
                const SeatLegend(),
                const SizedBox(height: AppSpacing.xs),
              ],
            ),
          ),

          // Floating Summary Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SeatSummaryBar(
              controller: _seatController,
              onOpen3DPreview: () => _open3DSeatPreview(),
              onProceed: _showMockBookingConfirmation,
            ),
          ),
        ],
      ),
    );
  }
}
