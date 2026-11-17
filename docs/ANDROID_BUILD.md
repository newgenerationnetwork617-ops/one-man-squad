# Android Debug Build

## Current build target

- Godot: 4.7.2
- Android package: `com.newgenerationnetwork.onemansquad` (development identifier; confirm before a public release)
- App label: One Man Squad
- Version: 0.1.0 (version code 1)
- Architectures: ARMv7 and ARM64
- Renderer: Compatibility / OpenGL
- Signing: temporary CI debug key only
- Network permission: disabled for this offline-first prototype

This is a development APK, not a release-signed store package. The temporary debug key is generated inside GitHub Actions and is never committed to the repository. A permanent release signing key must be created and securely backed up before any public release.

## Getting a test APK

After the Android Debug APK workflow succeeds:

1. Open the repository's **Actions** page.
2. Open the latest **Android Debug APK** run.
3. Find the **Artifacts** section and download `one-man-squad-android-debug`.
4. Extract the ZIP and install the APK on the Android test phone.

GitHub keeps this test artifact for seven days. A successful cloud export confirms that an APK was produced; it does not replace installation, touch-control, gameplay, or performance testing on a real phone.

## Build environment

The workflow installs OpenJDK 17, Android SDK Platform 35, Build Tools 35.0.1, Platform Tools, NDK r28b, CMake 3.10.2.4988404, and the Godot 4.7.2 Android export templates.

See the [Godot 4.7 Android export guide](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html) for the platform requirements.
