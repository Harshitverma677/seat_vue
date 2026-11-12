import 'package:flutter/material.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/mock_auditoriums.dart';
import '../../../models/movie.dart';
import '../../../models/seat.dart';
import '../../../models/seat_camera_pose.dart';
import '../../../models/showtime.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../seat_selection/state/seat_selection_controller.dart';
import '../models/auditorium_camera_state.dart';
import '../services/auditorium_3d_service.dart';
import '../widgets/cinema_3d_viewport.dart';

/// Screen hosting the 3D cinema auditorium preview with smooth camera transitions.
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

  late AnimationController _recenterAnimController;
  double _recenterStartYaw = 0.0;
  double _recenterStartPitch = 0.0;

  AuditoriumCameraState? _transitionStartState;
  SeatCameraPose? _transitionTargetPose;

  bool _isReturning = false;

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
      duration: AppDurations.cameraTransition,
    );
    _cameraAnimController.addListener(_onCameraAnimationTick);

    _recenterAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _recenterAnimController.addListener(_onRecenterTick);

    // Initial camera dive: Overview -> Selected Seat eye pose
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateToPose(targetPose, duration: AppDurations.cameraTransition);
    });
  }

  @override
  void dispose() {
    _cameraAnimController.removeListener(_onCameraAnimationTick);
    _cameraAnimController.dispose();
    _recenterAnimController.removeListener(_onRecenterTick);
    _recenterAnimController.dispose();
    _auditoriumService.dispose();
    super.dispose();
  }

  void _onCameraAnimationTick() {
    if (_transitionStartState == null || _transitionTargetPose == null) return;

    final t = _cameraCurve?.value ?? _cameraAnimController.value;
    final interpolated = AuditoriumCameraState.lerp(
      _transitionStartState!,
      _transitionTargetPose!,
      t,
    );

    _auditoriumService.setInterpolatedState(interpolated);
  }

  void _onRecenterTick() {
    final t = Curves.easeOutCubic.transform(_recenterAnimController.value);
    final curYaw = _recenterStartYaw * (1.0 - t);
    final curPitch = _recenterStartPitch * (1.0 - t);

    _auditoriumService.setInterpolatedState(
      _auditoriumService.currentState.copyWith(
        yawOffset: curYaw,
        pitchOffset: curPitch,
      ),
    );
  }

  void _triggerSmoothRecenter() {
    if (_recenterAnimController.isAnimating || _auditoriumService.isAnimating) return;
    _recenterStartYaw = _auditoriumService.currentState.yawOffset;
    _recenterStartPitch = _auditoriumService.currentState.pitchOffset;
    _recenterAnimController.forward(from: 0.0);
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

  void _onSelectSeatInPreview(String seatId) {
    if (_auditoriumService.isAnimating || _isReturning) return;

    final seat = widget.seatController.getSeatById(seatId);
    if (seat == null || seat.isUnavailable) return;

    widget.seatController.setActivePreviewSeat(seatId);
    final targetPose = MockAuditoriums.getCameraPoseForSeat(seat);
    _animateToPose(targetPose, duration: AppDurations.cameraSwitchSeat);
  }

  void _handleBack() {
    if (_isReturning) return;
    _isReturning = true;

    // Smoothly animate back to overview pose, then pop
    _animateToPose(
      MockAuditoriums.overviewPose,
      duration: AppDurations.cameraReturn,
      onComplete: () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  String _getViewQualityDescription(Seat seat) {
    if (seat.type == SeatType.vip) return 'VIP Luxury Recliner · Panoramic High View';
    if (seat.rowLabel == 'C' || seat.rowLabel == 'D') {
      return 'IMAX Reference Sweet Spot · Eye-Level Alignment';
    }
    if (seat.rowLabel == 'A' || seat.rowLabel == 'B') {
      return 'Front Row Immersion · Towering Screen View';
    }
    return 'Balanced Cinema Seating · Great Acoustic Focus';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: ListenableBuilder(
          listenable: Listenable.merge([_auditoriumService, widget.seatController]),
          builder: (context, _) {
            final activeSeat = widget.seatController.activePreviewSeat ??
                (widget.seatController.selectedSeats.isNotEmpty
                    ? widget.seatController.selectedSeats.last
                    : widget.seatController.seats.first);

            final isLookAroundActive = _auditoriumService.currentState.yawOffset.abs() > 0.015 ||
                _auditoriumService.currentState.pitchOffset.abs() > 0.015;

            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. Interactive 3D Canvas with Pan Gestures for Look-Around
                GestureDetector(
                  onPanUpdate: (details) {
                    _auditoriumService.applyLookAround(details.delta.dx, details.delta.dy);
                  },
                  child: Cinema3DViewport(
                    cameraState: _auditoriumService.currentState,
                    seats: widget.seatController.seats,
                    activeSeatId: activeSeat.id,
                    movie: widget.movie,
                    onSeatTappedIn3D: (seatId) => _onSelectSeatInPreview(seatId),
                  ),
                ),

                // 2. Top Floating Navigation Bar (Reference A)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      top: 48,
                      bottom: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.9),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.65),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                            onPressed: _handleBack,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '3D SEAT PREVIEW',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${widget.movie.title} • ${widget.showtime.experienceType}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.titleMedium.copyWith(color: Colors.white, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        // Recenter Control
                        TextButton.icon(
                          onPressed: isLookAroundActive ? _triggerSmoothRecenter : null,
                          icon: Icon(
                            Icons.center_focus_strong_rounded,
                            size: 16,
                            color: isLookAroundActive ? AppColors.primary : AppColors.textMuted,
                          ),
                          label: Text(
                            'Recenter',
                            style: TextStyle(
                              color: isLookAroundActive ? AppColors.primary : AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black.withValues(alpha: 0.6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: const RoundedRectangleBorder(borderRadius: AppSpacing.roundedSm),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Compact Gesture Hint Overlay (Reference A)
                Positioned(
                  top: 106,
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: AppSpacing.roundedFull,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.touch_app_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Drag to look around · Tap a seat below to switch',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. Bottom Information Sheet (Reference A & B)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.96),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
                      border: const Border(
                        top: BorderSide(color: AppColors.surfaceBorder, width: 1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.85),
                          blurRadius: 28,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Sheet handle pill
                          Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceBorder,
                              borderRadius: AppSpacing.roundedFull,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Active Seat Info Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: AppSpacing.roundedMd,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  activeSeat.id,
                                  style: AppTypography.titleLarge.copyWith(
                                    color: AppColors.textInverse,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Row ${activeSeat.rowLabel} · Seat ${activeSeat.seatNumber}',
                                          style: AppTypography.titleMedium.copyWith(fontSize: 15),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: activeSeat.type == SeatType.vip ? AppColors.seatVip : AppColors.surfaceElevated,
                                            borderRadius: AppSpacing.roundedXs,
                                            border: Border.all(
                                              color: activeSeat.type == SeatType.vip ? AppColors.seatVipBorder : AppColors.surfaceBorder,
                                            ),
                                          ),
                                          child: Text(
                                            activeSeat.type == SeatType.vip ? 'VIP' : 'Standard',
                                            style: AppTypography.labelSmall.copyWith(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _getViewQualityDescription(activeSeat),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '\$${activeSeat.price.toStringAsFixed(2)}',
                                    style: AppTypography.titleLarge.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '${(activeSeat.worldPosition.z).toStringAsFixed(1)}m to screen',
                                    style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Quick Seat Switcher Pills in Active Row
                          SizedBox(
                            height: 38,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: MockAuditoriums.seatsPerRow,
                              separatorBuilder: (context, index) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final seatNum = index + 1;
                                final seatId = '${activeSeat.rowLabel}$seatNum';
                                final seat = widget.seatController.getSeatById(seatId);
                                final isCurActive = seatId == activeSeat.id;
                                final isUnavailable = seat?.isUnavailable ?? false;

                                return GestureDetector(
                                  onTap: isUnavailable ? null : () => _onSelectSeatInPreview(seatId),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    width: 38,
                                    decoration: BoxDecoration(
                                      color: isCurActive
                                          ? AppColors.primary
                                          : isUnavailable
                                              ? AppColors.seatUnavailable
                                              : const Color(0xFF8B151F), // Red velvet tone
                                      borderRadius: AppSpacing.roundedMd,
                                      border: Border.all(
                                        color: isCurActive
                                            ? AppColors.primary
                                            : isUnavailable
                                                ? AppColors.seatUnavailableBorder
                                                : const Color(0xFFA8222D),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$seatNum',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: isCurActive
                                              ? AppColors.textInverse
                                              : isUnavailable
                                                  ? AppColors.textMuted
                                                  : Colors.white,
                                          fontWeight: isCurActive ? FontWeight.w800 : FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          // Quick Row Switcher Tabs (A to H)
                          SizedBox(
                            height: 32,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: MockAuditoriums.rowLabels.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 6),
                              itemBuilder: (context, index) {
                                final row = MockAuditoriums.rowLabels[index];
                                final isRowActive = row == activeSeat.rowLabel;

                                return GestureDetector(
                                  onTap: () {
                                    final newSeatId = '$row${activeSeat.seatNumber}';
                                    _onSelectSeatInPreview(newSeatId);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: isRowActive ? AppColors.surfaceHighlight : Colors.transparent,
                                      borderRadius: AppSpacing.roundedSm,
                                      border: Border.all(
                                        color: isRowActive ? AppColors.primary : AppColors.surfaceBorder,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Row $row',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: isRowActive ? AppColors.primary : AppColors.textMuted,
                                          fontWeight: isRowActive ? FontWeight.w700 : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _handleBack,
                                  icon: const Icon(Icons.grid_view_rounded, size: 18),
                                  label: const Text('2D Seat Map'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    side: const BorderSide(color: AppColors.surfaceBorder),
                                    shape: const RoundedRectangleBorder(borderRadius: AppSpacing.roundedLg),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: PrimaryButton(
                                  label: widget.seatController.isSelected(activeSeat.id)
                                      ? 'Keep Selection'
                                      : 'Select Seat',
                                  icon: widget.seatController.isSelected(activeSeat.id)
                                      ? Icons.check_circle_rounded
                                      : Icons.add_circle_outline_rounded,
                                  height: 48,
                                  onPressed: () {
                                    if (!widget.seatController.isSelected(activeSeat.id)) {
                                      widget.seatController.toggleSeat(activeSeat.id);
                                    }
                                    _handleBack();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
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
}
