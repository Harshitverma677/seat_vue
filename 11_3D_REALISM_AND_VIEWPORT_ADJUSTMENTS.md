# 3D Realism and Viewport Adjustments

## Geometry realism

- Seat backs and cushions must be volumetric meshes with visible thickness.
- Include rounded/padded seat backs, cushions, side bolsters, armrests and recliner footrests.
- Use bevels/curved surfaces where they materially improve silhouette.
- Avoid flat rectangular planes pretending to be complete seats.
- Row I recliners should be visibly wider and have a footrest/front edge.

## Auditorium realism

- Model tiered floor elevations consistently across rows.
- Include aisle steps, side rails, walls and ceiling.
- Use red guide-strip lighting on side railings, visible from rear seats.
- The curved screen should have actual 3D curvature if required by the visual target.
- Screen image should be an authorized warm desert landscape asset.

## Materials and lighting

- Crimson seat fabric: `#B91C1C`, matte fabric-like response.
- Selected seat: `#4ADE80`, visually distinct but not so bright that it overwhelms the scene.
- Armrests: dark near-black.
- Use restrained ambient, directional and emissive lighting.
- Add subtle red aisle illumination and soft screen light on nearby headrests.
- Avoid excessive bloom, clipping and glossy plastic appearance.

## Viewport

- Use a perspective camera with realistic field of view and near/far planes.
- Avoid camera clipping through seat backs, floor or ceiling.
- Maintain a clear view of the screen from all seat positions.
- Keep selected seat visible in overhead view.
- In row I POV, show the selected recliner's green footrest/front edge at the bottom of the viewport where the geometry and camera framing allow it.

## Performance

- Reuse meshes and materials; consider instancing for repeated seats.
- Use sensible texture sizes and compression.
- Keep draw calls, shadows and lights within mobile budgets.
- Pause or reduce rendering when the preview is off-screen.
- Dispose of scene resources correctly.
- Measure performance on actual Android and iOS devices, not only desktop.
