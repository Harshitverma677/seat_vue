import 'package:flutter/material.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/mock_auditoriums.dart';
import '../../../models/movie.dart';
import '../../../models/seat_camera_pose.dart';
import '../../../models/showtime.dart';
import '../../seat_selection/state/seat_selection_controller.dart';
import '../models/auditorium_camera_state.dart';
import '../services/auditorium_3d_service.dart';
import '../widgets/booking_confirmation_dialog.dart';
import '../widgets/cinema_3d_viewport.dart';
import '../widgets/miniature_seat_map.dart';
import 'cinema_3d_poc_screen.dart';

/// Screen hosting the 3D cinema auditorium preview matching 13_POV_HUD_AND_BOTTOM_SHEET.md.
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

class _SeatPreviewScreenState extends State<SeatPreviewScreen> with TickerProviderStateMixin {
  late final Auditorium3DService _auditoriumService;
  late AnimationController _cameraAnimController;
  Animation<double>? _cameraCurve;

  AuditoriumCameraState? _transitionStartState;
  SeatCameraPose? _transitionTargetPose;

  bool _isReturning = false;
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    final targetSeat = widget.seatController.activePreviewSeat ??
        (widget.seatController.selectedSeats.isNotEmpty
            ? widget.seatController.selectedSeats.last
            : widget.seatController.seats.first);

    final targetPose = MockAuditoriums.getCameraPoseForSeat(targetSeat);

    _auditoriumService = Auditorium3DService(initialPose: MockAuditoriums.overviewPose);

    _cameraAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // 1200ms per 09_STEP_07_CAMERA_AND_TRANSITIONS.md
    );
    _cameraAnimController.addListener(_onCameraAnimationTick);

    // Initial two-stage camera transition: Overhead (0-35%) -> Eye level (35-100%)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateToPose(targetPose, duration: const Duration(milliseconds: 1200));
    });
  }

  @override
  void dispose() {
    _cameraAnimController.removeListener(_onCameraAnimationTick);
    _cameraAnimController.dispose();
    _auditoriumService.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _onCameraAnimationTick() {
    if (_transitionStartState == null || _transitionTargetPose == null) return;

    final progress = _cameraCurve?.value ?? _cameraAnimController.value;

    // Two-stage interpolation:
    // Stage 1 (0% - 35%): Hold/fade overhead view
    // Stage 2 (35% - 100%): Curved path descent to seated eye level
    final double t;
    if (progress < 0.35) {
      t = 0.0;
    } else {
      t = ((progress - 0.35) / 0.65).clamp(0.0, 1.0);
    }

    final interpolated = AuditoriumCameraState.lerp(
      _transitionStartState!,
      _transitionTargetPose!,
      t,
    );

    _auditoriumService.setInterpolatedState(interpolated);
  }

  void _animateToPose(SeatCameraPose targetPose, {Duration? duration, VoidCallback? onComplete}) {
    if (_cameraAnimController.isAnimating) {
      _cameraAnimController.stop();
    }

    _transitionStartState = _auditoriumService.currentState;
    _transitionTargetPose = targetPose;

    _cameraAnimController.duration = duration ?? AppDurations.cameraSwitchSeat;
    _cameraCurve = CurvedAnimation(
      parent: _cameraAnimController,
      curve: Curves.easeInOutCubic,
    );

    _auditoriumService.setAnimating(true);
    _auditoriumService.setTargetPose(targetPose);

    _cameraAnimController.forward(from: 0.0).then((_) {
      _auditoriumService.setAnimating(false);
      onComplete?.call();
    });
  }

  void _handleBack() {
    if (_isReturning) return;
    _isReturning = true;

    // Smoothly animate camera back to overhead pose, then pop
    _animateToPose(
      MockAuditoriums.overviewPose,
      duration: const Duration(milliseconds: 800),
      onComplete: () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
    );
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
          listenable: Listenable.merge([_auditoriumService, widget.seatController]),
          builder: (context, _) {
            final activeSeat = widget.seatController.activePreviewSeat ??
                (widget.seatController.selectedSeats.isNotEmpty
                    ? widget.seatController.selectedSeats.last
                    : widget.seatController.seats.first);

            final metrics = MockAuditoriums.calculateMetrics(activeSeat);

            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. Interactive 3D Cinema Viewport with Look-Around Pan
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    _auditoriumService.applyLookAround(details.delta.dx, details.delta.dy);
                  },
                  child: Cinema3DViewport(
                    cameraState: _auditoriumService.currentState,
                    seats: widget.seatController.seats,
                    activeSeatId: activeSeat.id,
                    movie: widget.movie,
                    onSeatTappedIn3D: (seatId) {
                      widget.seatController.setActivePreviewSeat(seatId);
                      final seat = widget.seatController.getSeatById(seatId);
                      if (seat != null) {
                        _animateToPose(MockAuditoriums.getCameraPoseForSeat(seat));
                      }
                    },
                  ),
                ),

                // 2. Top Floating Header Bar (Back button, "• View from B4", 3D POC)
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

                          // Center Floating Pill: "• View from B4"
                          Expanded(
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.accent, // #4ADE80
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'View from ${activeSeat.id}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Right: True 3D WebGL POC shortcut
                          CircleAvatar(
                            backgroundColor: AppColors.surface.withValues(alpha: 0.85),
                            radius: 20,
                            child: IconButton(
                              tooltip: 'True 3D (POC)',
                              icon: const Icon(Icons.view_in_ar_rounded, color: AppColors.accent, size: 18),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => Cinema3DPocScreen(
                                      movie: widget.movie,
                                      showtime: widget.showtime,
                                      seatController: widget.seatController,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Draggable Information Sheet matching 13_POV_HUD_AND_BOTTOM_SHEET.md
                DraggableScrollableSheet(
                  controller: _sheetController,
                  initialChildSize: 0.38,
                  minChildSize: 0.24,
                  maxChildSize: 0.62,
                  snap: true,
                  snapSizes: const [0.24, 0.38, 0.62],
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

                                // 126-Dot Miniature Seat Map Widget
                                MiniatureSeatMap(activeSeat: activeSeat),
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
                            const SizedBox(height: 18),

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
