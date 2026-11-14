# Architecture and Implementation Rules

## 1. Inspect before changing

Inspect the actual repository, especially existing seat models, state controller, route/navigation flow, viewport, camera service and mock data. Known paths from earlier inspection include:

- `lib/features/seat_preview/widgets/cinema_3d_viewport.dart`
- `lib/features/seat_preview/services/auditorium_3d_service.dart`
- `lib/features/seat_preview/models/auditorium_camera_state.dart`
- `lib/features/seat_preview/screens/seat_preview_screen.dart`
- `lib/features/seat_selection/state/seat_selection_controller.dart`
- `lib/data/mock_auditoriums.dart`

These paths are starting points, not guaranteed current paths. Verify them.

## 2. Separation of responsibilities

- Flutter owns app navigation, seat-selection state, showtime state, booking mock state, HUD and draggable sheet.
- The 3D renderer owns scene objects, materials, lights, rendering and camera pose inside the scene.
- A typed adapter/bridge translates Flutter commands and renderer events.
- Mock data owns cinema, showtimes, seat availability, prices and auditorium dimensions.
- Geometry calculations belong in a pure Dart service where practical, with unit tests.

## 3. Preserve existing working behavior

Preserve and reuse where valid:
- Stable seat IDs and row/column mapping.
- Selection and availability rules.
- Existing navigation and app theme conventions.
- Camera coordinate calculations, eye-height settings and recenter behavior if correct.
- Existing animation/state logic where it can be adapted safely.

Do not delete the current `CustomPainter` viewport or related services until the replacement 3D implementation passes the proof-of-concept acceptance tests on Android and iOS. Keep a fallback during migration if practical.

## 4. State model

Use one source of truth for the selected seat. The selected seat must drive:
- Seat-map highlight.
- Checkout text and price.
- 3D selected mesh material.
- Camera position and look target.
- POV badge and sheet title.
- Mini-map highlight.
- Metrics and zone label.
- Mock booking confirmation.

Avoid separate duplicated selected-seat state in Flutter widgets and JavaScript.

## 5. Renderer communication

If using WebView + Three.js, define and document a versioned JSON message contract. Suggested Flutter-to-scene commands:
- `loadAuditorium`
- `selectSeat`
- `setCameraPose`
- `startCameraTransition`
- `recenterCamera`
- `setLookInput`
- `returnToOverview`

Suggested scene-to-Flutter events:
- `sceneReady`
- `cameraTransitionCompleted`
- `cameraTransitionReversed`
- `sceneError`

Validate message types and payloads. Do not pass arbitrary JavaScript strings assembled from user-controlled values. Handle WebView lifecycle, loading failures and disposal.

## 6. Dependencies

Do not add `three_js`, `flutter_gl`, and `webview_flutter` together by default. Evaluate viable approaches and choose one renderer. Keep dependency additions minimal and justify each package in the implementation report.

## 7. Code quality

- Use typed models and small focused widgets/services.
- Keep geometry math outside build methods.
- Avoid magic numbers; define named auditorium constants.
- Dispose controllers, subscriptions, WebViews and animation resources.
- Handle loading, failure and unsupported-platform states.
- Do not claim a feature works until it has been run and tested.
