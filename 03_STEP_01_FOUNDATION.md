# Step 1 — Flutter Project Foundation

## Objective

Create a clean Flutter project that runs on the target devices and has a maintainable starting structure.

## Read first

- `README.md`
- `01_PRODUCT_SPEC.md`
- `02_ARCHITECTURE_AND_RULES.md`

## Functions performed in this step

1. Create the Flutter application.
2. Confirm Flutter and Dart versions.
3. Configure Android and iOS targets.
4. Add the initial folder structure.
5. Add app entry point and a minimal app widget.
6. Configure a temporary dark theme.
7. Verify the app launches on an emulator/simulator and physical device if available.
8. Initialize Git and make the first commit if desired.

## Suggested commands

```bash
flutter doctor -v
flutter create movie_booking_ui
cd movie_booking_ui
flutter run
```

## Deliverables

- A running Flutter app.
- Clean project structure.
- No Firebase or backend packages.
- No authentication or payment packages.

## Completion checklist

- [ ] `flutter doctor -v` has no blocking issue for the chosen target.
- [ ] App launches successfully.
- [ ] Android build works.
- [ ] iOS build works if Xcode is configured.
- [ ] Folder structure is in place.
- [ ] No out-of-scope dependencies have been added.
