# POV HUD and Draggable Bottom Sheet

## Top floating controls

Overlay native Flutter widgets above the 3D viewport:
- Left: circular translucent dark back button.
- Center: dark pill badge, approximately `#16161AE6`, with a glowing mint status dot.
- Dynamic badge text: `View from B4`, `View from F8`, `View from I12`, etc.

The label must derive from the selected seat model.

## Draggable information sheet

Use `DraggableScrollableSheet` or a well-controlled equivalent animated bottom card.

Visual requirements:
- Dark `#121215` card.
- Rounded top corners, approximately 24 px.
- Small centered drag handle.
- Sheet can be pulled down to reveal more of the 3D view and pulled up to show full details.
- Avoid sheet/viewport gesture conflicts. Vertical sheet drag should not accidentally rotate the camera.

## Header content

Left side:
- Zone tag in mint uppercase:
  - Rows A–C: `UP CLOSE`
  - Rows D–G: `SWEET SPOT`
  - Rows H–I: `FULL PICTURE`
- Large title, e.g. `Row F, Seat 8`.
- Muted subtitle, e.g. `Standard · €12.50` or `Recliner · €16.00`.

Right side:
- Mini-map painted with `CustomPainter`.
- Show curved screen arc and all 9 × 14 seat dots.
- Highlight selected seat with a bright mint/white glow.
- Keep mini-map coordinate mapping identical to the actual seat grid.

## Three metric cards

Equal-width cards with `#1A1A1F` surface:
1. Distance to screen, e.g. `9.8 m` / `to screen`.
2. Horizontal field of view, e.g. `60°` / `field of view`.
3. Lateral offset, e.g. `0.3 m` / `right of centre`.

All values must come from the geometry service, not hardcoded per-seat display strings.

## Bottom actions

- Left: dark `Change seat` pill, `#1E1E24`, white text. Reverse to the 2D map.
- Right: white `Book · €12.50` pill, dark text. Show mock booking confirmation only.
- Button price and seat details must always reflect current selection.

## Responsive behavior

Support collapsed, intermediate and expanded sheet extents. Ensure the mini-map, metrics and actions remain accessible at the expanded extent on supported phone sizes. Test safe-area behavior.
