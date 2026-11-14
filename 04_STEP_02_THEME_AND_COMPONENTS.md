# Step 2: Theme and Reusable Components

## Required palette

| Token | Hex | Usage |
|---|---|---|
| `scaffold` | `#0A0A0C` | Main background |
| `surface` | `#16161A` | Cards, inactive pills |
| `surfaceBorder` | `#26262C` | 1 px card/pill border |
| `accent` | `#4ADE80` | Selected seat and green CTA |
| `accentText` | `#052E16` | Text on mint CTA |
| `activePill` | `#FFFFFF` | Selected showtime pill |
| `activePillText` | `#0A0A0C` | Text on selected showtime |
| `reclinerFill` | `#2A1C1E` | Recliner seat map fill |
| `availableFill` | `#1E1E24` | Available seat |
| `availableBorder` | `#2E2E36` | Available seat outline |
| `takenFill` | `#111114` | Unavailable seat |
| `checkoutSurface` | `#121215` | Sticky checkout and POV sheet |
| `metricSurface` | `#1A1A1F` | Metric cards |
| `theaterSeat` | `#B91C1C` | 3D seat material |

The 3D selected seat uses `#4ADE80`; all other available/taken/recliner mesh states should remain semantically correct. Do not color every 3D seat mint.

## Flutter theme

Create named constants and configure `ThemeData`/ColorScheme consistently. Use Material 3 if already used by the project; do not introduce a competing theme system.

## Reusable components

Create or refactor focused widgets for:
- Circular icon control.
- Showtime pill.
- Seat tile.
- Seat legend item.
- Curved screen header.
- Checkout bar.
- POV status badge.
- Metric card.
- Mini-map.
- POV action button.

## Visual rules

- Keep border radii, padding, typography and spacing consistent.
- Respect safe areas and keyboard-free full-screen preview.
- Avoid default Material button styling if it differs from the reference.
- Ensure disabled controls are visibly disabled and not tappable.
