import 'package:flutter_test/flutter_test.dart';
import 'package:seat_vue/features/seat_preview/models/renderer_message.dart';
import 'package:seat_vue/models/seat.dart';

void main() {
  group('3D Renderer Message Contract Tests', () {
    test('SetCameraPoseCommand serializes correctly to JSON', () {
      const cmd = SetCameraPoseCommand(
        cameraPosition: Position3D(1.5, 2.2, 12.0),
        lookAtTarget: Position3D(0.0, 3.5, 0.0),
        fov: 62.0,
        durationMs: 450,
      );

      final json = cmd.toJson();
      expect(json['type'], equals('setCameraPose'));
      expect(json['cameraPosition']['x'], equals(1.5));
      expect(json['cameraPosition']['y'], equals(2.2));
      expect(json['cameraPosition']['z'], equals(12.0));
      expect(json['lookAtTarget']['y'], equals(3.5));
      expect(json['durationMs'], equals(450));

      final str = cmd.serialize();
      expect(str, contains('"type":"setCameraPose"'));
    });

    test('RecenterCameraCommand and SetLookInputCommand serialize correctly', () {
      const recenter = RecenterCameraCommand(durationMs: 280);
      expect(recenter.toJson()['type'], equals('recenterCamera'));
      expect(recenter.toJson()['durationMs'], equals(280));

      const look = SetLookInputCommand(deltaX: 12.5, deltaY: -4.2);
      expect(look.toJson()['type'], equals('setLookInput'));
      expect(look.toJson()['deltaX'], equals(12.5));
      expect(look.toJson()['deltaY'], equals(-4.2));
    });

    test('RendererEvent correctly parses incoming WebGL messages', () {
      const rawReady = '{"type":"sceneReady","renderer":"threejs","version":"r128"}';
      final readyEvent = RendererEvent.parse(rawReady);
      expect(readyEvent.isSceneReady, isTrue);
      expect(readyEvent.data['renderer'], equals('threejs'));

      const rawComplete = '{"type":"cameraTransitionCompleted","seatId":"D4"}';
      final completeEvent = RendererEvent.parse(rawComplete);
      expect(completeEvent.isTransitionCompleted, isTrue);

      const rawError = '{"type":"sceneError","message":"WebGL context lost"}';
      final errorEvent = RendererEvent.parse(rawError);
      expect(errorEvent.isError, isTrue);
    });
  });
}
