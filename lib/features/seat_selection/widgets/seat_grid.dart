import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/mock_auditoriums.dart';
import '../../../models/seat.dart';
import '../state/seat_selection_controller.dart';

/// Grid widget displaying auditorium rows and interactive seats.
class SeatGrid extends StatelessWidget {
  final SeatSelectionController controller;
  final ValueChanged<String>? onSeatDoubleTap; // Optional direct 3D preview trigger

  const SeatGrid({
    super.key,
    required this.controller,
    this.onSeatDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Column(
              children: MockAuditoriums.rowLabels.map((rowLabel) {
                return _buildSeatRow(rowLabel);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeatRow(String rowLabel) {
    final rowSeats = controller.seats.where((s) => s.rowLabel == rowLabel).toList()
      ..sort((a, b) => a.seatNumber.compareTo(b.seatNumber));

    // Split seats into left bank (1..4) and right bank (5..8)
    final leftBank = rowSeats.where((s) => s.seatNumber <= 4).toList();
    final rightBank = rowSeats.where((s) => s.seatNumber > 4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Left Row Label
          SizedBox(
            width: 20,
            child: Text(
              rowLabel,
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Left Bank
          ...leftBank.map((seat) => _buildSeatCell(seat)),

          // Aisle Gap
          const SizedBox(width: 24),

          // Right Bank
          ...rightBank.map((seat) => _buildSeatCell(seat)),

          const SizedBox(width: AppSpacing.xs),
          // Right Row Label
          SizedBox(
            width: 20,
            child: Text(
              rowLabel,
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatCell(Seat seat) {
    final isSelected = controller.isSelected(seat.id);
    final isUnavailable = seat.isUnavailable;
    final isVip = seat.type == SeatType.vip;
    final isActivePreview = controller.activePreviewSeatId == seat.id;

    Color bgColor;
    Color borderColor;
    bool hasGlow = false;

    if (isSelected) {
      bgColor = AppColors.seatSelected;
      borderColor = AppColors.seatSelectedBorder;
      hasGlow = true;
    } else if (isUnavailable) {
      bgColor = AppColors.seatUnavailable;
      borderColor = AppColors.seatUnavailableBorder;
    } else if (isVip) {
      bgColor = AppColors.seatVip.withValues(alpha: 0.85);
      borderColor = AppColors.seatVipBorder;
    } else {
      bgColor = AppColors.seatAvailable;
      borderColor = AppColors.seatAvailableBorder;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.5),
      child: GestureDetector(
        onTap: () => controller.toggleSeat(seat.id),
        onDoubleTap: onSeatDoubleTap != null ? () => onSeatDoubleTap!(seat.id) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
              bottom: Radius.circular(4),
            ),
            border: Border.all(
              color: isActivePreview ? Colors.white : borderColor,
              width: isActivePreview ? 2.0 : 1.0,
            ),
            boxShadow: hasGlow
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.6),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isSelected
                ? Text(
                    '${seat.seatNumber}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textInverse,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  )
                : isUnavailable
                    ? const Icon(
                        Icons.close_rounded,
                        size: 12,
                        color: AppColors.textMuted,
                      )
                    : Text(
                        '${seat.seatNumber}',
                        style: AppTypography.labelSmall.copyWith(
                          color: isVip ? Colors.white : AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}

