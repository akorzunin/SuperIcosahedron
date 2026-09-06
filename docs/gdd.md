# SuperIcosahedron — Game Design Document

## 1. High concept

**SuperIcosahedron** is an indie arcade game made in Godot, inspired mostly by **Super Hexagon**.
The player navigates a stream of rotating icosahedrons by aligning camera towards faces, optioanally timing button press to beat.

## 2. Design pillars

- **Fast arcade gameplay:** Mid long sessions (15-25min) divided by short stages(0.5-1.5min), quick restarts, score-chasing, reward rolling/balancing.
- **Minimalist 3D geometry w/ expressive vfx:** icosahedrons, clean geometry w/ expressive shaders, web optimized color palette.
- **Readable pressure:** objects spawn, grow, and approach failure; the player must solve alignment decisions quickly.
- **Simple controls:** directional input only, with two control modes.
- **Reward collection:** unique icosahedrons from modifiers save for user profile

## 3. Target platforms / tech

- Engine: **Godot 4**.
- Main scene: `game/app/Main.tscn`.
- Targets priority:
  - **Web**
  - **Android**
  - **Linux/X11**
  - **Windows**
- Landing page exists in `web/` using Astro/React/Tailwind.
- Optional desktop Discord Rich Presence; disabled on web/mobile.

## Main game objects

- node - icosahedron node, active node controlled by player
  - dent - face of icosahedron and volume that belongs to it, have collisions, modifier state and etc
    - face or side - side of icosahedron
    - modifier - edge modifier, can appear on any face of icosahedron, can be picked up by player
    - collider - volume that above face to detect if player press beat button in time
- spawner - creates nodes on timer
- camera - shows spawner and node that comes from it, have a collider that detects how close player to node
- environment - skybox-like icosahedron that rotates and can be contolled to show environmental effects
- beat-counter - counts BPM of music and controls how close player to beat, contols how often nodes spawn

## 4. Core gameplay loop

0. Game spawns an icosahedron node.
1. Player rotates the active icosahedron to select a pass face.
2. Optionally timing button press to beat that gives score benefits.
2. Passing through side give effects(depends on modifier).

- To pass stage player need to collect sides w/ edge modifiers

0. If all sides are collected, player wins and get final icosahedron w/ its score to collection

## 5. Win / lose / scoring

- Win condition: all sides are collected.
- Lose condition: player lost all score and collides with solid side or special modifier effects lead to game over.

## 6. Mechanics

### Beat button

- Player can press beat button to pass node early. Timinig should be closer to beat.
- beat time is saved to dent state and can affect on score and modifiers
- `BEAT_TIME` value based on press beat window.

### Alignment

- modifiers can be picked by aligning sides of the icosahedron.
- harder to align sides have more valuable modifiers.
- player cannot see all modifiers at once (only front half at best)

### Spawning

- Nodes spawn on a timer or if all nodes resolved then new figure can spawn ahead of time w/ timre reset and on beat.
- Spawn interval depends on `SPAWN_INTERVAL` and beat-counter
- Spawn modes:
  - tutorial (altered spawn speed makes it easier to learn)
  - main
  - debug (spawn pre-defined icosahedrons)

### Scaling / pressure

- There is only two ways to increase pressure: `GAME_SPEED`
  - increased node Scaling `SCALE_SPEED`
  - reduced spawn interval `SPAWN_INTERVAL`
- Another way to increase difficulty is to reach sides furter away but its up to player

## 7. Controls

Supported input from project settings:

- Move/rotate: arrows, WASD, gamepad d-pad / stick.
- `Space/Enter` - beat button
- Pause: `P` / gamepad back - only halts game timer, no progress can be lost
- Reload: `R` - destroys current progress
- Fullscreen toggle: `Alt+Enter`.
- Debug stats toggle: `Ctrl+Shift+N`.
- Mobile/web touch uses screen buttons.

Control modes:

- **FreeSpin:** continuous rotation while directional input is held.
- **FaceLock:** discrete face-to-face rotations with short tweened movement.
- Optional inverted X-axis.
  NOTE: both modes should not affect how fast player can reach sides
  that means max speed of traversing from one side to another should be the same for both methods

## 8. Progression

- player have to pass 20 stages
- on each stage set of modifiers can be collected
- only 3 edge modifiers required to pass stage (they have to provide a lot of value so its really hord to get them), first and second edge modifiers apeared on edges of first face of next node that closer to player

### Modifiers

- [modifiers](./modifiers.md)

## 9. Game states / flow

States:

- Main menu
- Active game
- Paused game
- Game over

## 10. Menus and settings

Main menu entries:

- Start / level select
- View assembled icosahedrons
- View occured modifiers
- Settings
- Exit
- Easter egg item

Settings sections:

- Controls: control type, invert X-axis
- UI: FPS counter, debug stats
- Video: fullscreen/bordered, VSync
- Audio: music, SFX

## 11. Visual direction

- Minimalist 3D
- Expressive vfx: particles, texture effects, shaders.
- Rotating sky icosahedron in menu/game scenes.

## 12. Audio

Current audio events:

Menu:

- Main menu theme
- Section changed
- Section selected
- Action selected

Game:

- Node passed
- Modifier collected
- Stage passed
- Icosahedron completed

OST for game loop - formed dynamically from picking up modifiers
