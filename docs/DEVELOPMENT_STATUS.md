# One Man Squad — Development Status

## Current milestone: Second offline mission, XP progression, and park plaza

The current prototype includes a readable humanoid blockout with face and hair details plus procedural walk-cycle motion; two detailed low-cost vehicles with animated wheels; a starter district with road markings, sidewalks, facade windows, trees, streetlights, and a compact park plaza. These remain low-cost procedural assets designed for the initial Android Compatibility renderer.

The first playable prototype now builds successfully as an Android debug APK from the `main` branch. Automated Godot gameplay and save-state checks also pass. The next quality gate is installation and hands-on testing on the target Android phone.

### Included
- Godot 4 project using the Compatibility renderer as the initial low-end Android baseline.
- Expanded greybox district with a larger ground plane, connected road branches, building collision, perimeter barriers, road markings, sidewalks, facade windows, trees, and streetlights.
- Third-person on-foot player with camera-relative movement, right-side touch camera look, face/hair details, and lightweight procedural walk animation.
- Two selectable low-cost vehicles: the blue starter sedan and a red sport car with a spoiler, distinct body finish, headlamps, tire materials, animated wheels, collision, and chase camera. Vehicle switching is available while on foot near the parked car.
- Arcade-style vehicle controller with forward/reverse acceleration, steering, coasting, wall-impact speed reduction, and a dedicated brake input.
- Enter/exit car interaction with camera and control switching.
- Mobile brake button and an on-screen speed readout.
- Two offline adventure missions: deliver the first supply crate, then unlock a park-plaza mission to collect three supply caches in order.
- Expanded racing route: enter either car, select Racing, and pass twelve glowing checkpoints through the starter district's main and side roads while a timer runs.
- Competition foundation: start an on-foot 60-second signal challenge and collect three glowing objectives in order.
- Activity progress and completion messages.
- Offline local progress file using Godot `ConfigFile`: both mission completion flags, earned XP, best time-trial result, and completed Competition rounds are saved under `user://progress.cfg`.
- A local progress summary and persistent XP total are shown in the HUD.
- Compact park plaza landmark with paths, fountain feature, benches, and trees.
- In-game pause panel with Resume and Save Progress actions.
- Offline-first structure with no backend or network dependency.
- Android Debug export preset and GitHub Actions workflow for ARMv7 and ARM64.

### Automated verification completed
- Godot 4.7.2 project import and main-scene smoke test passed in GitHub Actions.
- Automated gameplay checks passed for player and both vehicle variants, vehicle switching, mission pickup and delivery, both missions and XP persistence, twelve racing checkpoints, Competition completion, local save writing, and persistence after scene reload.
- Android Debug APK workflow completed successfully on the `main` branch on 2026-11-17.
- The APK was exported and checked by the workflow; the artifact was downloaded and its ZIP archive was successfully extracted.

### Important limitations
- This is still an early prototype, not a complete game.
- The character is a procedural humanoid blockout with simple procedural movement animation, not a rigged or realistic final character. The car and environment also remain low-poly procedural blockout assets; imported production art and advanced animation are not yet included.
- Both adventure missions and the signal challenge use simple placeholder geometry and trigger zones; there is not yet dialogue, map GPS, an inventory, or a broader skill/level progression system. Mission XP and completion flags are saved locally.
- The time trial is a short prototype route inside the starter district, not a full race with AI opponents, laps, results history, or tournaments.
- Competition is currently a solo timed objective challenge. AI rivals, team play, capture/escort rounds, and online play are not implemented yet.
- Camera drag, world-boundary recovery, and the humanoid placeholder have automated coverage, but actual touch feel, physics handling, collision feel, screen layout, and Android performance still require physical-phone verification.
- The XP counter is a small persistent foundation; player levels, unlock trees, and spendable rewards are not implemented yet.
- The current APK is a debug build signed with a temporary CI key. It is for testing only, not public release distribution.

## Next milestones
1. Validate vehicle selection and the expanded route in Godot CI and export one consolidated Android debug APK.
2. Install and test on the target Android phone; measure frame rate, heat, touch response, and memory.
3. Test the new mission, park plaza, pause panel, and XP persistence on the target Android phone.
4. Add an optional settings panel and improve touch layout after device feedback.
5. Add optional ambient audio only after confirming performance on the target phone.
6. Replace procedural blockouts with properly licensed, optimised character/vehicle/environment art in measured stages.
7. Prepare permanent release signing only when the game is ready for a controlled release.

## Performance approach
Keep the Compatibility renderer, reuse materials, keep decorative props non-colliding, avoid expensive real-time lights, and profile on the target 4 GB Android device before increasing scene density. For larger districts, use visibility ranges/LOD and tile loading rather than drawing the whole world at full detail. Do not assume a target frame rate or memory use until tested on target hardware.

## Validation notes
- Godot gameplay validation run: https://github.com/newgenerationnetwork617-ops/one-man-squad/actions/runs/44127820598
- Main-branch Android Debug build run: https://github.com/newgenerationnetwork617-ops/one-man-squad/actions/runs/44129442931
- Main-branch artifact: `one-man-squad-android-debug`, approximately 57.1 MB ZIP, created 2026-11-17 and scheduled to expire 2026-11-24.
- A successful cloud export confirms that an APK was produced; it does not prove that it installs, runs smoothly, or has correct touch controls on a physical device.
