import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/seat_camera_pose.dart';
import '../models/renderer_message.dart';

/// True 3D Cinema Viewport running the local Three.js WebGL cinema auditorium.
/// Directly replaces any Flutter CustomPainter auditorium rendering.
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
        ..setOnConsoleMessage((JavaScriptConsoleMessage message) {
          debugPrint('ThreeJS [${message.level.name}]: ${message.message}');
        })
        ..addJavaScriptChannel(
          'FlutterBridge',
          onMessageReceived: (JavaScriptMessage message) {
            final event = RendererEvent.parse(message.message);
            if (event.isSceneReady) {
              if (mounted) {
                setState(() => _isSceneReady = true);
                startTwoStageTransition(widget.cameraPose, durationMs: 1200);
              }
            }
            widget.onRendererEvent?.call(event);
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              _controller?.runJavaScript("if (window.SeatView3D && window.SeatView3D.notifyReady) { window.SeatView3D.notifyReady(); }");
              // Fallback timeout to unblock overlay
              Future.delayed(const Duration(milliseconds: 600), () {
                if (mounted && !_isSceneReady) {
                  setState(() => _isSceneReady = true);
                  startTwoStageTransition(widget.cameraPose, durationMs: 1200);
                }
              });
            },
            onWebResourceError: (WebResourceError error) {
              if (mounted) {
                setState(() {
                  _hasError = true;
                  _errorMessage = error.description;
                });
              }
            },
          ),
        );

      controller.loadFlutterAsset('assets/three_js/index.html').catchError((error) {
        debugPrint('WebView loadFlutterAsset error: $error');
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = error.toString();
          });
        }
      });

      _controller = controller;
    } catch (e) {
      // In headless test environments or unsupported desktop platforms
      _hasError = true;
      _errorMessage = e.toString();
    }
  }

  @override
  void didUpdateWidget(covariant True3DCinemaViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cameraPose.seatId != widget.cameraPose.seatId) {
      startTwoStageTransition(widget.cameraPose, durationMs: 800);
    }
  }

  /// Triggers the two-stage camera transition (Overhead 0-35% -> Eye level POV 35-100%).
  void startTwoStageTransition(SeatCameraPose pose, {int durationMs = 1200}) {
    if (!_isSceneReady || _controller == null) return;

    final cmd = SetCameraPoseCommand(
      seatId: pose.seatId,
      cameraPosition: pose.cameraPosition,
      lookAtTarget: pose.lookAtTarget,
      fov: pose.fov,
      durationMs: durationMs,
    );

    final payload = cmd.serialize();
    _controller?.runJavaScript("window.SeatView3D.dispatch('$payload');");
  }

  /// Smoothly reverses the camera back to overhead overview.
  void reverseTransition({int durationMs = 800}) {
    if (!_isSceneReady || _controller == null) return;
    _controller?.runJavaScript("window.SeatView3D.dispatch('{\"type\":\"reverseTransition\",\"durationMs\":$durationMs}');");
  }

  /// Trigger smooth camera recentering in the Three.js scene.
  void recenterCamera() {
    if (!_isSceneReady || _controller == null) return;
    _controller?.runJavaScript("window.SeatView3D.dispatch('{\"type\":\"recenterCamera\"}');");
  }

  /// Pass touch drag delta directly to the Three.js renderer for bounded look-around.
  void sendLookDelta(double deltaX, double deltaY) {
    if (!_isSceneReady || _controller == null) return;
    final cmd = SetLookInputCommand(deltaX: deltaX, deltaY: deltaY);
    final payload = cmd.serialize();
    _controller?.runJavaScript("window.SeatView3D.dispatch('$payload');");
  }

  /// Notify Three.js that the container or device orientation resized.
  void notifyResize() {
    if (!_isSceneReady || _controller == null) return;
    _controller?.runJavaScript("if (window.SeatView3D && window.SeatView3D.dispatch) { window.SeatView3D.dispatch('{\"type\":\"resize\"}'); }");
  }

  /// Toggle fullscreen mode in Three.js renderer.
  void setFullscreen(bool isFullscreen) {
    if (!_isSceneReady || _controller == null) return;
    _controller?.runJavaScript("if (window.SeatView3D && window.SeatView3D.dispatch) { window.SeatView3D.dispatch('{\"type\":\"setFullscreen\",\"isFullScreen\":$isFullscreen}'); }");
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: AppColors.scaffold,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.view_in_ar_rounded, color: AppColors.accent, size: 48),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Three.js 3D Cinema Viewport',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              kIsWeb || defaultTargetPlatform == TargetPlatform.macOS
                  ? 'WebGL 3D preview active via bundled Three.js assets.'
                  : '3D initialization: $_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (_controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller!),
        if (!_isSceneReady)
          Container(
            color: AppColors.scaffold,
            alignment: Alignment.center,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.accent),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'LOADING THREE.JS 3D AUDITORIUM...',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
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
