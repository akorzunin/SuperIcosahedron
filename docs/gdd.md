# SuperIcosahedron — Game Design Document

## 1. High concept

**SuperIcosahedron** is an indie arcade game made in Godot, inspired mostly by **Super Hexagon**.
The player navigates a stream of rotating icosahedrons by aligning the active spot/cut plane before the object reaches the end detector.


**Short pitch:** Assemble unique icosahedrons by rotating them and clllecting different modifiers

## 2. Design pillars

- **Fast arcade gameplay:** Mid long sessions (15-25min) divided by short stages(0.5-1.5min), quick restarts, score-chasing, reward rolling/balancing.
- **Minimalist 3D geometry w/ expressive vfx:** icosahedrons, clean geometry w/ expressive shaders, web optimized color palette.
- **Readable pressure:** objects spawn, grow, and approach failure; the player must solve alignment decisions quickly.
- **Simple controls:** directional input only, with two control modes.
- **Reward collection:** unique icosahedrons from modifiers save for user profile
## 3. Target platforms / tech

- Engine: **Godot 4**.
- Main scene: `src/scenes/MainScene.tscn`.
- Targets priority:
    - **Web**
    - **Android**
    - **Linux/X11**
    - **Windows**
- Landing page exists in `web/` using Astro/React/Tailwind.
- Optional desktop Discord Rich Presence; disabled on web/mobile.


## 4. Core gameplay loop

0. Game spawns an icosahedron node.
- Stage 1 of 20 starts (each stage represents each side of final icosahedron).
0. Player rotates the active icosahedron to select a pass side.
0. Passing through side give effects(positive/negative/solid).
0. If positive side is passed > score increases + adds side to modifiers.
0. If negative side is passed > score decreases + adds side to modifiers.
0. Collision with solid side ends game. (final icosahedron destroyed
    0. Player restarts or exits from the game-over menu.
- To pass stage player need to collect sides w/ edge modifiers
0. If all sides are collected, player wins and get final icosahedron w/ its score to collection


## 5. Win / lose / scoring

- Win condition: all sides are collected.
- Lose condition: player collides with solid side.
- Score is based on quality of collected sides and score(number) collected during gameplay.

## 6. Mechanics

### Alignment

- modifiers can be picked by aligning sides of the icosahedron.
- harder to align sides have more valuable modifiers.
- player cannot see all modifiers at once (only front half at best)

### Spawning

- Nodes spawn on a timer.or if all nodes resolved then new figure can spawn ahead of time w/ timre reset
- Spawn interval depends on `SPAWN_INTERVAL` and `GAME_SPEED`
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
- Pause: `P` / gamepad back - only halts game timer, no progress can be lost
- Reload: `R` - destroys current progress
- Fullscreen toggle: `Alt+Enter`.
- Debug stats toggle: `Ctrl+Shift+N`.
- Mobile/web touch uses invisible screen buttons / touch accept handling.

Control modes:

- **FreeSpin:** continuous rotation while directional input is held.
- **FaceLock:** discrete face-to-face rotations with short tweened movement.
- Optional inverted X-axis.
NOTE: both modes should not affect how fast player can reach sides
that means max speed of traversing from one side to another should be the same for both methods

## 8. Progression

- player have to pass 20 stages
- on each stage set of modifiers can be collected
- only 3 edge modifiers required to pass stage (they have to provide a lot of value so players dont wanna skip them)

### Modifiers
- have custom effects
- quality: noraml, rare, legendary
- different duration: stage, game, timer
- only one modifier can be on side
- ...

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

OST for game loop: ...

