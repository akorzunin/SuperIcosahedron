# Rendered lab playtests

Run from a Linux graphical session with Godot and GNU `timeout` installed:

```sh
task visual-playtest
# Without Task installed:
bash scripts/visual_playtest.sh
```

The command imports resources, then renders RotationLab, RunLab, and a mounted
MainScene menu-to-gameplay replay using production scenes, controllers, and input. Each invocation prints
a fresh directory under `build/visual-playtest/run.*`; old evidence is never reused.
These development scenes are excluded from exports by the existing `dev/**` filter.

## Evidence to inspect

- `{rotation,run,mounted,fade,options,collision}_contact_sheet.png`: six checkpoints each,
  ordered left-to-right, top-to-bottom.
- `{rotation,run,mounted,fade,options,collision}_*.png`: individual 1280×720 screenshots
  for closer inspection.
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

The mounted replay captures menu, approaching empty dent, scored passage,
approaching solid dent, physical game over, and return to menu. It starts through
menu accept input, then aligns faces and steps scale to exercise real collisions.
It checks viewport camera ownership as well as passage and game-over state.
Audio streams and window-settings initialization are disabled for this replay.

The fade replay commits an aligned shell with accept input, captures four stages
of its fade, checks that its hidden collider remains unresolved, then grows it into
physical passage. The options replay captures the score, mid-rotation toward
Restart, restarted run, score again, mid-rotation toward Exit, and returned menu.
Options activate only after their 0.3-second turn, following the entry cooldown.

**Open all six contact sheets, then inspect individual frames where needed.** Verify
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
- The mounted replay uses controlled orientations/scale steps, not natural growth
  timing or player steering. Its stopped loop timer displays zero elapsed time.
- Six sparse captures per scenario catch gross transitions, not every single-frame
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

## Collision diagnosis

```sh
# Interactive production gameplay in the development lab:
godot --path . res://dev/labs/run/RunLab.tscn
# Normal mounted game, built-in collision visualization plus contact logs:
godot --path . --debug-collisions -- --collision-debug
# Physics regression tests and rendered evidence:
task test
task visual-playtest
```

In RunLab enable **Colliders** for red solid sectors, green passage sectors, and
a magenta circular player-window outline. This also enables `COLLISION` console records with
physics tick, figure instance/stage, all overlapping side IDs, selected side,
empty/solid classification, scale, and visibility before resolution. Use **Side
camera** to see the player window from outside; it changes only the camera, not the
collision target or steering axes. Pause/resume and restart remain available.

The detector is a **camera-aligned 32-sided circular prism**, radius 0.2 and
thickness 0.02, centered one unit in front of the gameplay camera. The former
world-aligned 4×4×4 box is removed. The tiny red spawn marker is not the hit window.
Each side collider is a tetrahedral sector from the figure center to its face;
green sectors are scoring triggers, not physical walls. The actual physics
resources supply the debug outlines, including hidden committed shells. Depth
occlusion is intentionally disabled, so rear/interior edges show through and
shared red/green edges can overlap. The player outline omits cap triangulation
spokes. The built-in debug view also shows cleanup/presentation shapes; the lab
filters those out. Neither view depicts the physics engine's numerical margin.

Space checks whether **every vertex of the circular window** lies strictly inside
an empty face's radial sector. With fixed orientation and uniform radial growth,
these edge planes do not change, so a successful commit freezes/fades the figure
and remains safe until passage. An incorrect commit emits
`LoopControls.commit_rejected(figure: Icosahedron)` and otherwise does nothing:
no fade, lock, handoff, score, sound, or immediate game over. The player can correct
and retry. An eventual uncorrected physical solid contact still ends the run.

Passage uses the same geometric clearance check; Area3D overlap gates arrival,
not Space or fading. Numerical physics margins are not added as an invisible
extra player radius. Touching an empty trigger with only part of the window is
not enough to score. This predictor assumes a fixed gameplay camera and radial
scaling about the figure center; translating/deforming shells or a moving camera
would require swept-path prediction.

