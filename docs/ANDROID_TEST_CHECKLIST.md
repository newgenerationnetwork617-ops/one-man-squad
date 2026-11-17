# Validation and Device Test Checklist

## Automated validation
A GitHub Actions workflow is configured to check the project whenever code is pushed to main, when a pull request is opened, or when the workflow is manually started.

It installs the pinned Godot 4.7.2 standard (non-.NET) editor, imports the project headlessly, and briefly launches the main scene. This is an automated project smoke test; it does not replace testing on a physical Android phone.

## Manual Android test still required
When an installable Android build is available, test on the intended 4 GB RAM phone:

- [ ] App opens without a black screen or crash.
- [ ] Main menu fits the screen in landscape orientation.
- [ ] Left-side touch movement buttons respond and release correctly.
- [ ] Swiping on the right side rotates the camera.
- [ ] Movement follows the direction the camera faces.
- [ ] Player cannot fall through the ground or pass through building collision.
- [ ] Camera follows the player smoothly.
- [ ] Adventure, Competition, and Racing menu entries respond.
- [ ] App can be closed and reopened without losing the test session unexpectedly.
- [ ] Record average performance, memory use, device model, Android version, and any errors.

## Current boundary
No Android APK is being declared ready in this milestone. Android export needs a valid Android export preset, signing configuration where applicable, and a successful build. Device performance must be measured on real hardware.
