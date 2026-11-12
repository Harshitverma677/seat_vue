# Documentation Index and Reading Order

This file is the entry point for developers and coding agents. Before implementing a step, read the documents listed for that step in the order shown. Follow the completion checklist before moving on.

## Always read first

1. [`README.md`](README.md) — project purpose, scope, and non-goals.
2. [`01_PRODUCT_SPEC.md`](01_PRODUCT_SPEC.md) — user journey and functional requirements.
3. [`02_ARCHITECTURE_AND_RULES.md`](02_ARCHITECTURE_AND_RULES.md) — code structure, state ownership, and implementation rules.

## Step-by-step reading guide

| Step | Goal | Read these files |
|---|---|---|
| 0 | Understand the project | `README.md`, `01_PRODUCT_SPEC.md`, `02_ARCHITECTURE_AND_RULES.md` |
| 1 | Create Flutter foundation | `03_STEP_01_FOUNDATION.md`, then `02_ARCHITECTURE_AND_RULES.md` |
| 2 | Build theme and reusable UI | `04_STEP_02_DESIGN_SYSTEM.md`, then `01_PRODUCT_SPEC.md` |
| 3 | Build movie browsing UI | `05_STEP_03_MOVIE_DISCOVERY.md`, then `01_PRODUCT_SPEC.md` |
| 4 | Build movie details and showtime selection | `06_STEP_04_MOVIE_DETAILS.md`, then `01_PRODUCT_SPEC.md` |
| 5 | Build the 2D seat map | `07_STEP_05_SEAT_MAP.md`, then `01_PRODUCT_SPEC.md` and `02_ARCHITECTURE_AND_RULES.md` |
| 6 | Add the 3D auditorium | `08_STEP_06_3D_AUDITORIUM.md`, then `02_ARCHITECTURE_AND_RULES.md` |
| 7 | Connect seats to camera positions and animate transitions | `09_STEP_07_CAMERA_AND_TRANSITIONS.md`, then `07_STEP_05_SEAT_MAP.md` and `08_STEP_06_3D_AUDITORIUM.md` |
| 8 | Polish and test the prototype | `10_STEP_08_POLISH_AND_TESTING.md`, then all relevant step documents |
| Any step | Give an AI coding agent project-wide instructions | `AGENT_INSTRUCTIONS.md` |

## Required order

Do not start the 3D transition before:
- The seat map works with mock data.
- Each seat has a stable unique ID.
- The 3D scene can load and render independently.
- The seat-to-camera mapping format has been agreed.

## Definition of done for the first UI prototype

- Movie browsing, movie details, showtime selection, and seat selection work with mock data.
- Tapping a seat opens the 3D preview for that exact seat.
- The camera transition is smooth and repeatable.
- Switching seats updates the camera target/position.
- Returning to the seat map preserves the selected seat.
- No authentication, payment, backend, or real booking is present.
