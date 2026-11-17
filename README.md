# One Man Squad

A 3D Android game featuring open-world adventure, competitive challenges and racing, built with Godot 4.

## Project direction
One integrated, offline-first Android game with three activities in its first release:
- **Adventure:** explore a compact city and countryside starter region, meet characters, and complete missions.
- **Competition:** take part in objective-based solo and team challenges against AI opponents.
- **Racing:** drive a range of vehicles in AI races, time trials, and off-road challenges.

## Technology
- Godot 4
- GDScript
- Android-first
- Compatibility renderer as the initial low-end device baseline
- Offline core gameplay; optional online systems are planned for a later stage

## Current status
The repository contains the first project foundation: a greybox 3D test district, placeholder third-person character movement, touch direction controls, and the three activity entry points.

This is an early prototype scaffold, not a finished or device-tested game. See [Development Status](docs/DEVELOPMENT_STATUS.md) for the milestone details.

## Development principles
- Build and test in small milestones.
- Keep the initial game space compact and optimise for Android devices with 4 GB RAM.
- Use original or properly licensed assets.
- Measure performance and package size on real devices before making release promises.
