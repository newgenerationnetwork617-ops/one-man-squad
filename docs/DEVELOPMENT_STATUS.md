# One Man Squad — Development Status

## Current milestone: Stage 1 foundation rebuild

The Stage 1 rebuild is strengthening the game foundation before the larger open-world, survival, racing, and online phases. It adds a dedicated menu camera, responsive menu and pause layouts, main menu, garage vehicle selection, game-mode overview, settings and about screens, plus clearer separation between the menu and active gameplay. The starter district now has an intermediate stylised architectural pass: individually named storefront signs and entrances, canopies, balconies, rooftop utility housings, planters, pedestrian crossings, road markings, and a more detailed park landmark with fountain rim/jets, pergola, shrubs, bench backs, and path bollards. The character and vehicles remain procedural prototype assets rather than final production art.

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
- Dedicated menu camera and main menu with Play/Continue, Garage, Game Modes, Settings, and About screens; the world remains paused until the player chooses to enter.
- Responsive home, garage, game-mode, settings, about, and pause layouts use viewport-aware panel dimensions, flexible-width controls, and vertical scrolling for smaller screens.
- Intermediate district visual detail pass across eight buildings, including entrances, signage, canopies, balcony details, rooftop units, planters, and storefront displays.
- Added pedestrian crossing stripes, intersection stop lines, parking-bay markings, and park plaza details including fountain rim/jets, pergola, shrubs, bench backs, and path bollards.
- Garage menu allows selecting the two currently implemented vehicles. This is a selection foundation, not yet a full customisation or upgrade workshop.
- Game Modes screen identifies currently available Open World and Time Trial activities and clearly labels Survival Zone and Online Multiplayer as planned, not playable features.
- Dedicated on-foot Jump control and contextual Jump/Brake visibility; camera handoff between menu, player, and vehicle is explicit.
- Full-screen pause overlay with large touch-friendly Resume, Save Progress, Main Menu, and Restart Session actions. Menu controls use Always process mode so they remain interactive while the world is paused.
- Camera sensitivity setting saved locally and applied to both the on-foot and vehicle cameras.
- Visual polish pass: procedural sky, filmic tone mapping, distance fog, directional shadows, smoother rounded car silhouettes, and rounded character footwear.
- Offline-first structure with no backend or network dependency.
- Android Debug export preset and GitHub Actions workflow for ARMv7 and ARM64.

### Automated verification completed
- Godot 4.7.2 project import and main-scene smoke test passed in GitHub Actions.
- Responsive UI checks passed for portrait/landscape sizing calculations and the home, garage, and pause scroll layouts.
- Architectural-detail checks passed for the eight building entrances/signs/rooftop units, intersection crossings, fountain rim, pergola slats, and retained gameplay landmarks.
- Stage 1 visual/UI update merged to `main` in PR #18 (merge commit `930375228246c01613ccd8f7818d73d847712073`).
- Automated gameplay checks passed for home-screen startup, menu camera handoff, HUD visibility, garage vehicle selection, game-mode menu navigation, starting/continuing gameplay, pause overlay processing, resume, return to home, both vehicle variants, vehicle switching, mission pickup and delivery, both missions and XP persistence, twelve racing checkpoints, Competition completion, local save writing, and persistence after scene reload.
- Android Debug APK workflow completed successfully on the `main` branch on 2026-11-17.
- The APK was exported and checked by the workflow; the artifact was downloaded and its ZIP archive was successfully extracted.

### Important limitations
- This is still an early prototype, not a complete game.
- The character, vehicles, and environment are still procedural prototype assets. Rounded shapes, lighting, and materials improve the presentation, but this is not yet realistic production-quality art; imported licensed models, textures, and advanced animation are still future work.
- Both adventure missions and the signal challenge use simple placeholder geometry and trigger zones; there is not yet dialogue, map GPS, an inventory, or a broader skill/level progression system. Mission XP and completion flags are saved locally.
- The time trial is a short prototype route inside the starter district, not a full race with AI opponents, laps, results history, or tournaments.
- Competition is currently a solo timed objective challenge. AI rivals, team play, capture/escort rounds, and online play are not implemented yet.
- Camera drag, world-boundary recovery, and the humanoid placeholder have automated coverage, but actual touch feel, physics handling, collision feel, screen layout, and Android performance still require physical-phone verification.
- The XP counter is a small persistent foundation; player levels, unlock trees, and spendable rewards are not implemented yet.
- The current APK is a debug build signed with a temporary CI key. It is for testing only, not public release distribution.

## Next milestones
1. Complete Stage 1 foundation rebuild and verify responsive menus, camera transitions, touch controls, and existing gameplay in Godot CI.
2. Replace procedural placeholder art with properly licensed, optimised character, vehicle, and environment assets before claiming a realistic visual upgrade.
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
