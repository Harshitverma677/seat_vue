# Seat Metrics and Auditorium Geometry

## 1. One shared coordinate model

Define auditorium dimensions in one typed configuration and use it for:
- 2D seat-map spacing.
- 3D seat mesh positions.
- Selected-seat camera position.
- Mini-map positions.
- Metric calculations.

Do not independently approximate seat positions in each layer.

## 2. Seat layout

Rows A–I map to row indices 0–8. Seat numbers 1–14 map to column indices 0–13.

There are physical aisle gaps after seat numbers 3 and 11. Therefore, physical lateral position must not be calculated using a simple uninterrupted `(colIndex - 6.5) * seatSpacing` expression.

Suggested lateral coordinate construction:
1. Compute each seat's local position within its block.
2. Add the widths of any aisle gaps to blocks after the first and second aisles.
3. Center the complete seating arrangement around auditorium center.
4. Apply a row-specific seat width only where appropriate for recliners, without changing logical seat IDs.

Use the resulting world-space X coordinate as `rawOffset` (positive means right of screen center, negative means left).

## 3. Longitudinal coordinate

Use named constants:
- `firstRowDist`
- `rowSpacing`

For row index `r`:
`zDistance = firstRowDist + (r * rowSpacing)`

Define the sign convention once. In the scene, the screen is at the front and row depth increases toward the back.

## 4. Metrics

Let:
- `zDistance` be perpendicular distance from the row's eye position to the screen plane.
- `rawOffset` be lateral offset from the screen center.
- `halfScreen` be half the physical screen width.
- `directDistance` be Euclidean distance from the seat eye point to the screen center.

Calculate:
`directDistance = sqrt(zDistance^2 + rawOffset^2)`

Calculate horizontal angular field of view:
`fovDegrees = (atan2(halfScreen + rawOffset, zDistance) + atan2(halfScreen - rawOffset, zDistance)) * (180 / pi)`

Use radians from `atan2`; convert the final sum to degrees. Validate sign and ordering with left/right seats and screen-edge rays.

## 5. Displayed distance definition

The UI examples describe the distance metric as the row's front-to-screen depth. Display `zDistance` as `Distance to screen` so the values are comparable to the requested calibration examples. Keep `directDistance` available for camera/diagnostic use, or label it explicitly as straight-line distance if it is ever displayed. Do not silently mix these definitions.

## 6. Calibration targets

Use these as approximate calibration targets, not hardcoded outputs:

| Seat | Target depth | Target horizontal FOV | Target lateral offset |
|---|---:|---:|---:|
| B4 | ~6.3 m | ~86° | ~2.2 m left |
| F8 | ~9.8 m | ~60° | ~0.3 m right |
| I12 | ~13.3 m | ~45° | ~3.3 m right |

The seat layout's aisle gaps and center origin determine the offsets. The physical screen width determines FOV. Tune the named auditorium dimensions to get close to all three targets simultaneously.

Important: the examples are approximate calibration constraints. Do not insert per-seat exceptions or hardcoded lookup values to force a match. If one set of physical dimensions cannot meet all targets, report the discrepancy and propose a coherent dimension adjustment.

## 7. Zone classification

- Row indices 0–2: `UP CLOSE`.
- Row indices 3–6: `SWEET SPOT`.
- Row indices 7–8: `FULL PICTURE`.

## 8. Unit tests

Test:
- Seat coordinates are symmetric around auditorium center, accounting for the central seat gap pattern.
- Aisle gaps are wider than normal seat spacing.
- Offset sign is correct on left and right.
- FOV decreases as row depth increases, with other dimensions fixed.
- Distance increases from front rows to back rows.
- Calibration targets are within a documented tolerance.
- Recliner seat width/position does not corrupt logical column indexing.
