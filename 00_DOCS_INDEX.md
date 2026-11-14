# Documentation Index

Read these files in order. Use the step documents as implementation gates.

| Order | Document | Purpose |
|---|---|---|
| 1 | `README.md` | Project summary and scope |
| 2 | `01_PRODUCT_SPEC.md` | Screens, content, interaction requirements |
| 3 | `02_ARCHITECTURE_AND_RULES.md` | Boundaries, state ownership, integration rules |
| 4 | `AGENT_INSTRUCTIONS.md` | Required workflow and coding-agent behavior |
| 5 | `03_STEP_01_FOUNDATION.md` | Repository audit and baseline |
| 6 | `04_STEP_02_THEME_AND_COMPONENTS.md` | Palette, theme and reusable UI |
| 7 | `05_STEP_03_SEAT_SELECTION.md` | Seat grid and selection state |
| 8 | `06_STEP_04_SEAT_MAP_AND_CHECKOUT.md` | Screen arc, legend and checkout bar |
| 9 | `07_STEP_05_3D_RENDERER.md` | Renderer evaluation and proof of concept |
| 10 | `08_STEP_06_3D_AUDITORIUM.md` | Actual 3D auditorium scene and assets |
| 11 | `09_STEP_07_CAMERA_AND_TRANSITIONS.md` | Overhead-to-seat POV and reverse transitions |
| 12 | `13_POV_HUD_AND_BOTTOM_SHEET.md` | Floating controls and draggable sheet |
| 13 | `14_SEAT_METRICS_AND_GEOMETRY.md` | Seat coordinates and metric calculations |
| 14 | `11_3D_REALISM_AND_VIEWPORT_ADJUSTMENTS.md` | Visual quality and mobile optimization |
| 15 | `12_TRUE_3D_RENDERER_MIGRATION.md` | Safe migration from current 2D-painted viewport |
| 16 | `10_STEP_08_POLISH_AND_TESTING.md` | Tests, acceptance criteria and final checks |

## Recommended implementation gates

- **Gate A:** Finish repository audit, theme and seat-selection UI. Run analysis and tests.
- **Gate B:** Build a separate 3D proof of concept with one seat, a screen, lighting and a controllable camera. Verify on Android and iOS.
- **Gate C:** Build the complete auditorium and connect selected-seat coordinates.
- **Gate D:** Add camera choreography, POV HUD, draggable sheet and metrics.
- **Gate E:** Run the full acceptance checklist and compare screenshots/video against the supplied reference.

Do not skip gates or perform a destructive renderer replacement before Gate B passes.
