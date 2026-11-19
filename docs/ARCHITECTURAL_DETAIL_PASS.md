# Starter district architectural detail pass

This pass adds a consistent visual layer to the existing greybox district without changing its road layout, mission triggers, vehicle physics, or collision boundaries.

## Added details
- Eight named storefront/building signs with distinct accent colours.
- Defined entrance doors with inset glass panels.
- Entrance canopies and slim supports.
- Repeated balcony slabs and rails on taller buildings.
- Rooftop utility housings.
- Street planters and display-window details.

The additions use simple low-cost meshes and Label3D signs. They are an intermediate stylised art pass, not imported photorealistic assets. The project still needs properly licensed character, vehicle, and environment models, textures, animation, and device profiling.

## Automated checks
`tests/architectural_detail_test.gd` checks that all eight building entrances, signs, and rooftop details are present and that the original ground, park plaza, and responsive home menu remain in the scene.

## Android verification still required
Headless Godot tests cannot verify how the materials, signs, and menu look on the user's physical phone. Check readability, visual scale, touch layout, frame pacing, heat, and memory use on the target device before considering this visual milestone complete.
