# Instructions for AI Coding Agents

You are working on Seat View, a Flutter UI-only movie-booking prototype. Read `00_DOCS_INDEX.md` first, then read the documents listed for the current step before editing code. For all 3D preview work, also read `11_3D_REALISM_AND_VIEWPORT_ADJUSTMENTS.md`. When upgrading the current CustomPainter renderer to actual 3D meshes, read `12_TRUE_3D_RENDERER_MIGRATION.md` before editing.

## Product goal

Build a Flutter app whose defining feature is a smooth transition from a 2D cinema seat map to a 3D auditorium camera view from the selected seat.

## Scope guardrails

Do implement:
- Flutter screens and widgets.
- Local mock movie, cinema, showtime, and seat data.
- Interactive 2D seat selection.
- A true 3D first-person auditorium renderer using actual meshes, perspective camera, depth/occlusion, realistic materials, lighting and shadows. The target view has padded foreground seat backs, neighboring seats, and a screen showing a bundled static placeholder image.
- Seat-to-camera mapping.
- Smooth camera transitions and preview navigation.

Do not implement in this phase:
- Authentication or user accounts.
- Firebase or another backend.
- Real-time APIs or live seat availability.
- Payment gateway.
- Real ticket booking, reservation, or QR ticket issuance.

## Working method

1. Identify the current step from the user's instruction.
2. Read the corresponding step document and its dependencies in `00_DOCS_INDEX.md`.
3. Inspect the existing code before changing it.
4. Make the smallest coherent implementation for that step.
5. Keep the app runnable after each step.
6. Do not replace working code unnecessarily.
7. Explain files changed, behavior implemented, and commands to verify.
8. Update the relevant documentation if architecture or decisions change.

## Technical constraints

- Use typed Dart models.
- Keep mock data separate from UI widgets.
- Keep seat IDs stable.
- Keep seat selection state in one source of truth.
- Keep 3D scene lifecycle and camera control outside ordinary UI widgets.
- Do not recreate the 3D renderer on every Flutter rebuild.
- Verify the chosen true 3D renderer on the project's Flutter version and target Android/iOS devices before building the full scene. Do not treat CustomPainter polygons as actual 3D meshes.
- Document model asset sources and licenses.
- Avoid magic numbers and duplicated styles.

## Acceptance criteria

The core prototype is complete when a user can browse a sample movie, open its details, choose a sample showtime, select a seat, see a smooth transition into the 3D auditorium from that seat's viewing position, switch to another seat, and return to the seat map with the selection preserved.
