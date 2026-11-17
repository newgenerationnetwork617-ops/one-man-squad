# One Man Squad — Development Status

## Current milestone: First driving time trial foundation

The starter district now includes a checkpoint-based time trial using the shared starter car.

### Included
- Godot 4 project using the Compatibility renderer as the initial low-end Android baseline.
- Compact greybox district with ground, roads, and building collision.
- Third-person on-foot player with camera-relative movement and touch camera look.
- Low-cost starter car scene with a basic body, cabin, wheels, collision, and chase camera.
- Arcade-style vehicle controller with forward/reverse acceleration, steering, coasting, wall-impact speed reduction, and a dedicated brake input.
- Enter/exit car interaction with camera and control switching.
- Mobile brake button and an on-screen speed readout.
- First Adventure mission: locate the supply crate, collect it by entering its marker, then reach the green delivery marker.
- Mission state and on-screen objective text update from collection to delivery completion.
- First Racing foundation: enter the car, select Racing, then pass four glowing checkpoints in order while a timer runs.
- Offline-first structure with no backend or network dependency.

### Important limitations
- This is still an early prototype, not a complete game.
- The character and car are blockout models, not finished art or animations.
- The mission uses simple placeholder geometry and a basic trigger zone; it has no dialogue, map GPS, save persistence, or reward inventory yet.
- The time trial is a short prototype route inside the starter district, not a full race with AI opponents, laps, results history, or tournaments.
- Vehicle handling, mission triggers, checkpoint detection, camera behaviour, collisions, and touch layout have not been verified in a running Godot build.
- Competition is still a lobby placeholder; its objective-based AI challenge remains to be built.
- The displayed 100 XP is a prototype mission message, not yet connected to a persistent progression system.
- No APK has been built or tested on an Android phone.

## Next milestones
1. Run and fix automated Godot validation; verify scene parsing and runtime behaviour.
2. Improve route layout and vehicle handling based on runtime testing.
3. Add mission guidance, interaction feedback, and local save persistence.
4. Build a self-contained AI objective challenge for Competition.
5. Expand Racing with AI opponents, laps, and race results.
6. Add art, sound, menus, and progression in measured stages.
7. Profile memory, loading time, and performance on a 4 GB RAM Android device.

## Performance approach
Use small test spaces first, simple materials, low-cost lighting, collision only where needed, and progressively replace greybox assets after profiling. Do not assume a target frame rate or APK size until tested on target hardware.

## Validation notes
- The GitHub Actions workflow is configured for pushes to main, pull requests, and manual dispatch.
- The Android test checklist records the physical-device checks.
- A successful automated run and a physical Android test have not yet been confirmed.
