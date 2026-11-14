# True 3D Renderer Migration

## Current implementation distinction

The existing Seat View viewport has used Flutter `CustomPainter` and mathematical perspective projection to draw seat backs, cushions, armrests, screen and auditorium details as 2D canvas paths/polygons. That can create a 3D-looking illustration, but it is not a true 3D scene.

A genuine 3D renderer must use scene objects/meshes with depth, camera projection, occlusion, materials and lighting.

## Migration principle

Replace the rendering layer only after a proof of concept works on Android and iOS. Preserve stable seat IDs, seat positions, selection state, navigation, reusable camera math and interaction rules.

## Required target

- Actual 3D seat meshes, including padded geometry, armrests and row-I recliners.
- 3D tiered auditorium, floor, aisles, steps, walls, ceiling and rails.
- Curved cinema screen with an authorized bundled landscape image.
- Crimson material for seats and mint material for the selected seat.
- Real perspective camera at selected seat's seated eye level.
- Depth, occlusion, lighting and shadows.
- Overhead camera view and animated first-person fly-in.
- Drag-to-look with constrained yaw/pitch.
- Reverse transition to the overhead view and 2D seat map.

## Migration sequence

1. Audit current viewport and camera services.
2. Evaluate renderer options and licenses.
3. Build one-seat/screen/floor proof of concept.
4. Verify on Android and iOS.
5. Define typed bridge and shared coordinate model.
6. Build full auditorium geometry and materials.
7. Connect seat IDs to meshes and camera poses.
8. Implement transitions and look-around.
9. Add HUD, mini-map and sheet.
10. Run performance and regression tests.
11. Remove old renderer only after acceptance; retain a fallback if practical.

## Renderer selection

Three.js inside `webview_flutter` is a viable candidate, not a mandatory conclusion. Also evaluate `three_js` or a `flutter_gl`-based route. Check current package maintenance, platform support, GPU behavior, licensing, asset pipeline and lifecycle constraints. Choose one approach and explain why.

## Bridge requirements for WebView approach

Use local bundled scene assets where possible. Define typed messages such as `loadAuditorium`, `selectSeat`, `startCameraTransition`, `setCameraPose`, `recenterCamera`, `setLookInput`, `returnToOverview`, `sceneReady`, `cameraTransitionCompleted` and `sceneError`.

Validate message payloads. Avoid arbitrary string-based script injection. Handle renderer startup, WebView disposal, app background/resume and platform-specific failures.

## Completion criteria

The implementation is not complete merely because the viewport looks more three-dimensional. Verify actual mesh depth, perspective movement, occlusion, lighting, selected-seat mapping and camera changes for different seat positions.
