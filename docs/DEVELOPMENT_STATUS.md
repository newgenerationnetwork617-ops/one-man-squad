# One Man Squad — Development Status

## Current milestone: First playable Competition round

The starter district now has three activity foundations: a supply delivery mission, a checkpoint time trial, and a timed signal-collection challenge.

### Included
- Godot 4 project using the Compatibility renderer as the initial low-end Android baseline.
- Compact greybox district with ground, roads, and building collision.
- Third-person on-foot player with camera-relative movement and touch camera look.
- Low-cost starter car scene with a basic body, cabin, wheels, collision, and chase camera.
- Arcade-style vehicle controller with forward/reverse acceleration, steering, coasting, wall-impact speed reduction, and a dedicated brake input.
- Enter/exit car interaction with camera and control switching.
- Mobile brake button and an on-screen speed readout.
- Adventure mission: collect a supply crate, then reach the green delivery marker.
- Racing foundation: enter the car, select Racing, then pass four glowing checkpoints in order while a timer runs.
- Competition foundation: start an on-foot 60-second signal challenge and collect three glowing objectives in order.
- Activity progress and completion messages.
- Offline-first structure with no backend or network dependency.

### Important limitations
- This is still an early prototype, not a complete game.
- The character and car are blockout models, not finished art or animations.
- The delivery mission and signal challenge use simple placeholder geometry and trigger zones; neither has dialogue, map GPS, save persistence, or a reward inventory yet.
- The time trial is a short prototype route inside the starter district, not a full race with AI opponents, laps, results history, or tournaments.
- Competition is currently a solo timed objective challenge. AI rivals, team play, capture/escort rounds, and online play are not implemented yet.
- Vehicle handling, mission triggers, checkpoint detection, competition triggers, camera behaviour, collisions, and touch layout have not been verified in a running Godot build.
- The displayed 100 XP is a prototype mission message, not yet connected to a persistent progression system.
- No APK has been built or tested on an Android phone.

## Next milestones
1. Verify the project with an actual Godot 4 headless import and runtime launch; fix any parse/runtime issues found.
2. Improve route layout and vehicle handling based on runtime testing.
3. Add local save persistence and proper mission/round result data.
4. Expand Competition with simple AI rival behaviour and more objective variety.
5. Expand Racing with AI opponents, laps, and race results.
6. Add art, sound, menus, and progression in measured stages.
7. Profile memory, loading time, and performance on a 4 GB RAM Android device.

## Performance approach
Use small test spaces first, simple materials, low-cost lighting, collision only where needed, and progressively replace greybox assets after profiling. Do not assume a target frame rate or APK size until tested on target hardware.

## Validation notes
- The GitHub Actions workflow is configured for pushes to main, pull requests, and manual dispatch.
- The workflow status has not yet been confirmed for the latest commits.
- The Android test checklist records the physical-device checks.
- No successful Godot runtime test or physical Android test has been confirmed.
