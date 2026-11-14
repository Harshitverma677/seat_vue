import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/mock_auditoriums.dart';
import '../../../models/seat.dart';
import '../state/seat_selection_controller.dart';

/// 9-Row Auditorium Seat Grid with 3-7-3 column arrangement matching reference video.
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

          // Left Aisle
          const SizedBox(width: 14),

          // Center Bank (Columns 4, 5, 6, 7, 8, 9, 10)
          ..._buildSeatColumns(rowLabel, [4, 5, 6, 7, 8, 9, 10]),

          // Right Aisle
          const SizedBox(width: 14),

          // Right Bank (Columns 11, 12, 13)
          ..._buildSeatColumns(rowLabel, [11, 12, 13]),
        ],
      ),
    );
  }

  List<Widget> _buildSeatColumns(String rowLabel, List<int> columns) {
    return columns.map((col) {
      final seatId = '$rowLabel$col';
      final seat = controller.getSeatById(seatId);

      // If it's an aisle gap in Recliner rows (H or I), render an empty placeholder
      if (seat == null && MockAuditoriums.aisleGaps.contains(seatId)) {
        return const SizedBox(width: 22, height: 20);
      }

      if (seat == null) {
        return const SizedBox(width: 22, height: 20);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.2),
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
      backgroundColor = AppColors.mintGreen;
      border = Border.all(color: const Color(0xFF8FF5C2), width: 1.2);
      shadows = [
        BoxShadow(
          color: AppColors.mintGreen.withValues(alpha: 0.55),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    } else if (isUnavailable) {
      backgroundColor = Colors.transparent;
      border = Border.all(color: const Color(0xFF333742), width: 1.4);
    } else if (isRecliner) {
      backgroundColor = AppColors.seatRecliner;
    } else {
      backgroundColor = AppColors.seatAvailable;
    }

    return GestureDetector(
      onTap: isUnavailable
          ? null
          : () {
              // Select single seat for 1-to-1 preview as shown in video
              controller.toggleSeat(seat.id);
              onSeatSelected?.call(seat.id);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4.5),
          border: border,
          boxShadow: shadows,
        ),
        alignment: Alignment.center,
        child: isSelected
            ? Text(
                '${seat.seatNumber}',
                style: const TextStyle(
                  color: Colors.black,
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
