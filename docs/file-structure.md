# Feature folders

`assets/` holds asset sources and large raw files, synced through the existing
cloud tooling. It is ignored by Godot. Runtime copies belong in `game/`:
scene-specific assets beside their feature, shared assets in `game/game-assets/`.
Import settings under `game/` are versioned so fonts/audio/textures import consistently.

## Current structure

```text
game/
  app/
    Main.tscn + Main.gd             # application entry point
    AppState.gd
    globals.gd                     # transitional settings/global signals
    version.gd
  gameplay/
    Gameplay.tscn + Gameplay.gd     # independently runnable production loop
    RunState.gd                    # scene-independent score/collection/outcome
    GameProgress.gd                # scene adapter: rules → lifecycle + HUD
    GameStateManager.gd            # active / paused / ended within a run
    figure/
      Icosahedron.tscn + Icosahedron.gd
      MeshIcosahedron.gd
      FigureData.gd + SideData.gd
      Collider.gd + SideCollider.gd
      assets/ + shaders/ + dent/
    controls/
      FigureController.gd          # explicit target and rotation commands
      PlayerInput.gd               # input actions → controller commands
      FreeSpin.gd + FaceLock.gd     # rotation mechanics
      LoopControls.gd              # target selection and run input requests
    level/
      StageGenerator.gd
      PatternGen.gd + LevelPatterns.gd + LevelQueue.gd
      LoopSpawner.gd + FigureRoot.gd + Anchor.gd
      LoopTimer.gd + ScaleTimer.gd
      Despawner.gd + EndDetector.gd # legacy detector, pending collider rewrite
      shaders/
    modifiers/
      ModifierData.gd + ModifierSystem.gd + EcsWorld.gd
  menu/
    Menu.tscn + Menu.gd
    MenuControls.gd + MenuSpawner.gd
    MenuState.gd + MenuActions.gd + MenuSelector.gd + MenuStruct.gd
    MenuGui.gd
    item/                          # MenuItem scene and scripts
    assets/ + shaders/
  ui/                              # HUD, debug labels, shared buttons
    assets/
  services/
    settings/
    audio/                         # player, presets, audio assets
    discord/
  game-assets/
    fonts/ + icons/ + themes/ + colors/ + sky/ + shaders/ + resources/
  shared/                          # existing Quats, Utils, Op helpers

dev/labs/
  rotation/RotationLab.tscn + RotationLab.gd
  run/RunLab.tscn + RunLab.gd

test/
  unit/                            # rule and controller assertions
  integration/                     # labs and main-menu flow
```

Existing script class names and internal scene node names are retained where
possible to avoid mixing a naming rewrite into the resource moves. In particular,
`Gameplay.gd` currently retains the `LoopScene` class name.

## Reuse boundaries

```text
Main → Gameplay → level / figure / controls / RunState
RunLab → the SAME Gameplay.tscn
RotationLab → the SAME Icosahedron.tscn + FigureController + PlayerInput
```

- Labs create scenarios, edit parameters, and show observations. They do not
  implement mechanics or copy production scenes.
- `FigureController` receives an explicit target, speed, mode, and inversion.
  Its commands are callable without synthesizing keyboard events.
- `PlayerInput` translates actions to commands. Focused GUI fields suppress
  rotation input. RotationLab and gameplay use this same script.
- `RunState` handles score, collection, duplicate resolution, and game-over rules
  without scene nodes or application services. Use fresh FigureData/SideData for
  a new run; never treat a mutated shared Resource as a reusable fixture.
- `Gameplay` owns restart and forwards menu, sound, and presence events. `Main`
  connects these to application services; RunLab needs no MainScene or Discord stub.
- Restart clears figures, run state, pattern queue, game-over animation and anchor
  transform, resets timers through state transitions, and spawns one figure.
- Scene-local `$Child` / `%Child` references are fine. New reusable mechanics must
  not reach into `/root/MainScene` or know about lab scripts.

## Labs

### RunLab

Run `task lab-run`, or F6 on `dev/labs/run/RunLab.tscn`.
It starts production gameplay immediately, provides restart and pause/resume,
and intercepts requests to return to the menu. It uses the existing gameplay
settings service, but does not initialize window/fullscreen/audio/Discord services.

**Collision behavior is not validated:** EndDetector is the existing nearest-face
heuristic. Replace it with the planned proper collider in the next mechanics pass.
Do not use successful launch or the menu-flow test as evidence it works.

### RotationLab

Run `task lab-rotation`, or F6 on `dev/labs/rotation/RotationLab.tscn`.
Arrow keys rotate a non-growing production figure. The panel selects free-spin
or face-lock, changes free-spin speed, inverts horizontal input, resets the figure,
and displays its quaternion. It does not seed or read `G.settings` for controls.

### Automated tests

`task test` runs unit and integration tests. These cover controller commands,
run rules, both labs without the app, restart from active/paused/ended states, and
existing menu/settings flow. The menu test restores the settings file it touches;
for extra isolation in local/CI runs, use a temporary `XDG_DATA_HOME` on Linux.

Exports already exclude `dev/**`, `test/**`, and `docs/**`.

## Deliberately unfinished rewrite work

This is a runnable restructuring foundation, not a claim that every legacy
subsystem has been rewritten:

- Replace EndDetector and remove the legacy side-collider fallback when the new
  collider is verified. Add actual physics-contact integration assertions then.
- Growth and level timing still use existing timers and global settings. An
  explicit `advance(delta)` is the upgrade path if manual stepping is needed.
- GameProgress remains the scene/HUD adapter; FigureRoot still updates a debug
  counter, and LoopSpawner still builds 3D menu items for game over.
- The main menu retains legacy service lookups and global signals. Gameplay's
  sound/Discord/navigation dependencies no longer require the main application.
- The small existing modifier ECS is retained, not expanded. Do not introduce
  additional infrastructure until a concrete modifier needs it.
- AppState and GameStateManager remain separate app/run state scopes. Moving files
  does not require replacing the menu's scene-switching presentation yet.
