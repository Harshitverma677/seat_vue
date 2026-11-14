import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/mock_auditoriums.dart';
import '../../../models/movie.dart';
import '../../../models/seat.dart';
import '../../../models/seat_camera_pose.dart';
import '../../../models/showtime.dart';
import '../../seat_selection/state/seat_selection_controller.dart';
import '../widgets/true_3d_cinema_viewport.dart';

/// Interactive Proof of Concept (POC) screen demonstrating the True 3D Cinema Renderer.
class Cinema3DPocScreen extends StatefulWidget {
  final Movie movie;
  final Showtime showtime;
  final SeatSelectionController seatController;

  const Cinema3DPocScreen({
    super.key,
    required this.movie,
    required this.showtime,
    required this.seatController,
  });

  @override
  State<Cinema3DPocScreen> createState() => _Cinema3DPocScreenState();
}

class _Cinema3DPocScreenState extends State<Cinema3DPocScreen> {
  final GlobalKey<True3DCinemaViewportState> _viewportKey = GlobalKey();
  late Seat _activeSeat;
  late SeatCameraPose _currentPose;
  String _rendererStatus = 'Initializing Three.js...';

  // Sample quick-switch seats spanning different rows and viewpoints
  static const List<String> _demoSeatIds = ['A4', 'D4', 'F8', 'H4'];

  @override
  void initState() {
    super.initState();
    final initialSeat = widget.seatController.activePreviewSeat ??
        widget.seatController.getSeatById('F8') ??
        widget.seatController.seats.first;
    _activeSeat = initialSeat;
    _currentPose = MockAuditoriums.getCameraPoseForSeat(initialSeat);
  }

  void _selectSeat(String seatId) {
    final seat = widget.seatController.getSeatById(seatId);
    if (seat == null) return;

    setState(() {
      _activeSeat = seat;
      _currentPose = MockAuditoriums.getCameraPoseForSeat(seat);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. True 3D Hardware-Accelerated Viewport
          True3DCinemaViewport(
            key: _viewportKey,
            cameraPose: _currentPose,
            onRendererEvent: (event) {
              if (event.isSceneReady) {
                setState(() => _rendererStatus = 'WebGL 3D (Three.js r128) · Active');
              } else if (event.isTransitionCompleted) {
                setState(() => _rendererStatus = 'Viewing from ${_activeSeat.id}');
              }
            },
          ),

          // 2. Top Bar
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
                      onPressed: () => Navigator.of(context).pop(),
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: AppSpacing.roundedXs,
                              ),
                              child: Text(
                                'TRUE 3D POC',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _rendererStatus,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.movie.title} • Seat ${_activeSeat.id}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleMedium.copyWith(color: Colors.white, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _viewportKey.currentState?.recenterCamera(),
                    icon: const Icon(Icons.center_focus_strong_rounded, size: 16, color: AppColors.primary),
                    label: const Text(
                      'Recenter',
                      style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700),
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

          // 3. Bottom Controls & Seat Switcher
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
                border: const Border(top: BorderSide(color: AppColors.surfaceBorder)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Viewpoint (Proof of Concept):',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                        ),
                        Text(
                          'Eye: (${_currentPose.cameraPosition.x.toStringAsFixed(1)}, ${_currentPose.cameraPosition.y.toStringAsFixed(1)}, ${_currentPose.cameraPosition.z.toStringAsFixed(1)}m)',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: _demoSeatIds.map((id) {
                        final isSelected = _activeSeat.id == id;
                        final label = id == 'A4'
                            ? 'A4 (Front)'
                            : id == 'D4'
                                ? 'D4 (Center)'
                                : id == 'F8'
                                    ? 'F8 (Ref B)'
                                    : 'H4 (VIP)';

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: InkWell(
                              onTap: () => _selectSeat(id),
                              borderRadius: AppSpacing.roundedSm,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
                                  borderRadius: AppSpacing.roundedSm,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  label,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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
