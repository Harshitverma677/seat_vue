# Step 1: Repository Foundation and Audit

## Objective

Understand the current `seat_vue` Flutter repository before refactoring.

## Tasks

1. Inspect the full `lib/` structure and `pubspec.yaml`.
2. Identify app entry point, routes, screens, state management, seat models and mock data.
3. Trace the current seat-selection-to-preview flow.
4. Identify which 3D viewport elements are actually 2D `CustomPainter` paths or polygons.
5. Run `flutter pub get`, `flutter analyze` and the existing test suite before edits.
6. Record the baseline results and any pre-existing failures.

## Deliverables

- Short architecture summary.
- File-by-file change plan.
- List of reusable code and code that must be replaced.
- Baseline analysis and test results.

## Gate

Do not start broad refactoring until the audit is complete and the plan is presented. Distinguish pre-existing errors from newly introduced errors.
