# Step 8 — UI Polish, Responsiveness, and Testing

## Objective

Make the UI-only prototype reliable, polished, and smooth on Android and iOS.

## Read first

- `README.md`
- `01_PRODUCT_SPEC.md`
- `02_ARCHITECTURE_AND_RULES.md`
- All relevant step documents for the screens being tested.

## Functions performed in this step

1. Compare screen layouts and transitions against the uploaded reel.
2. Tune animation duration, easing, and camera movement.
3. Check seat spacing and touch targets on small screens.
4. Check scrolling, safe areas, and orientation behavior.
5. Add loading and error states for 3D model loading.
6. Profile frame rate and memory use.
7. Test seat selection, preview, seat switching, and return navigation.
8. Remove debug UI and unused code.
9. Document known limitations.

## Test scenarios

- Open each movie from the home screen.
- Choose different showtimes.
- Select one seat and open its preview.
- Preview a front-row, center, side, and back-row seat.
- Switch between seats while in preview.
- Return to the map and verify selection is preserved.
- Try tapping unavailable seats.
- Rapidly tap preview/return controls.
- Test with the 3D model unavailable or failing to load.
- Test on a small and a large screen.

## Completion checklist

- [ ] Core user journey works end to end with mock data.
- [ ] UI is visually consistent.
- [ ] Seat-to-view mapping is believable and consistent.
- [ ] Transitions are smooth on target devices.
- [ ] No crashes from repeated navigation or taps.
- [ ] 3D assets and renderer resources are cleaned up.
- [ ] No authentication, payment, backend, or real booking functionality has slipped into scope.
