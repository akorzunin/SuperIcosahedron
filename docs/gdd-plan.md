# SuperIcosahedron — Game Design Document

## 1. High concept

**SuperIcosahedron** is an indie arcade game made in Godot, inspired mostly by **Super Hexagon**.
The player navigates a stream of rotating icosahedrons by aligning the active spot/cut plane before the object reaches the end detector.

**Short pitch:** rotate the icosahedron, line up the highlighted face, survive longer, clear more nodes.

## 2. Design pillars

- **Fast arcade skill:** short sessions, quick restarts, score-chasing.
- **Minimalist 3D geometry:** icosahedrons, clean shaders, color-coded variants.
- **Readable pressure:** objects spawn, grow, and approach failure; the player must solve alignment quickly.
- **Simple controls:** directional input only, with two control modes.

## 3. Target platforms / tech

- Engine: **Godot 4**.
- Main scene: `game/app/Main.tscn`.
- Export targets already configured: **Windows**, **Web**, **Linux/X11**, **Android**.
- Landing page exists in `web/` using Astro/React/Tailwind.
- Optional desktop Discord Rich Presence; disabled on web/mobile.

## 4. Core gameplay loop

1. Game spawns an icosahedron node.
2. Player rotates the active icosahedron.
3. The node's cut-plane direction is checked against the end direction.
4. If aligned, the node is passed and score increases.
5. If badly aligned when reaching the end detector, game ends.
6. Player restarts or exits from the game-over menu.

## 5. Win / lose / scoring

- No fixed win condition yet; current mode is survival / score attack.
- Game over happens when the active collider reaches the end detector with a wrong angle.
- Score shown at game over:
  - nodes passed
  - elapsed time
- Debug currently logs time-to-solve per node.

## 6. Mechanics

### Alignment

- `ANGLE_GOOD`: pass immediately when angle is under `0.22` radians.
- `ANGLE_OK`: pass near the end when angle is under `0.5` radians.
- `ANGLE_WRONG`: triggers game over near the end.

### Spawning

- Nodes spawn on a timer.
- Spawn interval uses `100 / (SPAWN_SPEED * GAME_SPEED)`.
- Spawn modes:
  - tutorial
  - debug
  - pattern queue

### Scaling / pressure

- Spawned icosahedrons scale over time.
- Scaling is driven by `SCALE_FACTOR` and `GAME_SPEED`.
- A despawner removes old colliders.

## 7. Controls

Supported input from project settings:

- Move/rotate: arrows, WASD, gamepad d-pad / stick.
- Pause: `P` / gamepad back.
- Reload: `R`.
- Fullscreen toggle: `Alt+Enter`.
- Debug stats toggle: `Ctrl+Shift+N`.
- Mobile/web touch uses invisible screen buttons / touch accept handling.

Control modes:

- **FreeSpin:** continuous rotation while directional input is held.
- **FaceLock:** discrete face-to-face rotations with short tweened movement.
- Optional inverted X-axis.

## 8. Progression / levels

Current level system is pattern-based:

- Tutorial / level 0 uses fixed intro patterns.
- Level 1 introduces simple motion patterns.
- Level 2 introduces harder/more varied patterns.
- Level 3+ currently falls back to random variants.

Level-up thresholds:

- Level 0 → 1 after more than 10 nodes.
- Level 1 → 2 after more than 20 nodes.
- Level 2 → 3 after more than 40 nodes.

Menu level select uses unlocked max level from settings.

## 9. Game states / flow

States:

- Main menu
- Active game
- Paused game
- Game over

Scene flow:

- `MainScene` boots the app and loads `MenuScene`.
- Menu start loads `LoopScene`.
- Game over shows score, restart, exit, and game-over labels.

## 10. Menus and settings

Main menu entries:

- Start / level select
- Settings
- Achievements placeholder
- Exit
- Credits placeholder
- Easter egg item

Settings sections:

- Controls: control type, invert X-axis
- UI: FPS counter, debug stats
- Video: fullscreen/bordered, VSync
- Audio: music, SFX

## 11. Visual direction

- Minimalist 3D icosahedron focus.
- Rotating sky icosahedron in menu/game scenes.
- Light blue background color currently used by sky shaders.
- Icosahedron shaders include:
  - base color shader
  - cut-plane effect
  - outline
  - edge highlight
- Variant colors and cut-plane variants define different node types.

## 12. Audio

Current audio events:

- Main menu theme
- Section changed
- Section selected
- Action selected
- Node passed

Audio settings support independent music and SFX toggles.

## 13. Content currently missing / TBD

- Final game name spelling: repo uses `SuperIcosahedron`; docs sometimes imply plural.
- Exact player-facing story/theme, if any.
- Final win condition, if not endless survival.
- Achievement designs.
- Credits content.
- Level unlock/save rules beyond current `MAX_LEVEL` setting.
- Final mobile controls description and UX.
- Asset/source list for music, textures, fonts, and icons.

## 14. Recommended GDD sections to keep

Keep this GDD lean. These sections are enough for this project:

1. High concept
2. Design pillars
3. Core gameplay loop
4. Mechanics
5. Controls
6. Progression / levels
7. Game states / flow
8. UI / menus
9. Visual direction
10. Audio
11. Platforms / tech
12. Open questions / TBD
