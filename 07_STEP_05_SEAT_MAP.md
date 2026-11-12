# Step 5 — Interactive 2D Seat Map

## Objective

Build the complete seat-selection UI and reliable selection state before adding 3D behavior.

## Read first

- `README.md`
- `01_PRODUCT_SPEC.md`
- `02_ARCHITECTURE_AND_RULES.md`
- `06_STEP_04_MOVIE_DETAILS.md`

## Functions performed in this step

1. Define the `Seat` model and seat status enum.
2. Create mock auditorium rows and seat numbers.
3. Render the screen indicator and seat grid.
4. Render available and unavailable seats distinctly.
5. Support selecting and deselecting available seats.
6. Show selected seat IDs and a sample total price.
7. Preserve selection when opening and returning from preview.
8. Add an action to open the 3D preview for the selected seat.

## Seat ID convention

Use stable IDs such as `A1`, `A2`, `B1`. Do not use a widget index as the permanent identity of a seat.

## Selection rules for this prototype

- Unavailable seats cannot be selected.
- Tapping an available seat selects it.
- Tapping a selected seat deselects it.
- The selected seat list is the single source of truth.
- If the reel's interaction previews one seat at a time, keep a clear `previewSeatId` separate from the selected-seat collection.

## Deliverables

- Seat model.
- Mock auditorium layout.
- Interactive seat-map screen.
- Seat legend.
- Selected-seat summary.
- Preview navigation callback.

## Completion checklist

- [ ] Seat rows and labels are correct.
- [ ] Available/unavailable/selected states are clear.
- [ ] Tapping seats updates state immediately.
- [ ] Unavailable seats do not respond.
- [ ] Selected seat ID is passed to the preview screen.
- [ ] Returning from preview preserves state.
