import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/movie.dart';
import '../../../models/seat.dart';
import '../models/auditorium_camera_state.dart';

/// 3D perspective projection viewport rendering the realistic cinema auditorium.
class Cinema3DViewport extends StatefulWidget {
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
  State<Cinema3DViewport> createState() => _Cinema3DViewportState();
}

class _Cinema3DViewportState extends State<Cinema3DViewport> {
  ui.Image? _screenImage;
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;

  @override
  void initState() {
    super.initState();
    _loadScreenImage();
  }

  @override
  void didUpdateWidget(covariant Cinema3DViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.movie.backdropUrl != widget.movie.backdropUrl) {
      _loadScreenImage();
    }
  }

  void _loadScreenImage() {
    if (widget.movie.backdropUrl.isEmpty) return;

    _imageStream?.removeListener(_imageListener!);
    final ImageProvider provider = NetworkImage(widget.movie.backdropUrl);
    _imageStream = provider.resolve(ImageConfiguration.empty);
    _imageListener = ImageStreamListener(
      (ImageInfo info, bool _) {
        if (mounted) {
          setState(() {
            _screenImage = info.image;
          });
        }
      },
      onError: (exception, stackTrace) {
        // Fallback to procedural cinematic screen graphics
      },
    );
    _imageStream!.addListener(_imageListener!);
  }

  @override
  void dispose() {
    if (_imageStream != null && _imageListener != null) {
      _imageStream!.removeListener(_imageListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: _Auditorium3DPainter(
          cameraState: widget.cameraState,
          seats: widget.seats,
          activeSeatId: widget.activeSeatId,
          movie: widget.movie,
          screenImage: _screenImage,
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
  final ui.Image? screenImage;

  _Auditorium3DPainter({
    required this.cameraState,
    required this.seats,
    required this.activeSeatId,
    required this.movie,
    required this.screenImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Deep cinema void background
    final bgPaint = Paint()..color = const Color(0xFF050609);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final eye = cameraState.position;
    final look = cameraState.effectiveLookTarget;

    // Compute Camera Basis Matrix (Forward, Right, Up)
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

    // Right = Forward x WorldUp
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

    // Focal length from field of view
    final fovRad = cameraState.fov * math.pi / 180.0;
    final focal = (size.width * 0.5) / math.tan(fovRad * 0.5);
    final cx = size.width * 0.5;
    // Align screen horizon comfortably in upper-mid viewport
    final cy = size.height * 0.44;

    // 3D to 2D projection function with near-plane clipping
    Offset? project(double wx, double wy, double wz) {
      final dx = wx - eye.x;
      final dy = wy - eye.y;
      final dz = wz - eye.z;

      final pz = dx * fx + dy * fy + dz * fz;
      if (pz < 0.25) return null; // Near clipping plane

      final px = dx * rx + dy * ry + dz * rz;
      final py = dx * ux + dy * uy + dz * uz;

      final sx = cx + (px * focal) / pz;
      final sy = cy - (py * focal) / pz;
      return Offset(sx, sy);
    }

    // 1. Draw Acoustic Walls, Sconces, and Ceiling
    _drawAuditoriumEnclosure(canvas, size, project);

    // 2. Draw Tiered Floor Risers & Aisle Runners
    _drawTieredFlooring(canvas, eye, project);

    // 3. Draw Curved Cinema Screen & Movie Image
    _drawCurvedCinemaScreen(canvas, size, project);

    // 4. Draw Seating Rows with Realistic Red Velvet Models
    _drawCinemaSeats(canvas, eye, project);

    // 5. Draw Viewer's Own Armrests & Flanking Foreground Controls
    _drawViewerForegroundArmrests(canvas, size, eye, project);

    // 6. Draw Screen Light Spill & Atmospheric Cinema Vignette
    _drawLightingAndVignette(canvas, size);
  }

  void _drawAuditoriumEnclosure(Canvas canvas, Size size, Offset? Function(double, double, double) project) {
    final wallPaint = Paint()..color = const Color(0xFF0A0C14);
    final slatDarkPaint = Paint()..color = const Color(0xFF07080E);
    final slatHighlightPaint = Paint()..color = const Color(0xFF141824);
    final ceilingPaint = Paint()..color = const Color(0xFF06070B);

    // Side acoustic walls (X = -8.2 and X = +8.2, from Z = 0 to 22, Y = 0 to 9)
    final l1 = project(-8.2, 0.0, 0.0);
    final l2 = project(-8.2, 9.0, 0.0);
    final l3 = project(-8.2, 9.0, 22.0);
    final l4 = project(-8.2, 0.0, 22.0);

    if (l1 != null && l2 != null && l3 != null && l4 != null) {
      final path = Path()
        ..moveTo(l1.dx, l1.dy)
        ..lineTo(l2.dx, l2.dy)
        ..lineTo(l3.dx, l3.dy)
        ..lineTo(l4.dx, l4.dy)
        ..close();
      canvas.drawPath(path, wallPaint);
    }

    final r1 = project(8.2, 0.0, 0.0);
    final r2 = project(8.2, 9.0, 0.0);
    final r3 = project(8.2, 9.0, 22.0);
    final r4 = project(8.2, 0.0, 22.0);

    if (r1 != null && r2 != null && r3 != null && r4 != null) {
      final path = Path()
        ..moveTo(r1.dx, r1.dy)
        ..lineTo(r2.dx, r2.dy)
        ..lineTo(r3.dx, r3.dy)
        ..lineTo(r4.dx, r4.dy)
        ..close();
      canvas.drawPath(path, wallPaint);
    }

    // Ceiling
    if (l2 != null && r2 != null && r3 != null && l3 != null) {
      final path = Path()
        ..moveTo(l2.dx, l2.dy)
        ..lineTo(r2.dx, r2.dy)
        ..lineTo(r3.dx, r3.dy)
        ..lineTo(l3.dx, l3.dy)
        ..close();
      canvas.drawPath(path, ceilingPaint);
    }

    // Vertical acoustic slats & architectural sconces on left and right walls
    for (double z = 2.0; z <= 20.0; z += 3.0) {
      // Left wall vertical panel rib
      final slBot = project(-8.2, 0.0, z);
      final slTop = project(-8.2, 8.5, z);
      if (slBot != null && slTop != null) {
        canvas.drawLine(slBot, slTop, slatDarkPaint..strokeWidth = 3.0);
        canvas.drawLine(Offset(slBot.dx + 2, slBot.dy), Offset(slTop.dx + 2, slTop.dy), slatHighlightPaint..strokeWidth = 1.0);
      }

      // Right wall vertical panel rib
      final srBot = project(8.2, 0.0, z);
      final srTop = project(8.2, 8.5, z);
      if (srBot != null && srTop != null) {
        canvas.drawLine(srBot, srTop, slatDarkPaint..strokeWidth = 3.0);
        canvas.drawLine(Offset(srBot.dx - 2, srBot.dy), Offset(srTop.dx - 2, srTop.dy), slatHighlightPaint..strokeWidth = 1.0);
      }

      // Subtle warm wall sconce lights
      final sconceL = project(-8.15, 4.2, z);
      if (sconceL != null) {
        final sconceGlow = Paint()
          ..color = const Color(0x28FFA726)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
        canvas.drawCircle(sconceL, 8.0, sconceGlow);
        canvas.drawCircle(sconceL, 2.5, Paint()..color = const Color(0xFFFFD180));
      }

      final sconceR = project(8.15, 4.2, z);
      if (sconceR != null) {
        final sconceGlow = Paint()
          ..color = const Color(0x28FFA726)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
        canvas.drawCircle(sconceR, 8.0, sconceGlow);
        canvas.drawCircle(sconceR, 2.5, Paint()..color = const Color(0xFFFFD180));
      }
    }
  }

  void _drawTieredFlooring(Canvas canvas, Position3D eye, Offset? Function(double, double, double) project) {
    final floorCarpetPaint = Paint()..color = const Color(0xFF0E1018);
    final riserPaint = Paint()..color = const Color(0xFF151824);
    final aisleCarpetPaint = Paint()..color = const Color(0xFF12141F);
    final stepLightPaint = Paint()..color = const Color(0x80FFB300);

    // Front stage below screen (Z = 0 to 5)
    final f1 = project(-8.2, 0.0, 0.0);
    final f2 = project(8.2, 0.0, 0.0);
    final f3 = project(8.2, 0.0, 5.0);
    final f4 = project(-8.2, 0.0, 5.0);
    if (f1 != null && f2 != null && f3 != null && f4 != null) {
      final p = Path()
        ..moveTo(f1.dx, f1.dy)
        ..lineTo(f2.dx, f2.dy)
        ..lineTo(f3.dx, f3.dy)
        ..lineTo(f4.dx, f4.dy)
        ..close();
      canvas.drawPath(p, floorCarpetPaint);
    }

    // Stepped risers for 8 rows (Z = 5.0 to 18.0)
    for (int i = 0; i < 8; i++) {
      final double zStart = 5.0 + i * 1.5;
      final double zEnd = zStart + 1.5;
      final double yLevel = 0.5 + i * 0.42;
      final double yPrev = i == 0 ? 0.0 : (0.5 + (i - 1) * 0.42);

      // Riser face
      final rv1 = project(-8.2, yPrev, zStart);
      final rv2 = project(8.2, yPrev, zStart);
      final rv3 = project(8.2, yLevel, zStart);
      final rv4 = project(-8.2, yLevel, zStart);

      if (rv1 != null && rv2 != null && rv3 != null && rv4 != null) {
        final rPath = Path()
          ..moveTo(rv1.dx, rv1.dy)
          ..lineTo(rv2.dx, rv2.dy)
          ..lineTo(rv3.dx, rv3.dy)
          ..lineTo(rv4.dx, rv4.dy)
          ..close();
        canvas.drawPath(rPath, riserPaint);

        // Soft LED step light along center aisle edge
        final sl1 = project(-0.7, yLevel - 0.05, zStart);
        final sl2 = project(0.7, yLevel - 0.05, zStart);
        if (sl1 != null && sl2 != null) {
          canvas.drawLine(sl1, sl2, stepLightPaint..strokeWidth = 2.0);
        }
      }

      // Tread horizontal tier surface
      final sp1 = project(-8.2, yLevel, zStart);
      final sp2 = project(8.2, yLevel, zStart);
      final sp3 = project(8.2, yLevel, zEnd);
      final sp4 = project(-8.2, yLevel, zEnd);

      if (sp1 != null && sp2 != null && sp3 != null && sp4 != null) {
        final sPath = Path()
          ..moveTo(sp1.dx, sp1.dy)
          ..lineTo(sp2.dx, sp2.dy)
          ..lineTo(sp3.dx, sp3.dy)
          ..lineTo(sp4.dx, sp4.dy)
          ..close();
        canvas.drawPath(sPath, floorCarpetPaint);

        // Center Aisle Runner
        final a1 = project(-0.65, yLevel, zStart);
        final a2 = project(0.65, yLevel, zStart);
        final a3 = project(0.65, yLevel, zEnd);
        final a4 = project(-0.65, yLevel, zEnd);
        if (a1 != null && a2 != null && a3 != null && a4 != null) {
          final aPath = Path()
            ..moveTo(a1.dx, a1.dy)
            ..lineTo(a2.dx, a2.dy)
            ..lineTo(a3.dx, a3.dy)
            ..lineTo(a4.dx, a4.dy)
            ..close();
          canvas.drawPath(aPath, aisleCarpetPaint);
        }
      }
    }
  }

  void _drawCurvedCinemaScreen(Canvas canvas, Size size, Offset? Function(double, double, double) project) {
    const int segments = 20;
    const double screenHalfWidth = 7.6;
    const double screenBottom = 0.9;
    const double screenTop = 6.9;
    const double screenCurveDepth = 1.05;

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

      // Atmospheric screen glow cast into cinema
      final screenGlowPaint = Paint()
        ..color = const Color(0x334A628A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 36);
      canvas.drawPath(screenPath, screenGlowPaint);

      // Matte Black Bezel / Frame
      final framePaint = Paint()
        ..color = const Color(0xFF030305)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14.0
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(screenPath, framePaint);

      final bounds = screenPath.getBounds();

      // Draw Movie Image or Cinematic Standby Graphic on screen surface
      canvas.save();
      canvas.clipPath(screenPath);

      if (screenImage != null) {
        final src = Rect.fromLTWH(0, 0, screenImage!.width.toDouble(), screenImage!.height.toDouble());
        canvas.drawImageRect(
          screenImage!,
          src,
          bounds,
          Paint()..filterQuality = FilterQuality.high,
        );

        // Cinematic anamorphic screen grading tint
        final screenTint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.15),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.35),
            ],
          ).createShader(bounds);
        canvas.drawRect(bounds, screenTint);
      } else {
        // High-fidelity procedural movie screen still
        final fallbackShader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF161F33),
            const Color(0xFF253456),
            const Color(0xFF141926),
          ],
        ).createShader(bounds);
        canvas.drawRect(bounds, Paint()..shader = fallbackShader);

        // Center cinema projection art
        final screenCenter = project(0.0, 3.9, -screenCurveDepth);
        if (screenCenter != null) {
          final tp = TextPainter(
            text: TextSpan(
              text: '${movie.title.toUpperCase()}\n',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(color: Colors.black, blurRadius: 16),
                  Shadow(color: AppColors.primary, blurRadius: 24),
                ],
              ),
              children: [
                TextSpan(
                  text: 'IMAX 70MM LASER PRESENTATION\n',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight.withValues(alpha: 0.9),
                    letterSpacing: 3.0,
                  ),
                ),
                TextSpan(
                  text: 'SEAT VIEW: ${activeSeatId ?? "OVERVIEW"}',
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

          tp.paint(
            canvas,
            Offset(screenCenter.dx - (tp.width * 0.5), screenCenter.dy - (tp.height * 0.5)),
          );
        }
      }

      canvas.restore();

      // Sharp inner border
      final innerBorder = Paint()
        ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      canvas.drawPath(screenPath, innerBorder);
    }
  }

  void _drawCinemaSeats(Canvas canvas, Position3D eye, Offset? Function(double, double, double) project) {
    // Sort seats from farthest to nearest relative to eye (Painter's algorithm)
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
      // Don't render the viewer's own seat back directly in front of the camera
      // (The viewer is sitting in this seat; their own backrest is behind them)
      if (seat.id == activeSeatId) {
        continue;
      }
      _drawRealisticCinemaSeat(canvas, seat, eye, project);
    }
  }

  void _drawRealisticCinemaSeat(
    Canvas canvas,
    Seat seat,
    Position3D eye,
    Offset? Function(double, double, double) project,
  ) {
    final pos = seat.worldPosition;
    final isSelected = seat.status == SeatStatus.selected;
    final isVip = seat.type == SeatType.vip;
    final isUnavailable = seat.isUnavailable;

    // Check if this seat is directly in the viewer's immediate foreground row ahead
    final dz = pos.z - eye.z;
    final isForegroundAhead = dz < 0 && dz.abs() < 2.2;

    const double hw = 0.32; // Seat half width (0.64m wide luxury seat)
    const double cushionH = 0.42; // Base seat height from floor
    const double lumbarH = 0.48; // Lumbar cushion height
    const double headrestH = 0.28; // Headrest cushion height
    const double totalBackH = lumbarH + headrestH; // 0.76m total backrest height

    // Palette: Rich cinema red velvet upholstery with multi-tier shading
    Color velvetPrimary;
    Color velvetShadow;
    Color velvetHighlight;
    Color shellColor;
    Color borderColor;

    if (isSelected) {
      velvetPrimary = const Color(0xFFC0212E);
      velvetShadow = const Color(0xFF82121B);
      velvetHighlight = const Color(0xFFFF5252);
      shellColor = const Color(0xFF1E1012);
      borderColor = AppColors.primary;
    } else if (isUnavailable) {
      velvetPrimary = const Color(0xFF1E2230);
      velvetShadow = const Color(0xFF141722);
      velvetHighlight = const Color(0xFF2C3246);
      shellColor = const Color(0xFF10121A);
      borderColor = const Color(0xFF222634);
    } else if (isVip) {
      velvetPrimary = const Color(0xFF7E22CE);
      velvetShadow = const Color(0xFF581C87);
      velvetHighlight = const Color(0xFFA855F7);
      shellColor = const Color(0xFF160E22);
      borderColor = const Color(0xFF9333EA);
    } else {
      // Classic deep ruby cinema red
      velvetPrimary = const Color(0xFF981B24);
      velvetShadow = const Color(0xFF6E1017);
      velvetHighlight = const Color(0xFFBD2833);
      shellColor = const Color(0xFF12141C);
      borderColor = const Color(0xFF4A1015);
    }

    // 1. HARD OUTER BACK SHELL (Protective molded rear casing)
    final sTopL = project(pos.x - hw, pos.y + cushionH + totalBackH, pos.z + 0.12);
    final sTopR = project(pos.x + hw, pos.y + cushionH + totalBackH, pos.z + 0.12);
    final sBotR = project(pos.x + hw, pos.y + cushionH, pos.z + 0.12);
    final sBotL = project(pos.x - hw, pos.y + cushionH, pos.z + 0.12);

    if (sTopL == null || sTopR == null || sBotR == null || sBotL == null) return;

    // Shell polygon
    final shellPath = Path()
      ..moveTo(sTopL.dx + 4, sTopL.dy)
      ..lineTo(sTopR.dx - 4, sTopR.dy)
      ..quadraticBezierTo(sTopR.dx, sTopR.dy, sTopR.dx, sTopR.dy + 4)
      ..lineTo(sBotR.dx, sBotR.dy)
      ..lineTo(sBotL.dx, sBotL.dy)
      ..lineTo(sTopL.dx, sTopL.dy + 4)
      ..quadraticBezierTo(sTopL.dx, sTopL.dy, sTopL.dx + 4, sTopL.dy)
      ..close();

    final shellPaint = Paint()..color = shellColor;
    canvas.drawPath(shellPath, shellPaint);

    final shellEdgePaint = Paint()
      ..color = isSelected ? borderColor : const Color(0xFF262A38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.0 : 1.0;
    canvas.drawPath(shellPath, shellEdgePaint);

    // 2. PLUSH VELVET LUMBAR BACKREST CUSHION
    final lumTopL = project(pos.x - hw * 0.92, pos.y + cushionH + lumbarH, pos.z + 0.10);
    final lumTopR = project(pos.x + hw * 0.92, pos.y + cushionH + lumbarH, pos.z + 0.10);
    final lumBotR = project(pos.x + hw * 0.88, pos.y + cushionH + 0.04, pos.z + 0.10);
    final lumBotL = project(pos.x - hw * 0.88, pos.y + cushionH + 0.04, pos.z + 0.10);

    if (lumTopL != null && lumTopR != null && lumBotR != null && lumBotL != null) {
      final lumPath = Path()
        ..moveTo(lumTopL.dx, lumTopL.dy)
        ..lineTo(lumTopR.dx, lumTopR.dy)
        ..lineTo(lumBotR.dx, lumBotR.dy)
        ..lineTo(lumBotL.dx, lumBotL.dy)
        ..close();

      final lumPaint = Paint()..color = velvetPrimary;
      canvas.drawPath(lumPath, lumPaint);

      // Vertical lumbar pleat stitching lines
      final lumCenterTop = project(pos.x, pos.y + cushionH + lumbarH, pos.z + 0.10);
      final lumCenterBot = project(pos.x, pos.y + cushionH + 0.04, pos.z + 0.10);
      if (lumCenterTop != null && lumCenterBot != null) {
        canvas.drawLine(lumCenterTop, lumCenterBot, Paint()..color = velvetShadow..strokeWidth = 1.2);
      }
    }

    // 3. CURVED CONVEX HEADREST CUSHION
    final hTopL = project(pos.x - hw * 0.85, pos.y + cushionH + totalBackH - 0.02, pos.z + 0.09);
    final hTopR = project(pos.x + hw * 0.85, pos.y + cushionH + totalBackH - 0.02, pos.z + 0.09);
    final hBotR = project(pos.x + hw * 0.88, pos.y + cushionH + lumbarH + 0.02, pos.z + 0.09);
    final hBotL = project(pos.x - hw * 0.88, pos.y + cushionH + lumbarH + 0.02, pos.z + 0.09);

    if (hTopL != null && hTopR != null && hBotR != null && hBotL != null) {
      final hPath = Path()
        ..moveTo(hTopL.dx, hTopL.dy)
        ..lineTo(hTopR.dx, hTopR.dy)
        ..lineTo(hBotR.dx, hBotR.dy)
        ..lineTo(hBotL.dx, hBotL.dy)
        ..close();

      // Headrest velvet gradient with subtle top highlight catching screen light
      final hBounds = hPath.getBounds();
      final hShader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [velvetHighlight, velvetPrimary, velvetShadow],
      ).createShader(hBounds);

      canvas.drawPath(hPath, Paint()..shader = hShader);

      // Screen light rim highlight on top curve of foreground seat headrests
      if (isForegroundAhead) {
        final rimPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawLine(hTopL, hTopR, rimPaint);
      }

      // Seat Number Plaque / Embroidery
      final hCenter = Offset((hTopL.dx + hBotR.dx) * 0.5, (hTopL.dy + hBotR.dy) * 0.5);
      final fontSize = isForegroundAhead ? 11.0 : (dz.abs() < 8.0 ? 8.0 : 6.0);
      if (fontSize >= 6.0) {
        final tp = TextPainter(
          text: TextSpan(
            text: seat.id,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: isSelected ? AppColors.textInverse : const Color(0xFFE2E8F0).withValues(alpha: 0.85),
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout();

        // Subtle brass plaque backing
        final plaqueRect = Rect.fromCenter(center: hCenter, width: tp.width + 8, height: tp.height + 4);
        canvas.drawRRect(
          RRect.fromRectAndRadius(plaqueRect, const Radius.circular(3)),
          Paint()..color = isSelected ? AppColors.primary : const Color(0xFF1E1418),
        );

        tp.paint(canvas, Offset(hCenter.dx - tp.width * 0.5, hCenter.dy - tp.height * 0.5));
      }
    }

    // 4. SEAT PAN / CUSHION (Front face visible when looking down or ahead)
    final cFrontL = project(pos.x - hw * 0.9, pos.y + cushionH, pos.z - 0.28);
    final cFrontR = project(pos.x + hw * 0.9, pos.y + cushionH, pos.z - 0.28);
    if (cFrontL != null && cFrontR != null) {
      final cPath = Path()
        ..moveTo(sBotL.dx, sBotL.dy)
        ..lineTo(sBotR.dx, sBotR.dy)
        ..lineTo(cFrontR.dx, cFrontR.dy)
        ..lineTo(cFrontL.dx, cFrontL.dy)
        ..close();
      canvas.drawPath(cPath, Paint()..color = velvetShadow);
    }

    // 5. PEDESTAL LEG TO FLOOR
    final legTop = project(pos.x, pos.y + cushionH, pos.z);
    final legBot = project(pos.x, pos.y, pos.z);
    if (legTop != null && legBot != null) {
      canvas.drawLine(legTop, legBot, Paint()..color = const Color(0xFF101218)..strokeWidth = 4.0);
    }
  }

  void _drawViewerForegroundArmrests(
    Canvas canvas,
    Size size,
    Position3D eye,
    Offset? Function(double, double, double) project,
  ) {
    // When the user is seated, their own armrests and cup holders flank the bottom left & right
    // Viewer armrest position: X = eye.x +/- 0.42m, Y = eye.y - 0.45m, Z = eye.z + 0.15m to eye.z - 0.35m
    final armrestPaint = Paint()..color = const Color(0xFF12141D);
    final armrestRimPaint = Paint()..color = const Color(0xFF262B3D);
    final cupHolderPaint = Paint()..color = const Color(0xFF090A0F);
    final cupHolderRimPaint = Paint()..color = const Color(0xFF3B435C);

    // Left Armrest
    final aL1 = project(eye.x - 0.44, eye.y - 0.48, eye.z + 0.10);
    final aL2 = project(eye.x - 0.34, eye.y - 0.48, eye.z + 0.10);
    final aL3 = project(eye.x - 0.34, eye.y - 0.48, eye.z - 0.38);
    final aL4 = project(eye.x - 0.44, eye.y - 0.48, eye.z - 0.38);

    if (aL1 != null && aL2 != null && aL3 != null && aL4 != null) {
      final pathL = Path()
        ..moveTo(aL1.dx, aL1.dy)
        ..lineTo(aL2.dx, aL2.dy)
        ..lineTo(aL3.dx, aL3.dy)
        ..lineTo(aL4.dx, aL4.dy)
        ..close();
      canvas.drawPath(pathL, armrestPaint);
      canvas.drawPath(pathL, armrestRimPaint..style = PaintingStyle.stroke..strokeWidth = 1.2);

      // Left Cup Holder at tip
      final cupCenterL = project(eye.x - 0.39, eye.y - 0.47, eye.z - 0.32);
      if (cupCenterL != null) {
        canvas.drawCircle(cupCenterL, 9.0, cupHolderPaint);
        canvas.drawCircle(cupCenterL, 9.0, cupHolderRimPaint..style = PaintingStyle.stroke..strokeWidth = 1.2);
      }
    }

    // Right Armrest
    final aR1 = project(eye.x + 0.34, eye.y - 0.48, eye.z + 0.10);
    final aR2 = project(eye.x + 0.44, eye.y - 0.48, eye.z + 0.10);
    final aR3 = project(eye.x + 0.44, eye.y - 0.48, eye.z - 0.38);
    final aR4 = project(eye.x + 0.34, eye.y - 0.48, eye.z - 0.38);

    if (aR1 != null && aR2 != null && aR3 != null && aR4 != null) {
      final pathR = Path()
        ..moveTo(aR1.dx, aR1.dy)
        ..lineTo(aR2.dx, aR2.dy)
        ..lineTo(aR3.dx, aR3.dy)
        ..lineTo(aR4.dx, aR4.dy)
        ..close();
      canvas.drawPath(pathR, armrestPaint);
      canvas.drawPath(pathR, armrestRimPaint..style = PaintingStyle.stroke..strokeWidth = 1.2);

      // Right Cup Holder at tip
      final cupCenterR = project(eye.x + 0.39, eye.y - 0.47, eye.z - 0.32);
      if (cupCenterR != null) {
        canvas.drawCircle(cupCenterR, 9.0, cupHolderPaint);
        canvas.drawCircle(cupCenterR, 9.0, cupHolderRimPaint..style = PaintingStyle.stroke..strokeWidth = 1.2);
      }
    }
  }

  void _drawLightingAndVignette(Canvas canvas, Size size) {
    // Subtle ambient cinema corner vignette
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.95,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.72),
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
        oldDelegate.movie != movie ||
        oldDelegate.screenImage != screenImage;
  }
}
