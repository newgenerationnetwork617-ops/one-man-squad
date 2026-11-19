# Responsive Android UI pass

The main scene now uses a responsive menu controller layered over the existing gameplay foundation.

## Changes
- Menu panel width is derived from the active viewport and capped at 500 px.
- Menu panel height is derived from the viewport and capped at 620 px.
- Home, garage, game-mode, settings, and about screens share a vertically scrollable content area.
- Menu buttons use the available panel width rather than a fixed 380 px minimum.
- Pause controls use the same viewport-aware sizing and scrolling approach.
- The gameplay controller and existing mission/vehicle systems remain inherited from the original main script.

## Verification
A dedicated `tests/responsive_ui_test.gd` checks the responsive panel, scroll container, flexible button widths, garage layout, and pause layout. The Godot validation workflow runs this test after the existing gameplay/save tests.

## Remaining device checks
Automated layout checks do not replace installation and interaction on a physical Android phone. Confirm the app's landscape/portrait behavior, safe areas, touch target size, scrolling, and camera controls on the target device before marking the visual foundation complete.
