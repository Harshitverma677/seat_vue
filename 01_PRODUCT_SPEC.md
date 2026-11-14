# Product Specification

## 1. Product goal

Create a premium dark cinema seat-booking experience. A user selects one seat on a 2D map, then enters a realistic 3D auditorium and sees the cinema screen from that exact seat's point of view.

The reference recording and the user's written specification are the visual and behavioral sources of truth. Match their layout and interactions closely; do not invent unrelated screens or controls.

## 2. Scope and exclusions

### Included
- `SeatSelectionScreen` with mock cinema information and showtimes.
- 9 rows (`A`–`I`) and 14 seats per row.
- Standard and recliner seat types, availability and single-seat selection.
- Sticky checkout bar.
- `SeatPovScreen` with real 3D auditorium rendering.
- Two-stage camera transition, reverse transition and subtle look-around.
- Floating POV controls and draggable details sheet.
- Seat mini-map and computed viewing metrics.
- Mock booking confirmation.

### Excluded in this phase
- Login or user accounts.
- Backend services or database.
- Live cinema listings, showtimes or seat availability.
- Payment gateway, payment processing or real ticket issuance.
- Production booking API integration.

The Book action must produce a clearly identified local/mock confirmation only.

## 3. Mock cinema content

- Cinema: `Meridian`
- Hall: `Hall 3`
- Display date: `Fri 14 Nov` (reference/mock copy, not a live date calculation)
- Showtime pills, in the specified order:
  - `17:30 2D`
  - `16:45 IMAX` (selected by default)
  - `22:15 2D`

Keep this data configurable in a mock-data source. Do not hardcode it throughout widgets.

## 4. Seat inventory

- Rows A through I.
- 14 seats in each row, numbered 1 through 14.
- Three blocks: seats 1–3, aisle, seats 4–11, aisle, seats 12–14.
- Rows A–H: Standard, €12.50.
- Row I: Recliner, €16.00.
- Each seat has a stable ID, row label, seat number, type, availability and world/map coordinate.
- Availability must be mock data and deterministic for tests. The written request does not specify which seats are taken; choose a small, documented mock pattern and keep it configurable. Never make the selected seat unavailable.

## 5. Screen flow

1. User lands on `SeatSelectionScreen`.
2. User may change showtime.
3. User selects one available seat. Selecting another moves the selection; tapping the selected seat clears it.
4. Continue is disabled until a seat is selected.
5. Continue opens `SeatPovScreen` and starts the overhead-to-first-person camera transition.
6. When settled, show the POV HUD and draggable information sheet.
7. Change seat or back reverses the transition and returns to the 2D map while preserving the selected seat unless the user explicitly clears or changes it.
8. Book displays a mock confirmation using the selected seat and price.

## 6. Zone labels

- Rows A–C: `UP CLOSE`
- Rows D–G: `SWEET SPOT`
- Rows H–I: `FULL PICTURE`

## 7. Design principles

- Deep near-black background, restrained borders, high contrast.
- Mint green is reserved for selected seat, selected-seat highlight, status dot and primary accent actions.
- The 3D auditorium uses crimson seats, with only the selected seat rendered mint green.
- Do not add extra navigation bars, headers, or decorative elements absent from the reference.
- UI should remain responsive across supported phone sizes and safe areas.
