# Step 4: Screen Arc, Legend and Checkout

## Curved screen header

Use `CustomPainter` for this 2D UI element only:
- Draw a thin, wide upward-curving arc.
- Add a soft radial or vertical white-to-transparent glow below the arc.
- Center the label `SCREEN` with tracked uppercase lettering.
- Keep the painter responsive to available width and avoid hardcoded screen pixel dimensions.

This `CustomPainter` is appropriate for the 2D seat-selection screen decoration. It must not be represented as a 3D cinema screen.

## Legend

Center a horizontal legend below row I:
- Available
- Taken
- Recliner
- Selected

Each item uses a small swatch and readable label. On narrow devices, allow compact spacing or horizontal scrolling without clipping.

## Sticky checkout bar

Use an elevated dark surface `#121215` with a subtle top border and safe-area padding.

No seat selected:
- Label: `Choose your seat`
- Value: `—`
- Continue: disabled, muted `#242429`

Seat selected:
- Label example: `Row F · Seat 8`
- Price: `€12.50` or `€16.00`
- Continue: enabled, mint `#4ADE80`, dark text.

The checkout bar must not cover the last seat row or legend. Account for bottom safe area and scrollable content height.

## Interaction

Continue passes the selected seat ID/model to `SeatPovScreen`. Do not reconstruct the seat from the displayed label.
