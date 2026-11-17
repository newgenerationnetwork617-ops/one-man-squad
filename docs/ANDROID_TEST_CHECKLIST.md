# Validation and Device Test Checklist

## Automated validation
A GitHub Actions workflow is configured to check the project on pushes to main, pull requests, and manual dispatch. It imports the project with Godot headlessly and briefly launches the main scene. This does not replace testing on a physical Android phone.

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
- [ ] Vehicle camera follows the car and can be rotated by swiping.
- [ ] Vehicle and player collide correctly with the ground and buildings.
- [ ] Supply crate pickup marker is visible near the starting area.
- [ ] Entering the pickup marker updates the objective to delivery.
- [ ] Green delivery marker appears only after collecting the crate.
- [ ] Reaching the green marker completes the mission once.
- [ ] Adventure, Competition, and Racing menu entries respond.
- [ ] Record performance, memory use, device model, Android version, and any errors.

## Current boundary
No Android APK is being declared ready in this milestone. Android export needs a valid export preset, signing configuration where applicable, and a successful build. Device performance must be measured on real hardware.
