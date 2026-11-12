# Step 6 — 3D Auditorium Scene

## Objective

Create and render a reusable 3D cinema auditorium independently of seat selection.

## Read first

- `README.md`
- `01_PRODUCT_SPEC.md`
- `02_ARCHITECTURE_AND_RULES.md`
- `07_STEP_05_SEAT_MAP.md`

## Functions performed in this step

1. Complete a renderer feasibility spike on the target Flutter version.
2. Record the selected rendering approach and why it was chosen.
3. Create or obtain a cinema auditorium model.
4. Include screen, floor, walls, seating rows, and basic lighting.
5. Optimize geometry and materials for mobile.
6. Load the model in a dedicated 3D preview widget/screen.
7. Add a default overview camera.
8. Handle loading, error, and disposal states.

## Asset guidance

Prefer a properly licensed or self-created GLB/GLTF model if the chosen renderer supports it. Keep the model in `assets/models/`. Document its source and license. Use low-to-medium polygon geometry and shared materials where possible.

## Camera coordinate conventions

Choose one consistent convention for the scene (for example, +Y up). Document the screen direction, row direction, seat spacing, and units. All seat and camera positions must use this convention.

## Deliverables

- Working 3D renderer spike.
- Cinema model asset.
- Scene-loading service/widget.
- Default camera view.
- Asset and renderer notes.

## Completion checklist

- [ ] Scene loads on target device.
- [ ] Screen and seat rows are visible.
- [ ] Materials and lighting are acceptable.
- [ ] Renderer is not recreated on every Flutter rebuild.
- [ ] Resources are disposed correctly.
- [ ] Model source/license is documented.
