# One Man Squad — Development Status

## Current milestone: Android device verification

The first playable prototype now builds successfully as an Android debug APK from the `main` branch. Automated Godot gameplay and save-state checks also pass. The next quality gate is installation and hands-on testing on the target Android phone.

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
- Offline local progress file using Godot `ConfigFile`: delivery completion, best time-trial result, and completed Competition rounds are saved under `user://progress.cfg`.
- A local progress summary is shown in the HUD.
- Offline-first structure with no backend or network dependency.
- Android Debug export preset and GitHub Actions workflow for ARMv7 and ARM64.

### Automated verification completed
- Godot 4.7.2 project import and main-scene smoke test passed in GitHub Actions.
- Automated gameplay checks passed for player/vehicle spawning, mission pickup and delivery, four racing checkpoints, Competition completion, local save writing, and persistence after scene reload.
- Android Debug APK workflow completed successfully on the `main` branch on 2026-11-17.
- The APK was exported and checked by the workflow; the artifact was downloaded and its ZIP archive was successfully extracted.

### Important limitations
- This is still an early prototype, not a complete game.
- The character and car are blockout models, not finished art or animations.
- The delivery mission and signal challenge use simple placeholder geometry and trigger zones; neither has dialogue, map GPS, or a reward inventory yet.
- The time trial is a short prototype route inside the starter district, not a full race with AI opponents, laps, results history, or tournaments.
- Competition is currently a solo timed objective challenge. AI rivals, team play, capture/escort rounds, and online play are not implemented yet.
- Actual touch input, camera feel, physics handling, collision feel, screen layout, and Android performance have not yet been verified on a physical phone.
- The displayed 100 XP is a prototype mission message, not yet connected to a persistent progression system.
- The current APK is a debug build signed with a temporary CI key. It is for testing only, not public release distribution.

## Next milestones
1. Install the current debug APK on the target Android phone and complete the device checklist.
2. Fix any startup, layout, touch, camera, movement, driving, collision, or save/load issues found.
3. Measure performance and memory on the actual 4 GB RAM device before expanding the world.
4. Improve vehicle handling and route layout based on device results.
5. Expand Competition and Racing with carefully scoped offline AI and varied objectives.
6. Add visual assets, sound, menus, and progression in measured stages.
7. Prepare permanent release signing only when the game is ready for a controlled release.

## Performance approach
Use small test spaces first, simple materials, low-cost lighting, collision only where needed, and progressively replace greybox assets after profiling. Do not assume a target frame rate or memory use until tested on target hardware.

## Validation notes
- Godot gameplay validation run: https://github.com/newgenerationnetwork617-ops/one-man-squad/actions/runs/44127820598
- Main-branch Android Debug build run: https://github.com/newgenerationnetwork617-ops/one-man-squad/actions/runs/44129442931
- Main-branch artifact: `one-man-squad-android-debug`, approximately 57.1 MB ZIP, created 2026-11-17 and scheduled to expire 2026-11-24.
- A successful cloud export confirms that an APK was produced; it does not prove that it installs, runs smoothly, or has correct touch controls on a physical device.
