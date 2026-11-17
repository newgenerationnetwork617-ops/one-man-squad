# One Man Squad — Development Status

## Current milestone: First drivable vehicle foundation

The starter district now includes a simple blue car and an initial enter/exit driving loop.

### Included
- Godot 4 project using the Compatibility renderer as the initial low-end Android baseline.
- Compact greybox district with ground, roads, and building collision.
- Third-person on-foot player with camera-relative movement and touch camera look.
- Low-cost starter car scene with a basic body, cabin, wheels, collision, and chase camera.
- Arcade-style vehicle controller with forward/reverse acceleration, steering, braking, and wall-impact speed reduction.
- Enter/exit car button; entering switches to the vehicle camera and controls, while exiting returns control to the character.
- Lobby entry points for Adventure, Competition, and Racing.
- Offline-first structure with no backend or network dependency.

### Important limitations
- This is still an early prototype, not a complete game.
- The character and car are blockout models, not finished art or animations.
- Vehicle handling, camera behaviour, collisions, and touch layout have not been verified in a running Godot build.
- Competition and Racing menu entries are not yet playable modes; the car is only the first driving foundation.
- No APK has been built or tested on an Android phone.

## Next milestones
1. Run and fix automated Godot validation; verify scene parsing and runtime behaviour.
2. Improve the vehicle interaction and add a small driving test route.
3. Build the first complete Adventure mission loop.
4. Build a self-contained AI objective challenge.
5. Build a short AI racing circuit using the same vehicle foundation.
6. Add art, sound, menus, and progression in measured stages.
7. Profile memory, loading time, and performance on a 4 GB RAM Android device.

## Performance approach
Use small test spaces first, simple materials, low-cost lighting, collision only where needed, and progressively replace greybox assets after profiling. Do not assume a target frame rate or APK size until tested on target hardware.

## Validation notes
- The GitHub Actions workflow is configured for pushes to main, pull requests, and manual dispatch.
- The Android test checklist records the physical-device checks.
- A successful automated run and a physical Android test have not yet been confirmed.
