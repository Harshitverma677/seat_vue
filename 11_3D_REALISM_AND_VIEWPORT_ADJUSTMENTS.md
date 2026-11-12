# 3D Realism and Seat-View UI Adjustment

## Purpose

This document updates the 3D preview requirements using the two user-provided screenshots. The desired result is a convincing first-person cinema experience: the viewer should feel physically seated in the selected seat, looking toward the movie screen.

This addendum takes priority over earlier generic 3D-preview wording wherever the requirements conflict. Read it with `01_PRODUCT_SPEC.md`, `02_ARCHITECTURE_AND_RULES.md`, `08_STEP_06_3D_AUDITORIUM.md`, and `09_STEP_07_CAMERA_AND_TRANSITIONS.md`.

## Visual references

### Reference A: Preview interface

Use the first screenshot for the surrounding UI:
- Dark, immersive background.
- Top bar with back navigation, 3D preview label, movie/show information, and Recenter control.
- Short gesture hint.
- Large 3D viewport.
- Bottom information sheet with selected row/seat, category, mock price, optional viewing metrics, seat switching, row switching, and a button to return to the 2D seat map.
- Clearly identify the currently previewed seat.

Do not reproduce the accidental right-edge overflow visible in the reference. Respect safe areas and fit supported device widths.

### Reference B: Realistic first-person cinema view

Use the second screenshot as the primary 3D realism reference:
- Camera at seated human eye height, not floating above the auditorium.
- A large, realistic padded seat back directly in front of the viewer.
- Neighboring red upholstered seats visible to the left and right.
- Additional rows visible beyond the foreground seats.
- Cinema screen ahead at a believable distance and height.
- A default static image or designed placeholder on the screen.
- Dark auditorium with subtle ambient light and screen light spill.
- Believable scale, depth, perspective, and materials.

The result must look like a real first-person viewpoint, not a miniature theatre diorama, top-down map, flat background image, or simplified collection of boxes.

## Critical camera placement

The selected seat represents the viewer's physical location. Place the camera at that seat's seated eye point.

Important:
- The selected seat's own seat back should normally be behind the camera, not blocking the view.
- The seat directly ahead in the viewer's line of sight, plus neighboring seat backs, should naturally appear in the foreground.
- If no seat is directly ahead, show neighboring seats and rows ahead.
- Never place the camera inside a seat mesh or floor.
- Do not represent the selected seat as a tiny highlighted object far below the camera.

Calculate camera position from the selected seat's world position, orientation, and seated eye-height offset. Keep all coordinates in one documented auditorium coordinate system.

## Scene requirements

### Cinema screen
- Large widescreen projection surface at the front.
- Correct perspective and aspect ratio.
- Bundled static placeholder image visible by default.
- Screen brighter than the auditorium, with subtle light spill.
- No implication that movie streaming/playback is implemented.
- Use a locally bundled, licensed image or a designed placeholder. Do not fetch random images at runtime.

### Realistic cinema seats
- Padded backrest, cushion, headrest, armrests, and visible supports/base where appropriate.
- Red fabric or velvet upholstery for the initial design.
- Rounded, padded forms rather than flat rectangles or boxes.
- Visible seat-back thickness and curved edges.
- Consistent real-world scale and spacing.
- Optimize repeated geometry and materials for mobile performance.

### Auditorium
- Dark walls and ceiling.
- Floor, steps, and aisles with believable geometry.
- Subtle architectural details where they add depth.
- Restrained aisle lighting and screen illumination.
- Avoid neon outlines, excessive glow, and game-like colors.

### Camera optics and interaction
- Seated eye-level perspective.
- Natural field of view; avoid exaggerated fisheye distortion.
- Correct clipping planes so nearby seat backs remain visible.
- Default camera faces the screen.
- Drag gestures allow limited, smooth look-around within sensible bounds.
- Recenter animates to the selected seat's default forward-facing direction without changing the selected seat.

