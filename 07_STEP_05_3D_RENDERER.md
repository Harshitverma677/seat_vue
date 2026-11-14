# Step 5: 3D Renderer Evaluation and Proof of Concept

## Objective

Choose one maintainable renderer for a genuine 3D auditorium on Android and iOS.

## Options to evaluate

1. Local Three.js scene inside `webview_flutter`.
2. A Flutter-compatible Three.js package such as `three_js`, if its current platform support and maintenance are suitable.
3. `flutter_gl` with a compatible rendering stack, if the additional integration complexity is justified.

These are alternatives, not a requirement to install all packages. Check current package versions, platform support, maintenance, licensing and examples before choosing.

## Proof of concept

Before replacing the existing viewport, create a separate minimal scene containing:
- One actual 3D cinema seat mesh with visible thickness and armrests.
- One screen plane or curved screen mesh.
- A simple auditorium floor.
- Basic lighting and shadows.
- A perspective camera that can be moved and aimed.
- A visible selected-seat material change.

Test the proof of concept on at least one Android and one iOS target. Record frame-rate/performance observations and lifecycle behavior.

## Decision report

Document:
- Chosen renderer and rationale.
- Rejected alternatives and reasons.
- Added dependencies.
- Asset format and loading strategy.
- Flutter-to-renderer bridge design, if applicable.
- Known platform limitations.

## Gate

Do not delete or replace the current viewport until the proof of concept builds and runs on both target platforms and demonstrates genuine 3D geometry.
