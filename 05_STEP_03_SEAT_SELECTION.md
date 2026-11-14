# Step 3: Seat Selection Screen

## Screen structure

Implement `SeatSelectionScreen` with the following top-to-bottom order:

1. App bar: circular back control on left; centered `Meridian` title and `Hall 3 · Fri 14 Nov` subtitle; circular info control on right.
2. Showtime row: `17:30 2D`, `16:45 IMAX`, `22:15 2D`. The middle pill is selected by default.
3. Curved screen header: thin upward-curving arc, soft white-to-transparent glow beneath, centered tracked uppercase `SCREEN`.
4. Seat grid: rows A–I, 14 seats per row.
5. Legend: Available, Taken, Recliner, Selected.
6. Sticky checkout bar at the bottom.

## Grid geometry

Each row contains:
- Left block: seats 1–3.
- Aisle gap.
- Center block: seats 4–11.
- Aisle gap.
- Right block: seats 12–14.

The row label appears at the far left. Aisles must be real spacing in the layout and in the 3D coordinate model, not merely a visual separator.

Rows A–H are Standard at €12.50. Row I is Recliner at €16.00 and should be slightly wider/taller with a subtle `#2A1C1E` tint.

## Seat states

- Available: `#1E1E24` fill, `#2E2E36` border.
- Taken: `#111114`, low contrast and non-interactive.
- Recliner: warm rose tint, distinguish available/taken state accessibly.
- Selected: `#4ADE80`, subtle dark center dot and soft green glow.

Single selection:
- Tapping an available seat selects it and clears any previous selection.
- Tapping the currently selected seat clears selection.
- Tapping a taken seat does nothing.
- Continue is disabled when there is no selected seat.

## Data model

Every seat must have a stable ID, row index, column/seat number, row label, seat type, availability, price and normalized/world position. Do not infer seat identity from widget order after layout changes.

## Acceptance

- Exactly 126 seat positions are represented (9 × 14).
- Aisles occur after seats 3 and 11.
- Row I is recliner; rows A–H are standard.
- Selection and deselection work as specified.
- Taken seats cannot be selected.
- Seat state survives navigation to POV and back.
