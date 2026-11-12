# Product Specification

## Product vision

Build a polished Flutter movie discovery and seat-preview prototype. Its standout feature is a 3D cinema preview that lets users understand what the screen looks like from a seat before proceeding.

## Target platforms

- Android
- iOS
- Development and testing on macOS

## Primary user journey

Home → Movie details → Select showtime → Seat map → Select seat → 3D seat preview → Return to seat map or continue through a clearly simulated UI-only next step.

## Screens

### 1. Home / movie discovery
- Dark cinematic visual theme.
- Featured movie section.
- Movie cards with poster, title, genre, and duration.
- Sections for currently showing and coming soon.
- All content comes from local mock data.

### 2. Movie details
- Movie poster/backdrop.
- Title, genre, duration, language, rating placeholder, and synopsis.
- Sample cinema/showtime choices.
- Continue to seat selection.

### 3. Seat selection
- Cinema screen indicator.
- Rows and numbered seats.
- Available, selected, and unavailable states.
- Seat legend.
- Selected seat summary and sample price.
- Clear action to open the 3D preview.
- Support selecting and deselecting seats.
- Use a consistent seat ID, such as `A1`, `A2`, `B1`.

### 4. 3D seat preview
- 3D auditorium with screen, floor, walls, and seat rows.
- Selected seat visibly identifiable in the scene if practical.
- Camera positioned at the selected seat's modeled eye point.
- Screen view should change according to the selected seat.
- Controls to switch to another seat and return to the seat map.
- Optional limited camera look-around, with sensible bounds.

## Seat states

- `available`: selectable.
- `selected`: selected locally by the user.
- `unavailable`: disabled sample seat, not a live booking status.

Do not call unavailable seats "booked" unless the UI explicitly explains that this is mock data.

## 3D preview requirements

- One auditorium coordinate system.
- Every seat has a stable ID, row, number, world position, and viewing/camera position.
- Camera position should be derived from the selected seat's position plus an eye-height offset.
- Camera target should point toward the screen center or a seat-specific viewing target.
- Camera transitions should interpolate position and orientation smoothly.
- Switching seats should update the view without loading an unrelated screen image.

## Visual direction

Use the uploaded reel as the visual and motion reference. Match its overall layout, visual hierarchy, seat selection behavior, and transition feel as closely as practical. Do not copy third-party logos or branding. If an exact detail cannot be reproduced, preserve the interaction and visual intent.

## Non-functional requirements

- Smooth scrolling and transitions.
- Avoid rebuilding the entire 3D scene for every small UI state change.
- Handle model loading and rendering errors gracefully.
- Keep the 2D seat map usable if the 3D asset fails to load.
- Use responsive sizing rather than fixed device-specific coordinates.
- Support accessibility labels for interactive seats and controls.

## Out of scope

Authentication, user profiles, backend, live showtimes, live seat inventory, seat locking, payments, real ticket generation, and production booking APIs.
