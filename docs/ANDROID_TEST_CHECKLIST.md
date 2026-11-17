# Validation and Device Test Checklist

## Automated validation
A GitHub Actions workflow imports the project, launches the main scene, and runs gameplay/save-state checks. A separate Android Debug APK workflow is being added to produce a downloadable test package. Neither workflow replaces testing on a physical Android phone.

## Manual Android test still required
When an installable Android build is available, test on the intended 4 GB RAM phone:

- [ ] App opens without a black screen or crash.
- [ ] Main menu fits the screen in landscape orientation.
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
- [ ] Competition can be started while on foot.
- [ ] Three signal markers appear and must be collected in order.
- [ ] Competition timer counts down and ends the round.
- [ ] Collecting all three signals completes the round.
- [ ] Completing the delivery mission is reflected in the local progress summary.
- [ ] A completed time trial updates the saved personal-best time when faster.
- [ ] Competition round completion count is saved.
- [ ] Close and reopen the app; saved progress and records remain available.
- [ ] Four checkpoints activate in order and update the time-trial timer.
- [ ] Crossing the final checkpoint ends the time trial and displays the result.
- [ ] Adventure, Competition, and Racing menu entries respond.
- [ ] Record performance, memory use, device model, Android version, and any errors.

## Current boundary
The Android export preset and cloud build workflow are now part of the project. The APK is not considered ready until the export workflow succeeds and the package is installed and checked on the intended phone. Device performance must be measured on real hardware.
