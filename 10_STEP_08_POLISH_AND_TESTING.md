# Step 8: Polish, Testing and Acceptance

## Automated checks

Run:
- `flutter pub get`
- `flutter analyze`
- `flutter test`

Add unit tests for seat layout, aisle coordinates, pricing, availability, selection, zone classification and metrics.

Add widget tests for:
- Default showtime.
- Seat map row/seat count.
- Selected/unselected/taken seat behavior.
- Continue disabled/enabled.
- Checkout label and price.
- POV badge, sheet labels and actions.
- Change-seat state preservation.
- Mock booking confirmation.

## Platform checks

Build and manually verify Android and iOS:
- App launches and 2D screen lays out correctly.
- 3D scene loads and reports errors cleanly.
- Camera transition runs without a blank/frozen viewport.
- Back/Change seat returns to map.
- Drag-to-look works without fighting the bottom-sheet drag.
- App background/resume and navigation do not leak renderer resources.

## Visual acceptance checklist

### Seat selection
- [ ] Dark palette matches spec.
- [ ] Meridian header and hall/date subtitle.
- [ ] Three showtime pills; `16:45 IMAX` selected initially.
- [ ] Curved screen arc and glow.
- [ ] 9 rows × 14 seats.
- [ ] Aisles after seat 3 and seat 11.
- [ ] Rows A–H standard; row I recliner.
- [ ] Seat selection/deselection and taken-seat behavior.
- [ ] Legend and sticky checkout bar.

### 3D experience
- [ ] Actual 3D meshes, not 2D polygon approximations.
- [ ] Tiered auditorium, aisle rails, floor, walls and ceiling.
- [ ] Curved screen with authorized desert image.
- [ ] Crimson seats; only selected seat mint.
- [ ] Row-I recliner/footrest geometry.
- [ ] Overhead-to-POV transition around 1200 ms.
- [ ] Seat-specific camera poses.
- [ ] Reverse transition and constrained look-around.

### POV interface
- [ ] Back button and dynamic `View from ...` badge.
- [ ] Draggable sheet and handle.
- [ ] Correct zone tag, seat title and type/price.
- [ ] Mini-map with 9 × 14 dots and active highlight.
- [ ] Three live metric cards.
- [ ] Change seat and mock Book action.

### Quality
- [ ] No overflow on target phone sizes.
- [ ] No new analyzer warnings.
- [ ] Tests pass or pre-existing failures are documented.
- [ ] Renderer performance checked on real devices.
- [ ] No payment/backend/live booking behavior added.

## Final report

List changed files, architecture choices, packages, tests run and results, supported platforms, known limitations and any acceptance items not completed. Never report unrun tests as passing.
