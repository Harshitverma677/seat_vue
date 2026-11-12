<div align="center">

# 🎬 SeatVue

**Pick your seat. See your view. Before you book.**

[![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
<br/>

> A movie booking UI prototype where you can **preview exactly what the screen looks like** from any seat — in first-person 3D — before you buy.

</div>

---

## 🎥 What is SeatVue?

SeatVue lets users browse movies, pick a showtime, select seats on an interactive 2D map, and then **step inside the auditorium** to see a real-time first-person 3D view from their chosen seat.

---

## ✨ Features

| | Feature |
|---|---|
| 🏠 | **Home Screen** — Featured carousel, genre filters, Now Showing & Coming Soon |
| 🎞️ | **Movie Details** — Cast, synopsis, showtime selector |
| 💺 | **Interactive 2D Seat Map** — 8×8 grid, available / selected / VIP / unavailable states |
| 🎭 | **First-Person 3D Preview** — See the screen from your exact seat using a custom `CustomPainter` projection engine |
| 🎬 | **Realistic Auditorium** — Curved 20-segment cinema screen, velvet seats, step lights, acoustic walls |
| 🕹️ | **Look Around** — Drag to pan the camera, tap Recenter to snap back smoothly |
| 🌑 | **Dark Cinema Theme** — Deep blacks, gold accents, red velvet throughout |

---

## 🗂️ Project Structure

```
lib/
├── app/              # Routes & app entry
├── core/
│   ├── theme/        # Colors, typography, Material theme
│   └── constants/    # Spacing, durations
├── data/             # Mock movies & auditorium data
├── models/           # Typed Dart models
├── features/
│   ├── home/         # Home screen & widgets
│   ├── movie_details/# Details screen
│   ├── seat_selection/# 2D seat map + controller
│   └── seat_preview/ # 3D viewport, camera, service
└── shared/           # Reusable widgets
```

---

## 🧠 3D Engine — How It Works

No game engine. No 3D packages. Pure Flutter.

- **Perspective projection** via camera basis matrix transforms
- **20-segment curved screen** drawn with `CustomPainter` paths
- **Camera placed at eye-level** for each of the 64 seats across 8 rows
- **Eased transitions** between seats using `AnimationController` + `Curves.easeOutCubic`
- **Movie backdrop** rendered onto the 3D screen via async `ImageStream`

---

## 📐 Architecture

```
UI Widgets  ──▶  ChangeNotifier Controller  ──▶  Mock Data Layer
                        │
                 Seat Camera Poses
                        │
              Cinema3DViewport (CustomPainter)
```

- Feature-first folder structure
- `ChangeNotifier` for state — no extra packages needed
- 26 custom UI components with centralized design tokens
- Zero third-party state management or routing libraries

---

## 🧪 Tests

```bash
flutter test        # 11/11 passing
flutter analyze     # 0 issues
```

| Test File | Coverage |
|---|---|
| `widget_test.dart` | App smoke test |
| `seat_selection_controller_test.dart` | 5 unit tests |
| `auditorium_camera_pose_test.dart` | 4 unit tests |
| `seat_preview_screen_test.dart` | 2 widget tests |

---

## 🚀 Getting Started

```bash
git clone https://github.com/Harshitverma677/seat_vue.git
cd seat_vue
flutter pub get
flutter run
```

> Requires Flutter 3.47+ and Dart 3.13+

---

## 🛠️ Tech Stack

| | |
|---|---|
| **Framework** | Flutter + Dart |
| **Rendering** | `CustomPainter` (perspective 3D projection) |
| **State** | `ChangeNotifier` / `ListenableBuilder` |
| **Data** | Local mock only — no backend |
| **Testing** | `flutter_test` |

---

## ⚠️ Scope

This is a **UI prototype** — no authentication, no backend, no real payments.
All movies, showtimes, and seat data are local mock data.

---

<div align="center">

### 👨‍💻 Built by [Harshit Verma](https://github.com/Harshitverma677)

⭐ Star this repo if you like it!

</div>
