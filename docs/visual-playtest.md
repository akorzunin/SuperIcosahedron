# Rendered lab playtests

Run from a Linux graphical session with Godot and GNU `timeout` installed:

```sh
task visual-playtest
# Without Task installed:
bash scripts/visual_playtest.sh
```

The command imports resources, then renders the existing RotationLab and RunLab
using their production scenes, controllers, and UI buttons. Each invocation prints
a fresh directory under `build/visual-playtest/run.*`; old evidence is never reused.
These development scenes are excluded from exports by the existing `dev/**` filter.

## Evidence to inspect

- `rotation_contact_sheet.png` and `run_contact_sheet.png`: six checkpoints each,
  ordered left-to-right, top-to-bottom.
- `rotation_*.png` and `run_*.png`: individual 1280×720 screenshots for closer inspection.
- `report.json`: automated checks, capture order/frame numbers, figure orientation,
  visibility, score, game state, and actual/project renderer names.
- `runtime.log`, `engine.log`, `import.log`: engine output, including errors.

| Checkpoint | RotationLab | RunLab |
| --- | --- | --- |
| 01 | Initial orientation | Initial active run |
| 02 | Holding right, midway | Brief rotation and growth |
| 03 | Right released | Game-over animation midway |
| 04 | Stopped, orientation unchanged | Settled game-over, fixture score 42 |
| 05 | Clicked Reset orientation | Clicked Restart run, score/progress zero |
| 06 | Reset stays stable | Active figure keeps growing, anchor stays reset |

**Open both contact sheets, then inspect individual frames where needed.** Verify
that rotation is visible, release stops movement, reset restores the initial
appearance, and restarting removes the game-over presentation without stale UI or
figures. Check clipping, missing meshes, unreadable text, and unexpected colors.
The RunLab panel currently overlaps the gameplay HUD; existing issues are not
implicitly approved baselines.

A zero exit code means the scripted checks passed and no runtime errors were logged.
It does **not** mean the visuals are correct. Record your visual observations and
evidence directory in the task's final report. For a visual change, run this before
and after editing and compare the two directories. No baselines are auto-approved.

## Scope and limitations

- Fixed seed, default in-memory settings, 60 FPS simulation, and fixed render size.
  User settings/saves are not loaded or written. Do not interact with the window
  during a replay; real input can interfere.
- RunLab failure and score are deliberately injected to exercise presentation and
  restart. This is not a collision/passage test or a complete gameplay replay.
- Six sparse captures per lab catch gross transitions, not every single-frame
  glitch. Use denser capture or video for animation investigations.
- Production HUD timers use wall-clock time; their text is not pixel-deterministic.
  GPU/driver/font differences can also affect pixels. This is review evidence, not
  an exact-image regression test. Compare using the same renderer and environment.
- The default command uses the project's renderer. Missing graphics support,
  automatic fallback errors, script errors, failed checks, missing reports, and
  a 120-second import or runtime timeout cause failure. Headless mode cannot pass.
- Existing editor-plugin shutdown leaks are retained in `import.log`; import is
  gated on exit status only. The rendered runtime is strictly error-gated.

For **explicit diagnostic testing** on a machine without working Vulkan:

```sh
task visual-playtest -- --rendering-method gl_compatibility
# Or:
bash scripts/visual_playtest.sh --rendering-method gl_compatibility
```

This is not validation of the default Mobile renderer. Check `renderer` against
`project_renderer` in `report.json`, and report the coverage limitation. A virtual
display with working graphics can also be used; `--headless` cannot capture evidence.
