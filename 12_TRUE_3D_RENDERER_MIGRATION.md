# Seat View: Upgrade from CustomPainter to a True 3D Cinema Environment

## 1. Purpose

The project name is **Seat View**.

This document defines the next major rendering upgrade: replace the current 2D-canvas-based 3D illusion with a genuine real-time 3D cinema environment.

The existing repository already has useful work in Flutter, including seat selection, auditorium coordinates, camera-pose calculations, camera interaction, and animated transitions. Preserve and reuse that work wherever practical. The goal is to upgrade the rendering layer, not rewrite the entire application.

Read this document together with:
- `README.md`
- `01_PRODUCT_SPEC.md`
- `02_ARCHITECTURE_AND_RULES.md`
- `08_STEP_06_3D_AUDITORIUM.md`
- `09_STEP_07_CAMERA_AND_TRANSITIONS.md`
- `11_3D_REALISM_AND_VIEWPORT_ADJUSTMENTS.md`

This document takes priority whenever earlier documents describe the current CustomPainter scene as the final 3D solution.

## 2. Current implementation and its limitation

The existing repository renders its auditorium using Flutter `CustomPainter` and mathematical perspective projection.

The current approach draws visual representations of seats and auditorium elements onto a 2D canvas. Seat backs, cushions, armrests, screen surfaces, and lighting effects are represented by 2D paths, polygons, gradients, and other canvas drawing operations.

This can create a convincing 3D-like appearance, but it is not a fully modeled 3D environment.

### What the current approach cannot provide naturally

- Actual 3D seat meshes with front, back, side, and curved surfaces.
- True geometric depth and physically correct object occlusion.
- Real-time shadows cast by seat geometry and auditorium structures.
- Physically based material response to lights.
- Natural reflections and screen-light interaction.
- Reliable viewing around objects as the camera moves.
- Detailed seat geometry that remains correct from different camera angles.
- A complete 3D environment that can be explored from different positions.

Do not describe the current CustomPainter output as true 3D geometry. It is a 2D rendering with perspective calculations.

## 3. Target experience

The user must feel as if they are physically sitting in a cinema hall.

The selected seat determines the viewer's camera position. The camera is placed at a realistic seated eye height and faces the cinema screen.

The view should include:
- A realistic padded seat back in the foreground where the auditorium layout places a seat ahead of the viewer.
- Neighboring seats to the left and right.
- Multiple rows of seats extending toward the screen.
- A large cinema screen showing a bundled default static image.
- Dark auditorium walls, ceiling, floor, steps, and aisles.
- Realistic material depth, lighting, and shadows.
- Natural perspective and believable scale.

The view must not look like a top-down map, a miniature theatre, a flat illustration, or a collection of floating 2D polygons.

## 4. Target rendering capabilities

The new renderer must support actual 3D scene geometry and a perspective camera.

### 4.1 Real 3D meshes

Use modeled geometry for:
- Seat backrests.
- Seat cushions.
- Headrests.
- Armrests.
- Cup holders.
- Seat supports and bases.
- Cinema screen frame and projection surface.
- Auditorium floor, steps, walls, ceiling, and aisle structures.

Seats should have rounded, padded forms and visible thickness. The first visual direction is realistic red fabric or velvet upholstery.

Do not approximate the final seat models using flat polygons or layered 2D canvas paths.

### 4.2 Depth, occlusion, and clipping

The renderer must use a depth buffer or equivalent 3D visibility system so that:
- Nearby seats correctly obscure objects behind them.
- Seat backs and armrests overlap naturally.
- Camera movement reveals correct surfaces.
- Objects behind the camera are not rendered in front.
- Near and far clipping behave predictably.

### 4.3 Materials and textures

Use physically based rendering (PBR) materials if supported by the selected renderer.

Where appropriate, use:
- Base-color textures for upholstery and surfaces.
- Roughness maps to distinguish fabric, plastic, painted walls, and flooring.
- Normal maps for subtle fabric and surface detail.
- Metalness values only for genuinely metallic components.

Avoid glossy plastic-looking seats. Upholstery should read as fabric, with restrained highlights and realistic roughness.

### 4.4 Lighting and shadows

The auditorium should be dark but readable.

Include:
- Low-level ambient illumination.
- A brighter cinema screen.
- Soft screen-light contribution on nearby surfaces where supported.
- Subtle aisle or step lights.
- Directional or area lighting as supported by the renderer.
- Real shadows from seats and architectural geometry where performance allows.

Lighting must improve depth and realism without excessive bloom, neon effects, or game-like colors.

### 4.5 Cinema screen

Create a real screen mesh or projection surface at the front of the auditorium.

Requirements:
- Believable widescreen aspect ratio.
- Correct position, height, and orientation.
- A locally bundled default still image or designed placeholder.
- Screen content remains static in this UI-only phase.
- No movie streaming or playback feature is implied.

## 5. Rendering technology decision

