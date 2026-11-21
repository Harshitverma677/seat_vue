import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/mock_auditoriums.dart';
import '../../../models/movie.dart';
import '../../../models/showtime.dart';
import '../../seat_selection/state/seat_selection_controller.dart';
import '../widgets/booking_confirmation_dialog.dart';
import '../widgets/miniature_seat_map.dart';
import '../widgets/true_3d_cinema_viewport.dart';

/// Screen hosting the 3D cinema auditorium preview rendered directly with Three.js.
/// Replaces any Flutter CustomPainter auditorium rendering.
class SeatPreviewScreen extends StatefulWidget {
  final Movie movie;
  final Showtime showtime;
  final SeatSelectionController seatController;

  const SeatPreviewScreen({
    super.key,
    required this.movie,
    required this.showtime,
    required this.seatController,
  });

  @override
  State<SeatPreviewScreen> createState() => _SeatPreviewScreenState();
}

class _SeatPreviewScreenState extends State<SeatPreviewScreen> with WidgetsBindingObserver {
  final GlobalKey<True3DCinemaViewportState> _viewportKey = GlobalKey<True3DCinemaViewportState>();
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  bool _isReturning = false;
  bool _isFullScreen = false;

  // Stored portrait orientation to restore upon exit
  static const List<DeviceOrientation> _portraitOrientations = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ];

  static const List<DeviceOrientation> _landscapeOrientations = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations(_portraitOrientations);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _sheetController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Notify Three.js renderer when orientation or layout dimensions change
    _viewportKey.currentState?.notifyResize();
  }

  Future<void> _enterFullScreen() async {
    if (_isFullScreen) return;

    setState(() {
      _isFullScreen = true;
    });

    try {
      // 1. Switch device to landscape orientation on both Android and iOS
      await SystemChrome.setPreferredOrientations(_landscapeOrientations);

      // 2. Hide system status bar and nav bar for immersive cinematic viewing
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } catch (_) {
      // Graceful fallback if platform does not support orientation change
    }

    // 3. Notify Three.js WebGL renderer
    _viewportKey.currentState?.setFullscreen(true);
  }

  Future<void> _exitFullScreen() async {
    if (!_isFullScreen) return;

    setState(() {
      _isFullScreen = false;
    });

    try {
      // 1. Restore portrait orientation
      await SystemChrome.setPreferredOrientations(_portraitOrientations);

      // 2. Restore system status/navigation bars
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } catch (_) {
      // Graceful fallback
    }

    // 3. Notify Three.js WebGL renderer
    _viewportKey.currentState?.setFullscreen(false);
  }

  void _goToAdjacentSeat(int delta) {
    final seats = widget.seatController.seats;
    final activeSeat = widget.seatController.activePreviewSeat ??
        (widget.seatController.selectedSeats.isNotEmpty ? widget.seatController.selectedSeats.last : seats.first);
    final currentIndex = seats.indexWhere((s) => s.id == activeSeat.id);
    if (currentIndex == -1) return;

    var nextIndex = currentIndex + delta;
    while (nextIndex >= 0 && nextIndex < seats.length && seats[nextIndex].isUnavailable) {
      nextIndex += delta;
    }
    if (nextIndex >= 0 && nextIndex < seats.length) {
      widget.seatController.toggleSeat(seats[nextIndex].id);
    }
  }

  void _handleBack() {
    if (_isFullScreen) {
      _exitFullScreen();
      return;
    }
    if (_isReturning) return;
    _isReturning = true;

    // Smoothly animate camera back to overhead overview in Three.js, then pop
    _viewportKey.currentState?.reverseTransition(durationMs: 800);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffold, // #0A0A0C
        body: ListenableBuilder(
          listenable: widget.seatController,
          builder: (context, _) {
            final activeSeat = widget.seatController.activePreviewSeat ??
                (widget.seatController.selectedSeats.isNotEmpty
                    ? widget.seatController.selectedSeats.last
                    : widget.seatController.seats.first);

            final targetPose = MockAuditoriums.getCameraPoseForSeat(activeSeat);
            final metrics = MockAuditoriums.calculateMetrics(activeSeat);

            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. True 3D Cinema Viewport running Three.js WebGL with drag-to-look
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    _viewportKey.currentState?.sendLookDelta(details.delta.dx, details.delta.dy);
                  },
                  onDoubleTap: () {
                    _viewportKey.currentState?.recenterCamera();
                  },
                  child: True3DCinemaViewport(
                    key: _viewportKey,
                    cameraPose: targetPose,
                  ),
                ),

                // 2A. Top Floating Header Bar (visible in portrait mode)
                if (!_isFullScreen)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            // Circular Back Button
                            CircleAvatar(
                              backgroundColor: AppColors.surface.withValues(alpha: 0.85),
                              radius: 20,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                                onPressed: _handleBack,
                              ),
                            ),

                            // Center Floating Pill: "< • View from B4 >"
                            Expanded(
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => _goToAdjacentSeat(-1),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          child: Icon(Icons.chevron_left_rounded, color: Colors.white70, size: 20),
                                        ),
                                      ),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: AppColors.accent, // #4ADE80
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'View from ${activeSeat.id}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => _goToAdjacentSeat(1),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          child: Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Right: Fullscreen Toggle Button (enters landscape & cinema fullscreen)
                            CircleAvatar(
                              backgroundColor: AppColors.surface.withValues(alpha: 0.85),
                              radius: 20,
                              child: IconButton(
                                tooltip: 'Full Screen Cinema',
                                icon: const Icon(
                                  Icons.fullscreen_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: _enterFullScreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 2B. Landscape Fullscreen Exit Button (Floating Top Right)
                if (_isFullScreen)
                  Positioned(
                    top: 14,
                    right: 16,
                    child: SafeArea(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: _exitFullScreen,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.fullscreen_exit_rounded, color: AppColors.accent, size: 20),
                                  SizedBox(width: 6),
                                  Text(
                                    'Exit Fullscreen',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // 3. Draggable Information Sheet with smooth animated slide for fullscreen toggle
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOutCubic,
                  left: 0,
                  right: 0,
                  bottom: _isFullScreen ? -MediaQuery.of(context).size.height * 0.75 : 0,
                  height: MediaQuery.of(context).size.height,
                  child: IgnorePointer(
                    ignoring: _isFullScreen,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 260),
                      opacity: _isFullScreen ? 0.0 : 1.0,
                      child: DraggableScrollableSheet(
                        controller: _sheetController,
                        initialChildSize: 0.38,
                        minChildSize: 0.12,
                        maxChildSize: 0.62,
                        snap: true,
                        snapSizes: const [0.12, 0.38, 0.62],
                        builder: (context, scrollController) {
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.checkoutSurface.withValues(alpha: 0.98), // #121215
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                              border: const Border(
                                top: BorderSide(color: AppColors.surfaceBorder, width: 1.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  blurRadius: 30,
                                  offset: const Offset(0, -6),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              controller: scrollController,
                              physics: const ClampingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Drag Handle Pill
                                  Center(
                                    child: Container(
                                      width: 36,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF333744),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  // Row 1: Seat Info & 126-Dot Miniature Seat Map
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Zone Tag (UP CLOSE, SWEET SPOT, FULL PICTURE)
                                            Text(
                                              metrics.badgeLabel,
                                              style: const TextStyle(
                                                color: AppColors.accent, // #4ADE80
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                            const SizedBox(height: 4),

                                            // Main Title: "Row B, Seat 4"
                                            Text(
                                              'Row ${activeSeat.rowLabel}, Seat ${activeSeat.seatNumber}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                            const SizedBox(height: 3),

                                            // Subtitle: "Standard · €12.50" or "Recliner · €16.00"
                                            Text(
                                              '${activeSeat.type.name.capitalize()} · €${activeSeat.price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: Color(0xFF8E929E),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // 126-Dot Interactive Miniature Seat Map Widget
                                      MiniatureSeatMap(
                                        activeSeat: activeSeat,
                                        onSeatSelected: (seatId) => widget.seatController.toggleSeat(seatId),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Row 2: 3 Dynamic Metric Cards (to screen, field of view, lateral offset)
                                  Row(
                                    children: [
                                      _buildMetricCard(
                                        value: '${metrics.distanceToScreen.toStringAsFixed(1)} m',
                                        label: 'to screen',
                                      ),
                                      const SizedBox(width: 8),
                                      _buildMetricCard(
                                        value: '${metrics.fieldOfView}°',
                                        label: 'field of view',
                                      ),
                                      const SizedBox(width: 8),
                                      _buildMetricCard(
                                        value: '${metrics.distanceFromCentre.toStringAsFixed(1)} m',
                                        label: metrics.centreAlignmentLabel,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  // Quick Row Jump Selector (Directly test front, middle, and back rows)
                                  SizedBox(
                                    height: 30,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: MockAuditoriums.rowLabels.length,
                                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                                      itemBuilder: (context, rIndex) {
                                        final rLabel = MockAuditoriums.rowLabels[rIndex];
                                        final isCurrentRow = activeSeat.rowLabel == rLabel;
                                        return GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            widget.seatController.toggleSeat('${rLabel}8');
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 160),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: isCurrentRow ? AppColors.accent : AppColors.surface,
                                              borderRadius: BorderRadius.circular(15),
                                              border: Border.all(
                                                color: isCurrentRow ? AppColors.accent : AppColors.surfaceBorder,
                                              ),
                                            ),
                                            child: Text(
                                              'Row $rLabel',
                                              style: TextStyle(
                                                color: isCurrentRow ? AppColors.accentText : AppColors.textSecondary,
                                                fontSize: 11,
                                                fontWeight: isCurrentRow ? FontWeight.w800 : FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Row 3: Action Buttons (Change seat & Book)
                                  Row(
                                    children: [
                                      // Change Seat Button
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: _handleBack,
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: AppColors.availableFill, // #1E1E24
                                            side: const BorderSide(color: AppColors.availableBorder),
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: AppSpacing.roundedFull,
                                            ),
                                          ),
                                          child: const Text(
                                            'Change seat',
                                            style: TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Book Button
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            BookingConfirmationDialog.show(
                                              context,
                                              movie: widget.movie,
                                              showtime: widget.showtime,
                                              seat: activeSeat,
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: AppSpacing.roundedFull,
                                            ),
                                          ),
                                          child: Text(
                                            'Book · €${activeSeat.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricCard({required String value, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.metricSurface, // #1A1A1F
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF8E929E),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on String {
  String capitalize() => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}
