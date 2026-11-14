# Step 7: Camera, POV and Transitions

## Camera choreography

Use an approximately 1200 ms transition with `Curves.easeInOutCubic` or the renderer's equivalent easing.

### Stage 1: 0%–35%
- Cross-fade from the 2D selection UI.
- Move to a top-down overhead 3D camera.
- Show the auditorium rows and the selected mint-green seat in context.

### Stage 2: 35%–100%
- Interpolate camera position and look target along a smooth curved path.
- Finish at the selected seat's seated eye-level camera pose.
- Aim at the center of the cinema screen.
- Use the selected seat's actual world position and orientation.

Do not linearly interpolate only between two arbitrary positions if it creates a camera collision or visibly unnatural movement. Use a curve or staged interpolation and validate the path.

## Camera pose

Derive the camera origin from:
- Selected seat world position.
- Seat forward direction.
- Configured seated eye-height offset.
- Small configurable forward/back offset to avoid intersecting the seat mesh.

The screen look target should be a real scene coordinate. Camera pose must vary for front, middle, back, center and side seats.

## Interactive look-around

After the camera settles:
- Enable subtle horizontal and vertical drag.
- Clamp yaw and pitch to comfortable limits.
- Do not allow users to rotate behind the seat or point the camera through the floor/ceiling.
- Provide recenter behavior if the design includes it.
- Disable or reduce look input while a transition is running.

## Reverse transition

Back and Change seat must:
1. Close or collapse the POV sheet as appropriate.
2. Animate camera back to overhead.
3. Cross-fade back to the 2D seat map.
4. Preserve selected seat and showtime state.

Prevent double taps from starting overlapping transitions. Expose transition completion/error events to Flutter.