The renderer must be selected based on the needs of a complete 3D scene, not merely the ability to display a single 3D model.

The implementation must support:
- Loading a full auditorium scene.
- Multiple meshes and materials.
- Perspective camera control.
- Depth testing and occlusion.
- Lighting and shadows.
- Animated camera movement.
- Touch/drag interaction.
- Android and iOS deployment.
- Acceptable performance on mid-range mobile devices.

A WebView-hosted Three.js scene is one possible approach. A native Flutter-compatible 3D renderer is another. Do not assume a package is suitable based only on its name or a model-viewer demo.

Before committing:
1. Review the existing Flutter version and project constraints.
2. Verify renderer maintenance, platform support, and licensing.
3. Build a proof of concept on both Android and iOS.
4. Load a GLB/GLTF seat model.
5. Add a screen mesh and a perspective camera.
6. Move the camera between two positions.
7. Test touch input and frame rate.
8. Record the chosen renderer and reason in `02_ARCHITECTURE_AND_RULES.md`.

If using Three.js through WebView, keep the Three.js scene and its assets separate from Flutter UI code. Define a small, typed message contract for communication between Flutter and JavaScript. Do not put business logic or the only copy of seat-selection state inside the WebView.

## 6. Reuse existing repository logic

Inspect the existing implementation before changing it. Preserve useful domain logic and UI behavior.

Evaluate these existing concepts for reuse:
- Stable seat IDs, row and seat number.
- Seat category and mock availability state.
- Auditorium row/column layout.
- Seat world coordinates and orientation.
- Selected-seat state.
- Camera eye-height offset.
- Camera forward direction and look target.
- Camera pose calculation.
- Recenter behavior and drag-to-look limits.
- Seat-switching transitions.
- Navigation back to the 2D seat map.

Existing files identified in the repository include:
- `lib/features/seat_preview/widgets/cinema_3d_viewport.dart`
- `lib/features/seat_preview/services/auditorium_3d_service.dart`
- `lib/features/seat_preview/models/auditorium_camera_state.dart`
- `lib/features/seat_preview/screens/seat_preview_screen.dart`
- `lib/features/seat_selection/state/seat_selection_controller.dart`
- `lib/data/mock_auditoriums.dart`

Verify the current paths and contents before editing because the repository may change.

The CustomPainter renderer can remain temporarily as a fallback or comparison implementation, but the new true 3D renderer should become the active preview only after the proof of concept passes.

## 7. Coordinate system and seat-to-camera mapping

Define and document one auditorium world coordinate system.

Each seat should have a stable seat ID, row and seat number, world position, forward orientation, optional row elevation, category, and mock availability state.

For the selected seat:
1. Read its world position and orientation.
2. Calculate the seated eye position using a configurable eye-height offset.
3. Calculate a look target toward the cinema screen.
4. Create a camera pose from the eye position and look target.
5. Animate the camera to the pose.
6. Keep the camera within safe auditorium bounds.

The selected seat is the viewer's seat. Its own backrest should generally be behind the camera. The seat in front of the viewer and neighboring seat backs should appear naturally in the foreground when the layout places them there.

Different seats must produce genuinely different camera views:
- Front rows should be closer to the screen.
- Back rows should show a more distant screen.
- Side seats should show an angled screen perspective.
- Center seats should face the screen more directly.
- Aisle seats should reveal the aisle from the correct side.

Do not fake different seat views by changing only labels or static images.

## 8. Camera interaction and transitions

Support:
- Animated transition from the seat-map context into the selected seat's first-person view.
- Smooth transition from one selected seat to another.
- Drag-to-look with bounded horizontal and vertical rotation.
- Recenter to the selected seat's default screen-facing direction.
- Return to the 2D seat map while preserving selection.

Use smooth interpolation for position and a suitable orientation interpolation method supported by the renderer. Handle rapid repeated input safely. Keep the scene loaded during seat changes instead of rebuilding the complete auditorium.

Camera movement must not pass through seat meshes or auditorium walls, drop below the floor, move to an unrelated seat, or change the selected seat when Recenter is pressed.

## 9. Flutter and 3D renderer communication

Keep Flutter responsible for movie and showtime UI, seat map UI, selected seat and mock availability state, bottom information panel, and navigation.

Keep the 3D renderer responsible for scene loading and lifecycle, meshes and materials, rendering and depth, camera movement and look controls, lighting and shadows, and mapping a requested seat pose to the camera.

Define explicit messages such as:
- `loadAuditorium`
- `selectSeat`
- `setCameraPose`
- `recenterCamera`
- `setLookInput`
- `returnToOverview`
- `sceneReady`
- `cameraTransitionCompleted`
- `sceneError`

Document the exact message format and type it on the Flutter side. Validate incoming data. Do not allow arbitrary JavaScript execution from ordinary UI values.

## 10. Asset pipeline

