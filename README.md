# Movie Booking UI with 3D Seat Preview

A Flutter application prototype focused on a cinematic seat-selection experience. The defining interaction is selecting a seat in a 2D auditorium map and transitioning into a 3D cinema view that previews the movie screen from that seat's position.

## Current scope

**Build now**
- Flutter UI and navigation
- Movie discovery and movie details using local mock data
- Interactive 2D seat map
- 3D cinema auditorium visualization
- Seat-to-camera-position mapping
- Animated transitions between the seat map and 3D preview
- Seat switching and preview controls
- Responsive layouts, loading/error states, and UI polish

**Explicitly out of scope for this phase**
- Authentication and user accounts
- Backend, APIs, or cloud database
- Real-time seat availability or seat locking
- Payment gateway or checkout transactions
- Real ticket issuance, QR validation, or booking confirmation
- Production cinema/showtime integrations

Use local mock data and clearly label simulated states. Do not imply that a seat is actually reserved.

## The core experience

1. User opens the app and browses sample movies.
2. User opens a movie and chooses a sample showtime.
3. User sees a 2D seat map with available, selected, and unavailable seats.
4. User taps a seat.
5. The selected seat is highlighted and its ID is passed to the 3D preview.
6. The 3D camera animates to the camera position associated with that seat.
7. The user can select another seat, inspect the view, and return to the seat map.

## Key product principle

The 3D preview must correspond to the selected seat's actual modeled position and orientation. It must not be a random static image or a generic view reused for every seat.

## Documentation map

Start with [`00_DOCS_INDEX.md`](00_DOCS_INDEX.md). It tells you which documents to read at each development step.

## Development rules

- Keep widgets small and focused.
- Separate UI, mock data, and 3D scene logic.
- Keep seat identity and seat-to-camera mapping in one clear model/service layer.
- Use named constants for colors, spacing, and animation durations.
- Make transitions interruptible or safely ignore repeated taps while an animation is running.
- Test on a physical device and simulator/emulator.
- Do not add authentication, payment, backend, or booking functionality until the scope is deliberately expanded.
