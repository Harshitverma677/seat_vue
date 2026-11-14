import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/mock_auditoriums.dart';
import '../../../models/seat.dart';
import '../state/seat_selection_controller.dart';

/// 9-Row Auditorium Seat Grid with 3-8-3 column arrangement (14 seats total per row).
/// Designed according to 05_STEP_03_SEAT_SELECTION.md and 14_SEAT_METRICS_AND_GEOMETRY.md.
class SeatGrid extends StatelessWidget {
  final SeatSelectionController controller;
  final ValueChanged<String>? onSeatSelected;

  const SeatGrid({
    super.key,
    required this.controller,
    this.onSeatSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: MockAuditoriums.rowLabels.map((rowLabel) {
                return _buildRow(rowLabel);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(String rowLabel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row letter label
          SizedBox(
            width: 16,
            child: Text(
              rowLabel,
              style: const TextStyle(
                color: Color(0xFF6A6E7A),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Left Bank (Columns 1, 2, 3)
          ..._buildSeatColumns(rowLabel, [1, 2, 3]),

          // Left Aisle (Physical gap after seat 3)
          const SizedBox(width: 15),

          // Center Bank (Columns 4, 5, 6, 7, 8, 9, 10, 11)
          ..._buildSeatColumns(rowLabel, [4, 5, 6, 7, 8, 9, 10, 11]),

          // Right Aisle (Physical gap after seat 11)
          const SizedBox(width: 15),

          // Right Bank (Columns 12, 13, 14)
          ..._buildSeatColumns(rowLabel, [12, 13, 14]),
        ],
      ),
    );
  }

  List<Widget> _buildSeatColumns(String rowLabel, List<int> columns) {
    return columns.map((col) {
      final seatId = '$rowLabel$col';
      final seat = controller.getSeatById(seatId);

      if (seat == null) {
        return const SizedBox(width: 20, height: 18);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: _buildSeatCell(seat),
      );
    }).toList();
  }

  Widget _buildSeatCell(Seat seat) {
    final isSelected = controller.isSelected(seat.id);
    final isUnavailable = seat.isUnavailable;
    final isRecliner = seat.type == SeatType.recliner || seat.type == SeatType.vip;

    Color backgroundColor;
    Border? border;
    List<BoxShadow>? shadows;

    if (isSelected) {
      backgroundColor = AppColors.accent; // #4ADE80
      border = Border.all(color: const Color(0xFF86EFAC), width: 1.2);
      shadows = [
        BoxShadow(
          color: AppColors.accent.withValues(alpha: 0.5),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    } else if (isUnavailable) {
      backgroundColor = AppColors.takenFill; // #111114
      border = Border.all(color: AppColors.surfaceBorder, width: 1.2);
    } else if (isRecliner) {
      backgroundColor = AppColors.reclinerFill; // #2A1C1E
      border = Border.all(color: AppColors.seatReclinerBorder, width: 1.0);
    } else {
      backgroundColor = AppColors.availableFill; // #1E1E24
      border = Border.all(color: AppColors.availableBorder, width: 1.0);
    }

    return GestureDetector(
      onTap: isUnavailable
          ? null
          : () {
              // Single-seat toggle
              controller.toggleSeat(seat.id);
              onSeatSelected?.call(seat.id);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: isRecliner ? 20 : 18,
        height: 18,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4.0),
          border: border,
          boxShadow: shadows,
        ),
        alignment: Alignment.center,
        child: isSelected
            ? Text(
                '${seat.seatNumber}',
                style: const TextStyle(
                  color: AppColors.accentText, // #052E16
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              )
            : null,
      ),
    );
  }
}
