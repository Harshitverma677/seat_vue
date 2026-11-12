import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/movie.dart';
import '../../../models/seat.dart';
import '../models/auditorium_camera_state.dart';

/// 3D perspective projection viewport rendering the cinema auditorium.
class Cinema3DViewport extends StatelessWidget {
  final AuditoriumCameraState cameraState;
  final List<Seat> seats;
  final String? activeSeatId;
  final Movie movie;
  final ValueChanged<String>? onSeatTappedIn3D;

  const Cinema3DViewport({
    super.key,
    required this.cameraState,
    required this.seats,
    required this.activeSeatId,
    required this.movie,
    this.onSeatTappedIn3D,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: _Auditorium3DPainter(
          cameraState: cameraState,
          seats: seats,
          activeSeatId: activeSeatId,
          movie: movie,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _Auditorium3DPainter extends CustomPainter {
  final AuditoriumCameraState cameraState;
  final List<Seat> seats;
  final String? activeSeatId;
  final Movie movie;

  _Auditorium3DPainter({
    required this.cameraState,
    required this.seats,
    required this.activeSeatId,
    required this.movie,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Draw deep cinematic background
    final bgPaint = Paint()..color = const Color(0xFF07080C);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final eye = cameraState.position;
    final look = cameraState.effectiveLookTarget;

    // Compute Camera Basis Matrix
    double fx = look.x - eye.x;
    double fy = look.y - eye.y;
    double fz = look.z - eye.z;
    double flen = math.sqrt(fx * fx + fy * fy + fz * fz);
    if (flen < 0.001) flen = 0.001;
    fx /= flen;
    fy /= flen;
    fz /= flen;

    // World Up
    const double upWx = 0.0;
    const double upWy = 1.0;
    const double upWz = 0.0;

    // Right = Forward x Up
    double rx = fy * upWz - fz * upWy;
    double ry = fz * upWx - fx * upWz;
    double rz = fx * upWy - fy * upWx;
    double rlen = math.sqrt(rx * rx + ry * ry + rz * rz);
    if (rlen < 0.001) {
      rx = 1.0;
      ry = 0.0;
      rz = 0.0;
    } else {
      rx /= rlen;
      ry /= rlen;
      rz /= rlen;
    }

    // Camera Up = Right x Forward
    final ux = ry * fz - rz * fy;
    final uy = rz * fx - rx * fz;
    final uz = rx * fy - ry * fx;

    final fovRad = cameraState.fov * math.pi / 180.0;
    final focal = (size.width * 0.5) / math.tan(fovRad * 0.5);
    final cx = size.width * 0.5;
    final cy = size.height * 0.52;

    // Projection helper
    Offset? project(double wx, double wy, double wz) {
      final dx = wx - eye.x;
      final dy = wy - eye.y;
      final dz = wz - eye.z;

      final pz = dx * fx + dy * fy + dz * fz;
      if (pz < 0.2) return null; // Near clipping plane

      final px = dx * rx + dy * ry + dz * rz;
      final py = dx * ux + dy * uy + dz * uz;

      final sx = cx + (px * focal) / pz;
      final sy = cy - (py * focal) / pz;
      return Offset(sx, sy);
    }

    // 1. Draw Auditorium Walls and Ceiling
    _drawWalls(canvas, size, project);

    // 2. Draw Auditorium Tiered Floor
    _drawTieredFloor(canvas, project);

    // 3. Draw Massive Curved Cinema Screen
    _drawCurvedScreen(canvas, size, project);

    // 4. Draw Seat Rows with Depth Sorting (Back to Front relative to camera)
    _drawSeats(canvas, eye, project);

    // 5. Cinema Atmospheric Lighting and Vignette
    _drawAtmosphere(canvas, size);
  }

  void _drawWalls(Canvas canvas, Size size, Offset? Function(double, double, double) project) {
    final wallPaint = Paint()..color = const Color(0xFF0D0F18);
    final ceilingPaint = Paint()..color = const Color(0xFF090A10);

    // Left wall quad (X = -8.0, from Z = 0 to Z = 22, Y from 0 to 9)
    final l1 = project(-8.5, 0.0, 0.0);
    final l2 = project(-8.5, 9.0, 0.0);
    final l3 = project(-8.5, 9.0, 22.0);
    final l4 = project(-8.5, 0.0, 22.0);

    if (l1 != null && l2 != null && l3 != null && l4 != null) {
      final path = Path()
        ..moveTo(l1.dx, l1.dy)
        ..lineTo(l2.dx, l2.dy)
        ..lineTo(l3.dx, l3.dy)
        ..lineTo(l4.dx, l4.dy)
        ..close();
      canvas.drawPath(path, wallPaint);
    }

    // Right wall quad (X = 8.5)
    final r1 = project(8.5, 0.0, 0.0);
    final r2 = project(8.5, 9.0, 0.0);
    final r3 = project(8.5, 9.0, 22.0);
    final r4 = project(8.5, 0.0, 22.0);

    if (r1 != null && r2 != null && r3 != null && r4 != null) {
      final path = Path()
        ..moveTo(r1.dx, r1.dy)
        ..lineTo(r2.dx, r2.dy)
        ..lineTo(r3.dx, r3.dy)
        ..lineTo(r4.dx, r4.dy)
        ..close();
      canvas.drawPath(path, wallPaint);
    }

    // Ceiling quad (Y = 9.0)
    if (l2 != null && r2 != null && r3 != null && l3 != null) {
      final path = Path()
        ..moveTo(l2.dx, l2.dy)
        ..lineTo(r2.dx, r2.dy)
        ..lineTo(r3.dx, r3.dy)
        ..lineTo(l3.dx, l3.dy)
        ..close();
      canvas.drawPath(path, ceilingPaint);
    }
  }

  void _drawTieredFloor(Canvas canvas, Offset? Function(double, double, double) project) {
    // Auditorium stepped platforms for tiers
    final floorPaint = Paint()..color = const Color(0xFF10121C);
    final riserPaint = Paint()..color = const Color(0xFF161928);
    final aisleStripePaint = Paint()..color = AppColors.primary.withValues(alpha: 0.25);

    // Front stage / floor under screen
    final f1 = project(-8.5, 0.0, 0.0);
    final f2 = project(8.5, 0.0, 0.0);
    final f3 = project(8.5, 0.0, 5.0);
    final f4 = project(-8.5, 0.0, 5.0);

    if (f1 != null && f2 != null && f3 != null && f4 != null) {
      final path = Path()
        ..moveTo(f1.dx, f1.dy)
        ..lineTo(f2.dx, f2.dy)
        ..lineTo(f3.dx, f3.dy)
        ..lineTo(f4.dx, f4.dy)
        ..close();
      canvas.drawPath(path, floorPaint);
    }

    // Stepped tiers for each row (Z = 5 to Z = 20)
    for (int i = 0; i < 8; i++) {
      final double zStart = 5.0 + i * 1.5;
      final double zEnd = zStart + 1.5;
      final double yLevel = 0.5 + i * 0.42;
      final double yPrev = i == 0 ? 0.0 : (0.5 + (i - 1) * 0.42);

      // Riser vertical face
      final rv1 = project(-8.5, yPrev, zStart);
      final rv2 = project(8.5, yPrev, zStart);
      final rv3 = project(8.5, yLevel, zStart);
      final rv4 = project(-8.5, yLevel, zStart);

      if (rv1 != null && rv2 != null && rv3 != null && rv4 != null) {
        final path = Path()
          ..moveTo(rv1.dx, rv1.dy)
          ..lineTo(rv2.dx, rv2.dy)
          ..lineTo(rv3.dx, rv3.dy)
          ..lineTo(rv4.dx, rv4.dy)
          ..close();
        canvas.drawPath(path, riserPaint);
      }

      // Step horizontal platform
      final sp1 = project(-8.5, yLevel, zStart);
      final sp2 = project(8.5, yLevel, zStart);
      final sp3 = project(8.5, yLevel, zEnd);
      final sp4 = project(-8.5, yLevel, zEnd);

      if (sp1 != null && sp2 != null && sp3 != null && sp4 != null) {
        final path = Path()
          ..moveTo(sp1.dx, sp1.dy)
          ..lineTo(sp2.dx, sp2.dy)
          ..lineTo(sp3.dx, sp3.dy)
          ..lineTo(sp4.dx, sp4.dy)
          ..close();
        canvas.drawPath(path, floorPaint);

        // Center Aisle illuminated runner (between X = -0.6 and X = 0.6)
        final a1 = project(-0.6, yLevel, zStart);
        final a2 = project(0.6, yLevel, zStart);
        final a3 = project(0.6, yLevel, zEnd);
        final a4 = project(-0.6, yLevel, zEnd);

        if (a1 != null && a2 != null && a3 != null && a4 != null) {
          final aPath = Path()
            ..moveTo(a1.dx, a1.dy)
            ..lineTo(a2.dx, a2.dy)
            ..lineTo(a3.dx, a3.dy)
            ..lineTo(a4.dx, a4.dy)
            ..close();
          canvas.drawPath(aPath, aisleStripePaint);
        }
      }
    }
  }

  void _drawCurvedScreen(Canvas canvas, Size size, Offset? Function(double, double, double) project) {
    // 16 segments approximating curved cinema screen
    const int segments = 16;
    const double screenHalfWidth = 7.5;
    const double screenBottom = 0.6;
    const double screenTop = 6.8;
    const double screenCurveDepth = 1.1;

    final List<Offset> topPoints = [];
    final List<Offset> bottomPoints = [];

    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final x = -screenHalfWidth + t * (2.0 * screenHalfWidth);
      final normalizedX = x / screenHalfWidth;
      final z = (1.0 - (normalizedX * normalizedX)) * -screenCurveDepth;

      final pTop = project(x, screenTop, z);
      final pBottom = project(x, screenBottom, z);

      if (pTop != null && pBottom != null) {
        topPoints.add(pTop);
        bottomPoints.add(pBottom);
      }
    }

    if (topPoints.length >= 2 && bottomPoints.length >= 2) {
      final screenPath = Path()..moveTo(topPoints.first.dx, topPoints.first.dy);

      for (int i = 1; i < topPoints.length; i++) {
        screenPath.lineTo(topPoints[i].dx, topPoints[i].dy);
      }
      for (int i = bottomPoints.length - 1; i >= 0; i--) {
        screenPath.lineTo(bottomPoints[i].dx, bottomPoints[i].dy);
      }
      screenPath.close();

      // Screen Glow
      final glowPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
      canvas.drawPath(screenPath, glowPaint);

      // Screen Surface Fill with subtle cinema gradient
      final bounds = screenPath.getBounds();
      final screenPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1E2638),
            const Color(0xFF28354E),
            const Color(0xFF181F30),
          ],
        ).createShader(bounds);

      canvas.drawPath(screenPath, screenPaint);

      // Crisp Screen Border
      final borderPaint = Paint()
        ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(screenPath, borderPaint);

      // Center Movie Title & IMAX branding on the preview screen
      final screenCenter = project(0.0, 3.8, -screenCurveDepth);
      if (screenCenter != null) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${movie.title}\n',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
              shadows: [
                Shadow(color: Colors.black, blurRadius: 12),
                Shadow(color: AppColors.primary, blurRadius: 20),
              ],
            ),
            children: [
              TextSpan(
                text: 'IMAX LASER 3D EXPERIENCE\n',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryLight.withValues(alpha: 0.9),
                  letterSpacing: 2.5,
                ),
              ),
              TextSpan(
                text: 'VIEW FROM SEAT: ${activeSeatId ?? "OVERVIEW"}',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: bounds.width * 0.85);

        textPainter.paint(
          canvas,
          Offset(screenCenter.dx - (textPainter.width * 0.5), screenCenter.dy - (textPainter.height * 0.5)),
        );
      }
    }
  }

  void _drawSeats(Canvas canvas, Position3D eye, Offset? Function(double, double, double) project) {
    // Sort seats from farthest to closest relative to eye position (Painter's algorithm)
    final sortedSeats = List<Seat>.from(seats)
      ..sort((a, b) {
        final distA = (a.worldPosition.x - eye.x) * (a.worldPosition.x - eye.x) +
            (a.worldPosition.y - eye.y) * (a.worldPosition.y - eye.y) +
            (a.worldPosition.z - eye.z) * (a.worldPosition.z - eye.z);
        final distB = (b.worldPosition.x - eye.x) * (b.worldPosition.x - eye.x) +
            (b.worldPosition.y - eye.y) * (b.worldPosition.y - eye.y) +
            (b.worldPosition.z - eye.z) * (b.worldPosition.z - eye.z);
        return distB.compareTo(distA);
      });

    for (final seat in sortedSeats) {
      _drawSingleSeat(canvas, seat, eye, project);
    }
  }

  void _drawSingleSeat(
    Canvas canvas,
    Seat seat,
    Position3D eye,
    Offset? Function(double, double, double) project,
  ) {
    final pos = seat.worldPosition;
    final isActive = seat.id == activeSeatId;
    final isVip = seat.type == SeatType.vip;
    final isUnavailable = seat.isUnavailable;

    const double hw = 0.28; // Half seat width (meters)
    const double hd = 0.26; // Half seat depth
    const double backH = 0.55; // Backrest height
    const double seatBaseH = 0.35; // Seat cushion base height

    // Backrest Top Quad
    final bTopL = project(pos.x - hw, pos.y + seatBaseH + backH, pos.z + hd);
    final bTopR = project(pos.x + hw, pos.y + seatBaseH + backH, pos.z + hd);
    final bBotR = project(pos.x + hw, pos.y + seatBaseH, pos.z + hd);
    final bBotL = project(pos.x - hw, pos.y + seatBaseH, pos.z + hd);

    // Cushion Front Quad
    final cFrontL = project(pos.x - hw, pos.y + seatBaseH, pos.z - hd);
    final cFrontR = project(pos.x + hw, pos.y + seatBaseH, pos.z - hd);

    if (bTopL == null || bTopR == null || bBotR == null || bBotL == null) return;

    Color seatColor;
    Color borderColor;

    if (isActive) {
      seatColor = AppColors.seatSelected;
      borderColor = AppColors.seatSelectedBorder;
    } else if (isUnavailable) {
      seatColor = const Color(0xFF131620);
      borderColor = const Color(0xFF1C2030);
    } else if (isVip) {
      seatColor = const Color(0xFF6B21A8);
      borderColor = const Color(0xFF9333EA);
    } else {
      seatColor = const Color(0xFF22283C);
      borderColor = const Color(0xFF333B58);
    }

    final path = Path()
      ..moveTo(bTopL.dx, bTopL.dy)
      ..lineTo(bTopR.dx, bTopR.dy)
      ..lineTo(bBotR.dx, bBotR.dy)
      ..lineTo(bBotL.dx, bBotL.dy)
      ..close();

    // Active seat radiant glow aura
    if (isActive) {
      final glowPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawPath(path, glowPaint);
    }

    final fillPaint = Paint()..color = seatColor;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = isActive ? Colors.white : borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isActive ? 2.0 : 0.8;
    canvas.drawPath(path, borderPaint);

    // Cushion base (front face) if visible
    if (cFrontL != null && cFrontR != null) {
      final cushionPath = Path()
        ..moveTo(bBotL.dx, bBotL.dy)
        ..lineTo(bBotR.dx, bBotR.dy)
        ..lineTo(cFrontR.dx, cFrontR.dy)
        ..lineTo(cFrontL.dx, cFrontL.dy)
        ..close();

      final cushionPaint = Paint()..color = seatColor.withValues(alpha: 0.9);
      canvas.drawPath(cushionPath, cushionPaint);
      canvas.drawPath(cushionPath, borderPaint);
    }

    // Seat label on backrest if close enough
    final dz = pos.z - eye.z;
    if (dz.abs() < 12.0) {
      final labelOffset = Offset((bTopL.dx + bTopR.dx) * 0.5, (bTopL.dy + bBotL.dy) * 0.5);
      final labelPainter = TextPainter(
        text: TextSpan(
          text: seat.id,
          style: TextStyle(
            fontSize: isActive ? 10 : 8,
            fontWeight: FontWeight.w700,
            color: isActive ? AppColors.textInverse : AppColors.textMuted,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      labelPainter.paint(
        canvas,
        Offset(labelOffset.dx - labelPainter.width * 0.5, labelOffset.dy - labelPainter.height * 0.5),
      );
    }
  }

  void _drawAtmosphere(Canvas canvas, Size size) {
    // Subtle ambient cinema corner vignette
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.9,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.65),
        ],
        stops: const [0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignettePaint);
  }

  @override
  bool shouldRepaint(covariant _Auditorium3DPainter oldDelegate) {
    return oldDelegate.cameraState != cameraState ||
        oldDelegate.activeSeatId != activeSeatId ||
        oldDelegate.seats != seats ||
        oldDelegate.movie != movie;
  }
}