## Seat-to-view behavior

Every seat must produce its own believable perspective:
1. Resolve stable seat ID.
2. Read its world position and orientation.
3. Calculate seated eye position.
4. Calculate a look target on or near the screen.
5. Animate the camera to that pose.
6. Keep the camera constrained to the auditorium experience.

Front/back rows, center/side seats, aisle seats, and different row elevations must look meaningfully different. Do not merely change a label or swap a static screenshot. The 3D camera must actually move.

## Preview UI layout

### Top controls
- Back button.
- Compact 3D preview heading.
- Movie title and format/show label, safely truncated.
- Recenter button.
- Gesture hint such as "Drag to look around · Tap a seat below to switch".

### 3D viewport
- Occupy the largest practical screen area.
- Sit behind/above the bottom information sheet.
- Keep the screen and important seat geometry visible.
- Never overflow horizontally.

### Bottom information sheet
- Selected seat badge, e.g. `F8`.
- Row and seat label.
- Mock category, e.g. Standard or Premium.
- Mock price.
- Optional distance-to-screen and viewing-angle values only if calculated from scene geometry.
- Compact seat-number selector.
- Row selector.
- Button to return to the 2D seat map.
- Clear selected/current preview state.

All values are mock UI data. Do not claim a seat is reserved or booked.

## Transitions

### Open preview
Animate from the seat-map context/overview camera into the selected seat's eye pose. Do not abruptly replace the screen or teleport the camera.

### Switch seats
Keep the scene loaded. Animate position and orientation from the current seat pose to the new seat pose. Update the bottom sheet and selected-seat indicator in sync.

### Recenter
Animate to the selected seat's default forward-facing view. Keep the same seat selected.

### Return to map
Animate back to an overview/exit pose where supported. Return to the 2D map with selection preserved.

Use eased interpolation for position and a safe orientation interpolation supported by the renderer. Handle rapid repeated taps without corrupting camera state.

## Technical asset requirements

- Prefer a detailed, optimized auditorium model or modular seat assets.
- Use GLB/GLTF if supported by the selected renderer.
- Use physically based materials where available.
- Use base-color, roughness, and normal maps where they improve realism.
- Use instancing/shared geometry for repeated seats if supported.
- Keep polygon counts and texture sizes appropriate for mobile.
- Bundle required assets locally.
- Document each asset's source and license in an asset README.

Verify the renderer's model loading, materials, camera control, animation, and Android/iOS compatibility with a small proof of concept before building the full scene.

## Implementation milestones

### A. Camera proof of concept
Render a screen and a few seat models. Place the camera at a seated eye point and verify that the foreground seat composition feels natural.

### B. Realistic auditorium
Replace primitive boxes with padded seat models. Add rows, aisles, walls, floor, ceiling, materials, and restrained lighting.

### C. Seat mapping
Map mock seat IDs to world positions and camera poses. Verify front, back, center, and side views.

### D. UI and transitions
Add top controls and bottom sheet. Implement transition into the selected seat view, seat switching, Recenter, and return-to-map.

### E. Mobile optimization
Test on physical Android and iOS devices. Tune model complexity, lighting, textures, frame rate, and safe-area layout.

## Acceptance checklist

- [ ] Preview feels like a person sitting in a cinema, not an overhead or distant view.
- [ ] Realistic padded seat backs appear in the foreground.
- [ ] Neighboring red seats have believable depth and scale.
- [ ] Large cinema screen is visible ahead.
- [ ] Screen shows a bundled static placeholder image.
- [ ] Selected seat controls the actual 3D camera position.
- [ ] Side and center seats produce different perspectives.
- [ ] Drag-to-look and Recenter work without changing the selected seat.
- [ ] Seat switching animates smoothly.
- [ ] Top controls and bottom sheet fit without overflow.
- [ ] Scene performs well on target phones.
- [ ] No authentication, backend, payment, streaming, or real booking is added.
