import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/mock_auditoriums.dart';
import '../../../models/seat.dart';

/// Miniature seat map displayed in the top-right of the POV information sheet.
/// Renders a mini curved screen arc and all 9 × 14 = 126 seat dots with 3-8-3 aisle gaps.
/// The selected seat is highlighted in glowing mint green (#4ADE80).
class MiniatureSeatMap extends StatelessWidget {
  final Seat activeSeat;
  final ValueChanged<String>? onSeatSelected;

  const MiniatureSeatMap({
    super.key,
    required this.activeSeat,
    this.onSeatSelected,
  });

  @override
  Widget build(BuildContext context) {
    final int totalRows = MockAuditoriums.rowLabels.length;
    final int totalCols = MockAuditoriums.seatsPerRow;

    return Container(
      width: 86,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.checkoutSurface, // #121215
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini Curved Screen Arc
          CustomPaint(
            size: const Size(68, 6),
            painter: _MiniScreenArcPainter(),
          ),
          const SizedBox(height: 5),

          // Mini Dot Grid (9 rows x 14 columns)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(totalRows, (r) {
              final rowLabel = MockAuditoriums.rowLabels[r];
              final isCurrentRow = activeSeat.rowLabel == rowLabel;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(totalCols, (c) {
                    final colNumber = c + 1;
                    final isSelected = isCurrentRow && activeSeat.seatNumber == colNumber;

                    // Aisle gap margin after col 3 and col 11
                    final isAisleRight = c == 2 || c == 10;

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSeatSelected?.call('$rowLabel$colNumber'),
                      child: Padding(
                        padding: EdgeInsets.only(right: isAisleRight ? 3.0 : 0.0),
                        child: Container(
                          width: 3.2,
                          height: 3.2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.accent // #4ADE80
                                : const Color(0xFF2C2F3A),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.accent.withValues(alpha: 0.9),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MiniScreenArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width * 0.5, 0, size.width, size.height);

    final paint = Paint()
      ..color = const Color(0xFF8E929E).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
