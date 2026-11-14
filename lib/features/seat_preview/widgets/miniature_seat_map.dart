import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/mock_auditoriums.dart';
import '../../../models/seat.dart';

/// Miniature seat map displayed in the top-right of the preview panel.
/// Shows a mini curved screen and a dot matrix representing the 9×13 auditorium,
/// with the active preview seat highlighted in glowing mint green.
class MiniatureSeatMap extends StatelessWidget {
  final Seat activeSeat;

  const MiniatureSeatMap({
    super.key,
    required this.activeSeat,
  });

  @override
  Widget build(BuildContext context) {
    const int totalRows = 9;
    const int totalCols = 13;

    return Container(
      width: 82,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF14161C),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini Curved Screen Arc
          CustomPaint(
            size: const Size(64, 6),
            painter: _MiniScreenArcPainter(),
          ),
          const SizedBox(height: 5),

          // Mini Dot Grid
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
                    final seatId = '$rowLabel$colNumber';
                    final isAisleGap = MockAuditoriums.aisleGaps.contains(seatId);

                    if (isAisleGap) {
                      return const SizedBox(width: 3.5, height: 3.5);
                    }

                    final isSelected = isCurrentRow && activeSeat.seatNumber == colNumber;

                    return Container(
                      width: 3.5,
                      height: 3.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.mintGreen
                            : const Color(0xFF333742),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.mintGreen.withValues(alpha: 0.8),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
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
      ..color = const Color(0xFF8E929E).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