Use Blender or another suitable 3D modeling tool to create or prepare cinema seats, auditorium shell, screen and frame, floor, steps, aisle, and optional wall and ceiling details.

Prefer GLB/GLTF when supported by the chosen renderer.

Asset requirements:
- Correct real-world scale.
- Applied transforms and sensible origins.
- Clean normals.
- Optimized topology.
- Efficient texture sizes.
- Reusable seat geometry and materials.
- Consistent naming.
- Mobile-friendly polygon counts.

Bundle required assets locally. Record asset source, creator, license, and modifications in `assets/3d/ASSET_LICENSES.md`. Do not use copyrighted cinema branding or movie artwork without permission.

## 11. Performance and mobile optimization

A complete auditorium may contain many repeated seats. Avoid unnecessary unique geometry and materials.

Use where supported:
- Instancing or shared mesh geometry for repeated seats.
- Shared materials and texture atlases.
- Level of detail for distant seats.
- Frustum culling.
- Compressed textures and optimized GLB assets.
- Bounded shadow quality.
- Lazy loading for optional assets.
- A controlled render loop that pauses when the preview is not visible.

Test on physical Android and iOS devices. Track frame rate, memory usage, scene load time, and device heat during a sustained preview.

Do not sacrifice the first-person composition, but reduce invisible or distant detail before reducing foreground seat quality.

## 12. Migration plan

### Phase A: Audit and preserve
- Inspect current camera, seat, and state models.
- Identify which CustomPainter functions are rendering-only.
- Identify reusable seat coordinates and camera-pose calculations.
- Record current behavior with screenshots or a short screen recording.
- Keep the existing app runnable.

### Phase B: Renderer proof of concept
- Select and integrate a candidate 3D renderer.
- Load one realistic seat mesh.
- Add a screen mesh and a simple floor.
- Place a perspective camera at seated eye height.
- Verify depth, occlusion, materials, and basic lighting.
- Test Android and iOS.

### Phase C: Realistic auditorium scene
- Add multiple rows of real seat meshes.
- Add walls, ceiling, floor, steps, and aisles.
- Add the default screen image.
- Tune materials, lighting, and shadows.
- Verify the view from center and side seats.

### Phase D: Connect existing seat logic
- Connect stable Flutter seat IDs to 3D world positions.
- Reuse or adapt the existing camera-pose service.
- Send selected-seat changes to the renderer.
- Keep the Flutter bottom panel synchronized with the camera.
- Preserve seat-map selection when navigating back.

### Phase E: Camera interaction and polish
- Implement seat-to-seat camera transitions.
- Implement drag-to-look and Recenter.
- Add safe camera bounds and interruption handling.
- Verify all controls on different screen sizes.

### Phase F: Performance and cleanup
- Optimize geometry, textures, materials, and shadows.
- Remove or retain CustomPainter only as an intentional fallback.
- Add tests for seat-to-camera mapping and message handling.
- Document renderer setup and asset licenses.

## 13. Testing requirements

Add or update tests for:
- Stable seat ID to world-position mapping.
- Camera pose calculation for center and side seats.
- Eye-height offset.
- Recenter preserving selected seat.
- Seat switching updating camera target.
- Invalid or missing seat IDs.
- Flutter-to-renderer message serialization.
- Renderer-ready and renderer-error states.
- Returning to the seat map with selection preserved.

Perform manual visual checks for foreground seat geometry, natural occlusion, side-seat perspective, screen visibility, shadow and lighting quality, camera clipping, UI overflow, and smooth transitions on physical devices.

## 14. Acceptance criteria

- [ ] The active preview uses actual 3D meshes, not only CustomPainter polygons.
- [ ] Cinema seats have real modeled thickness and curved padded geometry.
- [ ] The scene has a perspective camera and correct depth/occlusion.
- [ ] The camera is positioned at the selected seat's seated eye point.
- [ ] The seat ahead and neighboring seats appear naturally in the foreground.
- [ ] The cinema screen is visible and displays a bundled default still.
- [ ] The auditorium includes believable floor, walls, ceiling, steps, and aisles.
- [ ] Materials look like fabric, flooring, and architectural surfaces rather than flat colored shapes.
- [ ] Lighting and shadows add depth without overwhelming the scene.
- [ ] Different seat selections produce genuinely different camera perspectives.
- [ ] Seat switching, drag-to-look, and Recenter work smoothly.
- [ ] Existing seat-selection and navigation behavior is preserved.
- [ ] The renderer works on target Android and iOS devices.
- [ ] Performance is measured and acceptable on physical devices.
- [ ] Asset sources and licenses are documented.
- [ ] Authentication, backend, payment, streaming, and real booking remain out of scope.

## 15. Scope restrictions

This is a rendering and visual-experience upgrade only.

Do not add authentication, backend services, live cinema or showtime APIs, real seat inventory or reservation locking, payment gateway, ticket issuance, or movie streaming.

Continue using mock movie, cinema, showtime, and seat data until a separate integration task is approved.
