# One Man Squad — Development Status

## Current milestone: Character, vehicle, and starter-district expansion

The next visual/gameplay expansion adds a more readable humanoid player blockout with face and hair details plus procedural walk-cycle motion; a more detailed starter car with bumpers, grille, lamps, roof, darker tires, and animated wheels; and a more lived-in starter district with road markings, sidewalks, facade windows, trees, and streetlights. All assets remain low-cost procedural placeholders designed for the initial Android compatibility renderer.

The first playable prototype now builds successfully as an Android debug APK from the `main` branch. Automated Godot gameplay and save-state checks also pass. The next quality gate is installation and hands-on testing on the target Android phone.

### Included
- Godot 4 project using the Compatibility renderer as the initial low-end Android baseline.
- Expanded greybox district with a larger ground plane, connected road branches, building collision, perimeter barriers, road markings, sidewalks, facade windows, trees, and streetlights.
- Third-person on-foot player with camera-relative movement, right-side touch camera look, face/hair details, and lightweight procedural walk animation.
- Low-cost starter car with metallic body finish, cabin/roof, front and rear bumpers, grille, headlamps, tail lamps, tire materials, animated wheels, collision, and chase camera.
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
- The character is a procedural humanoid blockout with simple procedural movement animation, not a rigged or realistic final character. The car and environment also remain low-poly procedural blockout assets; imported production art and advanced animation are not yet included.
- The delivery mission and signal challenge use simple placeholder geometry and trigger zones; neither has dialogue, map GPS, or a reward inventory yet.
- The time trial is a short prototype route inside the starter district, not a full race with AI opponents, laps, results history, or tournaments.
- Competition is currently a solo timed objective challenge. AI rivals, team play, capture/escort rounds, and online play are not implemented yet.
- Camera drag, world-boundary recovery, and the humanoid placeholder have automated coverage, but actual touch feel, physics handling, collision feel, screen layout, and Android performance still require physical-phone verification.
- The displayed 100 XP is a prototype mission message, not yet connected to a persistent progression system.
- The current APK is a debug build signed with a temporary CI key. It is for testing only, not public release distribution.

## Next milestones
1. Validate the character, vehicle, and streetscape expansion in Godot CI and export a fresh Android debug APK.
2. Install and test on the target Android phone; measure frame rate, heat, and memory before adding more world geometry.
3. Add a second playable vehicle and tune arcade handling using device feedback.
4. Add more offline mission variety and a longer racing route.
5. Add simple pedestrian traffic and non-combat ambient activity only if performance allows.
6. Replace procedural blockouts with properly licensed, optimised character/vehicle/environment art in measured stages.
7. Prepare permanent release signing only when the game is ready for a controlled release.

## Performance approach
Keep the Compatibility renderer, reuse materials, keep decorative props non-colliding, avoid expensive real-time lights, and profile on the target 4 GB Android device before increasing scene density. For larger districts, use visibility ranges/LOD and tile loading rather than drawing the whole world at full detail. Do not assume a target frame rate or memory use until tested on target hardware.

## Validation notes
- Godot gameplay validation run: https://github.com/newgenerationnetwork617-ops/one-man-squad/actions/runs/44127820598
- Main-branch Android Debug build run: https://github.com/newgenerationnetwork617-ops/one-man-squad/actions/runs/44129442931
- Main-branch artifact: `one-man-squad-android-debug`, approximately 57.1 MB ZIP, created 2026-11-17 and scheduled to expire 2026-11-24.
- A successful cloud export confirms that an APK was produced; it does not prove that it installs, runs smoothly, or has correct touch controls on a physical device.