The collision replay captures an incorrect Space press in player view, observer
view, hidden shell after correction and successful Space, successful passage,
solid approach, and game over with normal camera restored. Its contacts are real
Area3D overlaps, not injected score/failure.

Regression coverage includes every solid face and centered hole, off-center hole
clearance and near-edge failure on three orientations with 2% growth steps,
committed hidden passage using the production growth increment, same-tick
pass/failure ordering, and 24 overlapping passes across stages. The growth test
calls the production increment once per physics frame rather than reproducing
timer cadence. These deterministic orientations do **not** reproduce the input
history/settings of a video or prove arbitrary fast steering cannot miss a hit.
Record the console log alongside the next suspicious run to identify the shell
and side that actually resolved. Tests also check all window vertices against the
camera plane, rejection/retry through `ui_accept`, and accepted near-edge commits
remaining safe throughout growth.

### Camera-aligned window and non-punitive commit evidence

- Before: `build/visual-playtest/run.OkmcD5`; all six sheets and full-size
  `collision_01_player_view.png` reviewed. The old tilted box fills much of the view.
- After: `build/visual-playtest/run.fNobwP`; all six sheets and full-size collision
  frames 01–03 plus `mounted_02_approaching_hole.png` reviewed on default Vulkan
  Mobile, NVIDIA RTX 5060 Ti.
- Visible acceptance: player view shows a small centered round magenta outline,
  not a tilted box; rejected Space leaves the figure fully visible; corrected
  commit leaves only the hidden collider outline; passage removes that outline.
  Existing rotation/release/reset, fades, score, and restart/exit remain consistent.
  The physically small ring is only a few pixels from the distant observer view;
  inspect it in player view. Existing lab-panel/HUD overlap remains unapproved.
- `task test`: 37 tests / 569 assertions passed. This includes clear offsets at
  35% and 95% toward an edge and straddling offsets at 99%, across three faces,
  plus all 20 centered empty and solid faces. Rendered replay: 143 checks passed.
  Contact log: hidden empty side 19 passes at scale 16, then solid side 0 fails
  at scale 16. Radius/placement are initial feel values, not established through
  an interactive usability study.

### Original box-collider investigation evidence

- Video sampled at 4 FPS from 4–9 seconds:
  `build/collision-replay/replay.png`. Several passes precede an offset green
  opening and game over at nodes 4. Without input/transform/contact telemetry,
  this is not proof of a false hit.
- Before: `build/visual-playtest/run.a06JNw`; all five existing sheets and the
  full-size approaching-hole frame reviewed.
- After: `build/visual-playtest/run.4LizeS`; all six sheets, full-size
  `collision_01_player_view.png`, `collision_02_observer.png`,
  `collision_03_hidden_collider.png`, and `mounted_02_approaching_hole.png`
  reviewed on default Vulkan Mobile, NVIDIA RTX 5060 Ti.
- Visible acceptance: outlines do not fill/obscure the hole; observer view shows
  the separate magenta player box; the faded shell retains its outline; passed
  shell outlines disappear; disabling diagnostics restores the normal end view.
  Rotation/release/reset, commit fade, mounted passage, and restart/exit remain
  visually consistent. Existing lab-panel/HUD overlap remains; no blanket
  baseline approval. Thin overlapping sector edges are a diagnostic limitation.
- `task test`: 35 tests / 359 assertions passed. Rendered replay: 133 checks
  passed. Runtime contact records show hidden empty side 19 passing at scale 13,
  then visible solid side 0 failing at scale 13. No collision tolerance or
  resolution-rule change was made in this investigation.

### Debug-toggle keyboard-focus regression

Clicking the new debug checkboxes took GUI focus, which intentionally blocks
`PlayerInput`. Both now use `FOCUS_NONE`, like Restart/Pause. The collision replay
now actually steers after each checkbox click and checks release stops rotation;
its alignment helper also preserves scale when restoring the grown fixture.

