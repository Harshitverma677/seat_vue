# Instructions for the Seat View Coding Agent

You are working in the existing Flutter repository `seat_vue`. The product name shown in the app and documentation is **Seat View**.

## Mandatory first actions

1. Read `README.md`, `00_DOCS_INDEX.md`, `01_PRODUCT_SPEC.md`, `02_ARCHITECTURE_AND_RULES.md` and this file.
2. Read all implementation documents relevant to the phase you are about to change.
3. Inspect the actual repository and compare it with the docs.
4. Run baseline Flutter analysis and tests.
5. Present a concise implementation plan and list of files to change before broad edits.

## Reference fidelity

The user's screen recording and detailed written UI specification are the primary design references. Reproduce the described layout, colors, seat map, camera movement, metrics and draggable sheet closely. Do not invent unrelated design elements. If the video cannot be inspected by your environment, state that limitation and use the provided screenshots/specification; do not claim to have watched it.

## Critical 3D rule

Do not call 2D CustomPainter polygons, gradients or perspective-projected paths “true 3D”. The final auditorium must use actual 3D meshes/scene objects, perspective camera, depth/occlusion, materials and lighting.

## Work in phases

- Phase 1: Audit and theme.
- Phase 2: Seat selection, showtime, legend and checkout.
- Phase 3: Renderer comparison and one-seat proof of concept.
- Phase 4: Full auditorium scene.
- Phase 5: camera transitions and look-around.
- Phase 6: POV HUD, mini-map, draggable sheet and metrics.
- Phase 7: tests, platform verification and polish.

After each phase:
- Run `flutter analyze` and relevant tests.
- Fix regressions before continuing.
- Report what changed and what remains.
- Do not claim completion without running the feature.

## Preserve existing functionality

Do not rewrite the app from scratch. Preserve stable seat IDs, selection logic, navigation, reusable camera calculations and mock data where valid. Do not delete the current viewport until the new 3D proof of concept passes on Android and iOS.

## Scope restrictions

This phase is a prototype. Do not add authentication, backend, live cinema inventory, real ticketing or payment processing. Book should display a mock confirmation only.

## Dependency discipline

Do not install every renderer option. Evaluate current package status and select one. Update `pubspec.yaml` only after the renderer decision. Document why each new dependency is required.

## Geometry discipline

Use a shared physical coordinate model including both aisle gaps. Do not use a continuous seat-column formula that ignores aisles. Compute metrics from the selected seat's physical position. Treat B4/F8/I12 values as approximate calibration targets, not per-seat hardcoded outputs.

## Final response expected from the agent

Provide:
- Summary of implementation.
- Files changed.
- Renderer and dependency decisions.
- Tests and builds actually run.
- Android/iOS verification status.
- Known issues and incomplete requirements.
