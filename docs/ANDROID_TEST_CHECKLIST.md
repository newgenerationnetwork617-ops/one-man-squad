# Validation and Device Test Checklist

## Automated validation completed
- [x] Godot 4.7.2 project import and main-scene smoke test passed in GitHub Actions.
- [x] Automated gameplay checks passed for player and vehicle spawning.
- [x] Mission pickup and delivery completion passed.
- [x] Four racing checkpoints were created and tested.
- [x] Competition completion and local save writing passed.
- [x] Saved mission and Competition progress persisted after scene reload.
- [x] Android Debug APK exported successfully from the `main` branch.
- [x] APK artifact ZIP downloaded and extracted successfully.

## Manual Android test still required
Install the current debug APK on the intended 4 GB RAM phone and test:

- [ ] App installs and opens without a black screen or crash.
- [ ] Main screen fits the phone in landscape orientation; no important controls are clipped.
- [ ] Left-side touch movement buttons respond and release correctly.
- [ ] Swiping on the right side rotates the on-foot camera.
- [ ] Movement follows the direction the camera faces.
- [ ] Player cannot fall through the ground or pass through building collision.
- [ ] Blue starter car appears in the district.
- [ ] Player can enter the car when nearby and exit safely.
- [ ] Vehicle accelerates, reverses, and steers using the touch controls.
- [ ] Dedicated brake button slows the vehicle smoothly.
- [ ] Speed readout updates while driving.
- [ ] Vehicle camera follows the car and can be rotated by swiping.
- [ ] Vehicle and player collide correctly with the ground and buildings.
- [ ] Supply crate pickup marker is visible near the starting area.
- [ ] Entering the pickup marker updates the objective to delivery.
- [ ] Green delivery marker appears only after collecting the crate.
- [ ] Reaching the green marker completes the mission once.
- [ ] Racing can be started while inside the vehicle.
- [ ] Four checkpoints activate in order; crossing the final checkpoint ends the time trial.
- [ ] Competition can be started while on foot.
- [ ] Three signal markers appear and must be collected in order.
- [ ] Competition timer counts down and ends the round.
- [ ] Collecting all three signals completes the round.
- [ ] Completing the delivery mission is reflected in the local progress summary.
- [ ] A completed time trial updates the saved personal-best time when faster.
- [ ] Competition round completion count is saved.
- [ ] Close and reopen the app; saved progress and records remain available.
- [ ] Adventure, Competition, and Racing menu entries respond.
- [ ] Record device model, Android version, observed performance, and any errors.

## Current boundary
The cloud build and automated tests have passed. Physical-device installation, touch interaction, gameplay feel, and performance are still unverified. The APK is a temporary debug build and must not be treated as a public release package.