Before: `build/visual-playtest/run.QLQcSH`; reproduction with added input checks:
`run.HkIzq8` fails both focus and steering checks. After:
`build/visual-playtest/run.RbJedI`, default Vulkan Mobile. All six before/after
sheets and full-size `collision_01_player_view.png` reviewed: the enabled-overlay
figure visibly turns, its outlines follow, and hidden/passed collider cleanup
still works. Existing lab HUD overlap remains. The mounted approaching hole is
larger because fixture alignment now retains its existing scale. `task test`:
36 tests / 361 assertions passed; rendered replay passed including both actual
click/steer/release checks.

## Camera-switch regression evidence

The gameplay recording showed faces filling the view and disappearing before
resolution, followed by an invisible game-over screen. MainScene kept the menu's
close camera current while displaying gameplay; standalone labs missed this.
Scene activation now explicitly selects that scene's camera.

Evidence under `build/visual-playtest/` (local generated artifacts):

- `run.talMhW`: original rotation/restart baseline, sheets and full-size frames reviewed.
- `run.Utz1uk`: mounted reproduction before the fix; camera assertion fails and
  `mounted_05_game_over.png` shows only the background and red spawn marker.
  This diagnostic run also logged audio shutdown leaks, subsequently avoided by
  omitting playback in the rendered fixture.
- `run.e66se5`: passing final replay on Vulkan Mobile, NVIDIA RTX 5060 Ti.
  All three sheets and relevant full-size PNGs reviewed. The approaching hole is
  visible (`mounted_02_approaching_hole.png`), passage shows Nodes: 1, the end screen
  shows nodes/score 1 (`mounted_05_game_over.png`), and the menu returns at its proper
  framing (`mounted_06_menu_return.png`). Rotation, release/reset, and restart
  remain visually consistent with the baseline, with no stale game-over figure.

Presentation issues at the time of the camera fix: the RunLab panel overlaps its
HUD, and white end-screen lettering has weak contrast against yellow. Neither is approved as a
visual baseline by this camera fix. `task test`: 27 tests / 228 assertions passed.

## Commit, contact order, and end-game transitions

- Before: `build/visual-playtest/run.vr6bXt`; all existing sheets and relevant
  full-size PNGs reviewed before changes.
- After: `build/visual-playtest/run.kyzxCe`; all five sheets and relevant full-size
  PNGs reviewed on the default Vulkan Mobile renderer (NVIDIA RTX 5060 Ti).
- Acceptance/observations: `options_02_restart_turn.png` and
  `options_05_exit_turn.png` visibly rotate the labeled figure in opposite
  directions before activating. Restart removes the old figure and resets the
  anchor. The fade sheet shows progressive disappearance, a stable next figure,
  and Nodes: 1 only after collision. Full-size `fade_03_mid.png` shows intentional
  screen-door grain, not a smooth alpha blend; this avoids depth-sorting artifacts
  between nested shells. No blanket visual baseline approval is implied.
- Colors now remain the figure's stage color across control handoff, with a subtle
  rim highlight instead of a yellow recolor. Menu/end figures retain cyan.
  Rotation/release/reset still match geometrically. The lab HUD overlap remains.
- Regression tests cover same-tick pass/failure ordering, 24 consecutive overlapping
  passes across level changes (mixed committed/uncommitted), frozen face-lock
  rotation after commit, stable colors, delayed option activation in both inversion
  modes, cancellation on restart, and pass sound only after real passage.
- Limitation: the 24-pass test uses aligned faces and accelerated scale steps. It
  cannot prove every player-reported auto-failure is resolved. Early commits still
  fail later if their locked orientation contacts a solid face; switching control
  no longer incorrectly plays the successful-pass sound.
- Final validation: `task test` passed 33 tests / 265 assertions; rendered replay
  passed 111 state/capture checks, with the separate visual review described above.
