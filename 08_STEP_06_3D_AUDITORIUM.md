# Step 6: Build the 3D Auditorium

## Scene requirements

Build an actual 3D scene, not a 2D canvas drawing with perspective-like polygons.

Include:
- Tiered auditorium floor with nine seat rows A–I.
- 14 seat positions per row, preserving the same aisle layout as the 2D map.
- Individual 3D seats with backrest, seat cushion, thickness and armrests.
- Wider recliner geometry for row I, including a footrest/front edge.
- Black or near-black armrests.
- Auditorium walls, ceiling, side railings, steps and aisles.
- Subtle red aisle guide-strip lighting, especially visible from rear seats.
- Large cinema screen at the front.
- Warm desert landscape image on the screen. Use an original, licensed, public-domain or otherwise authorized asset; do not extract copyrighted movie frames.
- Ambient and directional lighting, realistic shadows and material response.

## Materials

- Standard seat material: deep crimson `#B91C1C`.
- Selected seat material: mint `#4ADE80`.
- Armrests: dark charcoal/black.
- Recliner surfaces: crimson family with distinguishable geometry.
- Floor and walls: dark, low-reflection materials.

Use physically based materials where supported. Fabric should not look like glossy plastic. Use suitable roughness and restrained highlights.

## Selected seat mapping

Map the selected seat's stable ID to exactly one 3D mesh or instance. Only that seat should turn mint green. When the selection changes, restore the previous seat's normal material and highlight the new seat.

## Scene layout

The 3D world coordinates must come from the same auditorium dimension configuration used by the Dart seat-metrics service. Keep row spacing, seat spacing and aisle gaps consistent across 2D and 3D.

## Performance

Use shared geometry/materials or instancing where appropriate. Avoid creating unnecessary independent render resources for every repeated object. Add sensible loading progress and error handling.
