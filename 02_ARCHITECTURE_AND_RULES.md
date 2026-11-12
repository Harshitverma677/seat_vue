# Architecture and Implementation Rules

## Suggested folder structure

```text
lib/
  main.dart
  app/
    app.dart
    routes.dart
  core/
    theme/
      app_colors.dart
      app_theme.dart
    constants/
      app_spacing.dart
      app_durations.dart
  data/
    mock_movies.dart
    mock_auditoriums.dart
  models/
    movie.dart
    showtime.dart
    seat.dart
    seat_camera_pose.dart
  features/
    home/
      screens/
      widgets/
    movie_details/
      screens/
      widgets/
    seat_selection/
      screens/
      widgets/
      state/
    seat_preview/
      screens/
      widgets/
      services/
      state/
  shared/
    widgets/
```

Adapt the structure if the project starts small, but keep responsibilities separate.

## Responsibility boundaries

- **Screens:** compose page-level UI and coordinate navigation.
- **Widgets:** reusable visual elements such as movie cards, seat cells, and legends.
- **Models:** typed data structures.
- **Mock data:** sample movies, showtimes, auditorium layout, and seat availability.
- **Seat-selection state:** selected seat IDs and selection rules.
- **3D service:** load/dispose the scene, map seat IDs to camera poses, and animate the camera.
- **3D preview screen:** display the renderer and controls; it should not contain all scene math.

## State ownership

Keep one source of truth for selected seat IDs. The seat map and preview screen must read the same selection state. Returning from preview must not reset the selection.

For the first version, a simple state solution is acceptable. Choose `setState` for very local state or a lightweight state-management package if shared state becomes awkward. Do not add complexity without a need.

## Seat and camera data contract

A seat should have:
- `id` — stable unique identifier, e.g. `C7`.
- `rowLabel` — e.g. `C`.
- `seatNumber` — e.g. `7`.
- `status` — available, selected (derived locally), or unavailable.
- `worldPosition` — position in the 3D auditorium coordinate system.

A camera pose should have:
- `seatId`
- `cameraPosition`
- `lookAtTarget`
- Optional field of view.

Keep all positions in the same coordinate system and units.

## 3D rendering engine decision

Before building the complete auditorium, create a small technical spike to verify the selected Flutter-compatible renderer on the project's Flutter version and target devices.

Evaluate:
- Model loading (GLB/GLTF or supported alternative).
- Camera positioning and smooth animation.
- Materials and lighting.
- Touch interaction and camera controls.
- Android and iOS compatibility.
- Performance and package maintenance.

A Flutter-embedded Three.js scene via WebView is one viable approach. A Flutter-native 3D package may also be evaluated. Do not assume a package is production-ready without testing. Record the final choice and limitations in the project README.

## Performance rules

- Load the 3D model once and reuse the scene.
- Do not recreate the renderer on every Flutter rebuild.
- Dispose renderer resources/controllers when the screen is permanently removed.
- Avoid excessive real-time shadows and high-polygon seat models on mobile.
- Use instancing or shared geometry/materials if the chosen engine supports it.
- Keep camera animation frame work inside the 3D renderer where possible.

## Coding rules

- Use null safety and typed models.
- Avoid hard-coded seat positions inside UI widgets.
- Avoid magic numbers; use named constants.
- Keep navigation and animation durations consistent.
- Add comments for coordinate transforms and non-obvious camera calculations.
- Do not introduce networking, authentication, payments, or backend dependencies in this phase.
