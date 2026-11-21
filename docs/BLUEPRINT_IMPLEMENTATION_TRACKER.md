# Blueprint implementation tracker

This document is the delivery checklist for the approved One Man Squad blueprint. A feature is only marked **implemented** when working code exists and an automated or device test verifies it. **Foundation** means the supporting architecture exists, not that the complete player-facing feature is finished.

## First-release target

- Android-first, Godot 4 / GDScript, offline-first.
- Low-end optimisation target: Android devices with 4 GB RAM.
- All three activities remain in the first-release scope: Adventure, Competition and Racing.
- Online multiplayer, friends, matchmaking and cloud sync are later additions, not dependencies for core gameplay.

## Implementation tracker

| Area | Blueprint requirement | Current status |
|---|---|---|
| Project foundation | Godot project, Android export, GL Compatibility baseline | Implemented; CI export verified |
| Startup and menus | Home menu first, pause/resume, activity selection | Implemented; automated startup regression test |
| Connected world | Starter city and connected countryside blockout | Foundation; countryside extension merged, not final art |
| 3D environment | Detailed city/country terrain, buildings, interiors, lighting and weather visuals | In progress; procedural blockout only |
| World simulation | Day/night and weather state controller | Foundation; code and automated state tests |
| Character | Player movement and camera | Prototype |
| Character identity | Name, face, hair, skin tone, clothing, shoes, accessories, saved outfits and profile showcase | Not complete |
| Character animation | Walk/run, gestures, expressions and voice options | Prototype movement animation only |
| Vehicles | Starter sedan and sports-car prototypes, driving controller | Prototype |
| Vehicle garage | Eight initial vehicle categories, colours, wheels, stats and saved preferences | Not complete |
| Adventure | Mission 01 delivery and Mission 02 caches | Prototype missions |
| Adventure expansion | NPC citizens, mission characters, dialogue, shops, collectibles, discovery and navigation | Not complete |
| Competition | Offline timed objective collection | Prototype; no complete AI team modes |
| Competition expansion | Solo/team 2/3/4, team-v-team objectives, escort and protection | Not complete |
| Racing | Offline time trial with checkpoints | Prototype; no full AI race modes |
| Racing expansion | Quick Race, AI opponents, off-road events, tournaments and 8-car roster | Not complete |
| Home | Starter home concept | Not complete |
| Home upgrades | Interior rooms, wardrobe, trophy room, garage and four upgrade tiers | Not complete |
| Progression | XP, ranks, earned gold/tokens and unlock thresholds | Foundation; integration with all gameplay rewards remains |
| Local save | Three profile slots, backup recovery and profile metadata | Foundation; automated tests |
| Audio | Contextual music, environment, voice and vehicle audio controls | Not complete |
| Navigation | Minimap, full map, GPS, compass, markers and filters | Not complete |
| Settings | Graphics, FPS, audio, camera, touch layout, subtitles, brightness and storage | Partial |
| Online expansion | Friends, multiplayer, matchmaking, leaderboards and cloud sync | Deferred until offline release is stable |
| Performance | Memory, frame rate, loading and thermal checks on 4 GB Android hardware | CI only so far; physical-device testing required |
| Release | Offline/save/crash checks, APK size and release signing | Debug APK export verified; release validation pending |

## Delivery stages

1. **Core foundation:** multi-slot local profiles, backup/recovery, progression rules, world clock/weather state and data-driven catalogs.
2. **Player and garage:** character identity/customisation, animation upgrade, vehicle catalog, garage preferences and driving controls.
3. **Adventure:** connected region expansion, NPC interaction, dialogue, mission registry, collectibles and navigation.
4. **Racing:** vehicle roster, AI opponents, race modes, off-road route and results/progression.
5. **Competition:** AI opponents and team-size/objective variants, offline scoring and rewards.
6. **Home and identity:** home interior, wardrobe, trophy room, upgrades and profile showcase.
7. **Audio, settings and integration:** contextual audio, accessibility, touch layout, quality settings and activity integration.
8. **Optimisation and release:** profile/save migration, recovery, performance profiling, low-memory tests, APK and device acceptance.

## Release gate

Do not call the blueprint complete until each first-release item above is implemented, regression-tested, exported, installed and checked on a physical Android device. Online expansion is explicitly outside the offline-first release gate.
