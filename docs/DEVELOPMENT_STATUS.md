# One Man Squad — Development Status

## Current milestone: Third-person control foundation

The starter project now has a more useful third-person control setup.

### Included
- Godot 4 project using the Compatibility renderer as the initial low-end Android baseline.
- Compact greybox test district with ground and building collision.
- Placeholder third-person player and camera follow.
- Camera-relative movement: forward and sideways movement follow the direction the camera faces.
- Right-side swipe camera look on touchscreens; left-side movement buttons remain available.
- Mouse-drag camera look for editor/desktop testing.
- Lobby entry points for Adventure, Competition, and Racing.
- Offline-first structure with no backend or network dependency.

### Important limitations
- This remains a foundation prototype, not a complete game.
- The player is still a capsule placeholder; finished character art and animations are not present.
- The district uses simple blockout geometry, not finished art.
- Competition and Racing buttons currently identify their planned modes; those modes are not playable yet.
- No APK has been built or tested on an Android phone.
- The camera and controls have not yet been verified in a running Godot build.

## Next milestones
1. Confirm automated Godot validation and fix any project errors it reveals.
2. Add a first drivable vehicle and basic vehicle interaction.
3. Build the first small Adventure mission loop.
4. Build a self-contained AI objective challenge.
5. Build a short AI racing circuit.
6. Add art, sound, menus, and progression in measured stages.
7. Profile memory, loading time, and performance on a 4 GB RAM Android device.

## Performance approach
Use small test spaces first, simple materials, low-cost lighting, collision only where needed, and progressively replace greybox assets after profiling. Do not assume a target frame rate or APK size until tested on target hardware.

## Validation notes
- The GitHub Actions workflow is configured for pushes to main, pull requests, and manual dispatch.
- The Android test checklist records the physical-device checks.
- A successful automated run and a physical Android test have not yet been confirmed.
