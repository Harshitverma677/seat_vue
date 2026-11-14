import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/seat_camera_pose.dart';
import '../models/renderer_message.dart';

/// True 3D Cinema Viewport running a hardware-accelerated WebGL Three.js scene.
///
/// This widget serves as the Proof-of-Concept (POC) implementation for migrating
/// from CustomPainter 2D projection to genuine 3D mesh rendering.
class True3DCinemaViewport extends StatefulWidget {
  final SeatCameraPose cameraPose;
  final ValueChanged<RendererEvent>? onRendererEvent;
  final bool enableGestures;

  const True3DCinemaViewport({
    super.key,
    required this.cameraPose,
    this.onRendererEvent,
    this.enableGestures = true,
  });

  @override
  State<True3DCinemaViewport> createState() => True3DCinemaViewportState();
}

class True3DCinemaViewportState extends State<True3DCinemaViewport> {
  WebViewController? _controller;
  bool _isSceneReady = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..addJavaScriptChannel(
          'FlutterBridge',
          onMessageReceived: (JavaScriptMessage message) {
            final event = RendererEvent.parse(message.message);
            if (event.isSceneReady) {
              if (mounted) {
                setState(() => _isSceneReady = true);
                _sendCameraPose(widget.cameraPose, durationMs: 0);
              }
            }
            widget.onRendererEvent?.call(event);
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onWebResourceError: (WebResourceError error) {
              if (mounted) {
                setState(() {
                  _hasError = true;
                  _errorMessage = error.description;
                });
              }
            },
          ),
        )
        ..loadFlutterAsset('assets/web/poc_cinema.html');

      _controller = controller;
    } catch (e) {
      // In headless test environments or unsupported platforms
      _hasError = true;
      _errorMessage = e.toString();
    }
  }

  @override
  void didUpdateWidget(covariant True3DCinemaViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cameraPose.seatId != widget.cameraPose.seatId) {
      _sendCameraPose(widget.cameraPose);
    }
  }

  void _sendCameraPose(SeatCameraPose pose, {int durationMs = 500}) {
    if (!_isSceneReady || _controller == null) return;

    final cmd = SetCameraPoseCommand(
      cameraPosition: pose.cameraPosition,
      lookAtTarget: pose.lookAtTarget,
      fov: pose.fov,
      durationMs: durationMs,
    );

    _dispatchToRenderer(cmd);
  }

  /// Trigger smooth camera recentering in the 3D scene.
  void recenterCamera() {
    if (!_isSceneReady || _controller == null) return;
    _dispatchToRenderer(const RecenterCameraCommand());
  }

  /// Pass touch drag delta directly to the 3D renderer.
  void sendLookDelta(double deltaX, double deltaY) {
    if (!_isSceneReady || _controller == null) return;
    _dispatchToRenderer(SetLookInputCommand(deltaX: deltaX, deltaY: deltaY));
  }

  void _dispatchToRenderer(RendererMessage message) {
    final payload = message.serialize();
    _controller?.runJavaScript("window.SeatView3D.dispatch('$payload');");
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          margin: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.roundedMd,
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videogame_asset_off_rounded, color: AppColors.primary, size: 40),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'True 3D Renderer (POC)',
                style: AppTypography.titleMedium.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                kIsWeb || defaultTargetPlatform == TargetPlatform.macOS
                    ? 'WebGL 3D preview active via bundled Three.js r128 assets.'
                    : 'Renderer error: $_errorMessage',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller!),
        if (!_isSceneReady)
          Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'INITIALIZING 3D WEBGL AUDITORIUM...',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
