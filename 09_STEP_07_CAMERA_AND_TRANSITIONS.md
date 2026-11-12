# Step 7 — Seat-to-Camera Mapping and 3D Transitions

## Objective

Connect the selected 2D seat to its real 3D location and animate the camera into that seat's viewing position.

## Read first

- `README.md`
- `01_PRODUCT_SPEC.md`
- `02_ARCHITECTURE_AND_RULES.md`
- `07_STEP_05_SEAT_MAP.md`
- `08_STEP_06_3D_AUDITORIUM.md`

## Functions performed in this step

1. Define a `SeatCameraPose` model.
2. Map every seat ID to a world-space seat position.
3. Calculate camera eye position using seat position plus eye-height offset.
4. Calculate a look-at target aimed toward the screen.
5. Pass the selected seat ID from the seat map into the preview.
6. Animate camera position and orientation from the current pose to the target pose.
7. Add a smooth return transition to the seat map.
8. Support changing the preview seat without rebuilding the whole scene.
9. Prevent conflicting animations from rapid repeated taps.

## Camera mapping concept

For a seat:
- `cameraPosition` is the modeled eye point at that seat.
- `lookAtTarget` is the screen center or a carefully chosen point on the screen.
- Camera orientation is derived from `cameraPosition` and `lookAtTarget`.
- Use a small eye-height offset above the seat's base position.

Do not use one hard-coded camera pose for all seats. Center seats, side seats, front rows, and back rows should produce visibly different perspectives.

## Transition behavior

- Seat map → preview: animate from the overview/entry camera to the selected seat camera.
- Seat A → Seat B: animate from A's pose to B's pose.
- Preview → seat map: animate back to the overview pose, then return to the map.
- Keep the selected seat highlighted after returning.

Use an eased interpolation for position and a safe orientation interpolation supported by the renderer. Avoid abrupt camera snaps.

## Deliverables

- Seat-to-camera pose mapping.
- Camera transition controller/service.
- Preview seat switching.
- Return transition.
- A documented animation duration and curve.

## Completion checklist

- [ ] Each seat ID resolves to a camera pose.
- [ ] Different seats show different viewing angles.
- [ ] Camera moves smoothly to the selected seat.
- [ ] Switching seats animates rather than snapping.
- [ ] Back navigation returns smoothly.
- [ ] Rapid taps do not corrupt camera state.
- [ ] The selected seat remains selected on return.
