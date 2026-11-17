# One Man Squad — Development Status

## Current milestone: Project foundation

This repository now contains the initial Godot 4 project scaffold.

### Included in this milestone
- Godot project configuration using the Compatibility renderer as the initial low-end Android baseline.
- A small greybox 3D test district with simple collision.
- A third-person placeholder player and basic movement controller.
- On-screen directional buttons for touch testing.
- Lobby entry points for Adventure, Competition, and Racing.
- Offline-first project structure; no backend or network dependency.

### Important limitations
- This is a foundation prototype, not a complete game.
- The player is currently represented by a capsule placeholder.
- The district uses simple blockout geometry, not finished art.
- Competition and Racing buttons currently identify their planned mode; those modes are not playable yet.
- No APK has been built or device-tested yet.

## Next milestones
1. Validate the project with the matching Godot 4 editor and export templates.
2. Test touch layout, camera follow, movement, collision, and frame rate on a real Android device.
3. Improve the player camera and add an initial drivable vehicle.
4. Build the first small Adventure mission loop.
5. Build a self-contained AI objective challenge.
6. Build a short AI racing circuit.
7. Profile memory, loading time, and performance on a 4 GB RAM Android device.

## Performance approach
Use small test spaces first, simple materials, low-cost lighting, collision only where needed, and progressively replace greybox assets after profiling. Do not assume a target frame rate or APK size until tested on target hardware.
