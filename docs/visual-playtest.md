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

## Face-distance difficulty and shared steering

- Before: `build/visual-playtest/run.WPri0U`; after:
  `build/visual-playtest/run.0XxH5z`, default Vulkan Mobile, RTX 5060 Ti.
  Reviewed all seven before/eight after contact sheets in combined overviews,
  before full-size `modifiers_03_choices.png`, and after full-size
  `difficulty_01_easy_zone.png`, `difficulty_03_hard_pickup.png`, and
  `difficulty_06_open_border.png`.
- Visible acceptance: the easy region has neutral PASS routes and a weak T1
  pickup rather than isolated mandatory choices. Two nested shells visibly
  turn together. A distant opening reads `TIER +2 / 4 steps`; collecting it
  changes the HUD from one acquired tier/difficulty 1 to three/difficulty 2.
  The next generated easy region has two openings; the centered open/open
  border has no visible wall or rejected-clearance state. Existing rotation,
  release/reset, burst fade, game over, restart and menu return stay consistent.
- Intermediate `run.FmbO1F` showed overlapping multi-line pickup labels. The
  final version suppresses intersecting labels nearest-screen-center first;
  rotation reveals suppressed/rear choices. This is deliberately not a full
  label layout. Existing lab-panel/top-HUD overlap remains unapproved.
- `task test`: 54 tests / 3279 assertions passed. Rendered replay: 181 checks
  passed, including physical hard-tier progression, shared orientation,
  committed-shell freeze, recentering, and adjacent-opening clearance. Unit and
  physics coverage includes all 400 recenter mappings and actual open/open
  border passage. Lab collider colors also refresh when recentering changes
  a face's role without replacing its collider. No balance/usability approval is implied: face alignment,
  fixture seed selection and scale steps are scripted, and captures are sparse.

## Controlled figure outline and open-dent diamond

- Before: `build/visual-playtest/run.apxGH6`; after:
  `build/visual-playtest/run.9CUNad`, default Vulkan Mobile, RTX 5060 Ti.
  Reviewed all six contact sheets in combined overviews and full-size
  `mounted_02_approaching_hole.png` before/after, plus after
  `rotation_03_right_end.png`.
- Acceptance/observations: only the controlled shell has thin dark triangular
  edge outlines, preserving stage colors. A small hollow gold diamond tracks
  its empty face during rotation and stays screen-sized during growth. It is
  visible through the shell, so a rear opening remains locatable. Control
  handoff transfers cues; burst fragments and menu/end figures have no cues.
  Rotation/release/reset, passage, fade and restart remain visually consistent.
- The outline includes face edges, not just the outer silhouette. The marker
  does not distinguish front/back or indicate an offscreen opening; those would
  require directional HUD cues. Existing lab-panel/HUD overlap remains.
- `task test`: 39 tests / 626 assertions passed. Final rendered checks passed.
  First after-run `run.T2nRcC` rendered but failed RunLab restart checks; an
  unchanged rerun passed. This intermittent replay failure is not resolved here.
  Sparse captures do not validate every animation frame.

## Radial fragment fade

- Before: `build/visual-playtest/run.zf1y5K`; after:
  `build/visual-playtest/run.2RQIZi`, default Vulkan Mobile (RTX 5060 Ti).
  Both replay checks passed; all six sheets reviewed in combined overviews,
  plus full-size `fade_06_passed.png` before/after and after
  `mounted_05_game_over.png`.
- Pieces stay solid for 0.3 seconds, then fade over 0.8 seconds while continuing
  straight outward. Late passage frames visibly show the background through
  dissolving triangles instead of fully opaque pieces awaiting abrupt removal.
  Impact fragments also fade behind the readable score. This uses the existing
  grainy screen-door shader, not smooth alpha blending. Two-sided faces remain.
- `task test`: 38 tests / 580 assertions passed, including intermediate fragment
  opacity after the source shell is removed. Existing lab HUD overlap remains;
  sparse captures do not validate every frame.

## Simplified radial burst and two-sided faces

- Before: `build/visual-playtest/run.H4yba1`; after:
  `build/visual-playtest/run.Tkc1z6`, default Vulkan Mobile, RTX 5060 Ti.
  Both replay checks passed. Reviewed all six sheets as combined overviews,
  full-size `fade_03_mid.png` before/after, and after
  `mounted_05_game_over.png`.
- Acceptance/observations: dents retain their orientation and move directly away
  from the center for 1.1 seconds, remaining opaque until removal. Wide, solid
  triangles and widening gaps are clearly visible instead of tumbling slivers
  and grainy fading. Back faces now show the shell interior through the hole and
  during the burst. Large nearby fragments fill the screen edges; the central
  score remains readable. Inner faces also make intact shells look fuller.
  Existing lab-panel/HUD overlap remains unapproved.
- `task test`: 38 tests / 578 assertions passed, including fixed orientation,
  longer fragment lifetime, and cleanup. Sparse replay still does not validate
  every animation frame.

## Dent burst animation evidence

- Before: `build/visual-playtest/run.IJk7AJ`; after:
  `build/visual-playtest/run.bM6PBF`, default Vulkan Mobile (RTX 5060 Ti).
  Reviewed all six contact sheets in combined overviews and full-size
  `fade_03_mid.png` before/after and `mounted_05_game_over.png` after.
- Acceptance: successful Space separates the visible triangular dents in distinct
  outward directions with tumble, then fades them; solid impact leaves flying
  fragments around the score figure rather than deleting the shell instantly.
  The next shell and score text remain visible. Fragments deliberately travel
  beyond the screen edges; edge-on triangles briefly appear as thin slivers.
  Existing screen-door fading and lab-panel/HUD overlap remain.
- `task test`: 38 tests / 576 assertions passed. Final visual replay state checks
  passed. The baseline rendered but failed reset/restart/input checks; that run
  is not an approved functional baseline. Sparse captures do not validate every
  animation frame.

## Gameplay JSON migration evidence

- Before: `build/visual-playtest/run.hosb7z`; after:
  `build/visual-playtest/run.IKkNJf`, default Vulkan Mobile, RTX 5060 Ti.
- Reviewed all seven contact sheets before/after and full-size
  `modifiers_03_choices.png` in both runs. Acceptance: moving unchanged defaults
  into JSON must retain shell scale/appearance, rotation/release/reset, readable
  pickup/HUD text, modifier activation, and restart/menu transitions. These remain
  visibly consistent; wall-clock HUD times differ. Existing lab-panel overlap and
  distant label clustering remain unapproved limitations.
- `task test`: 46 tests / 1652 assertions passed, including authoritative JSON
  defaults, saved-config migration, preference preservation, and invalid tuning
  validation. Rendered replay checks passed. This validates the unchanged default
  tuning, not the playability of arbitrary future CMS speed values.

## Modifier-chain replay

The replay also produces `modifiers_contact_sheet.png`: generated base choices,
base collected, tier choices, tier collected, next base, and committed effect.
It checks physical POINTS → TIER → POINTS passage and restart cleanup. Review this
seventh sheet for modifier changes. The eighth, `difficulty_contact_sheet.png`,
continues that run: three-face easy zone, shared rotation, a four-step TIER +2,
physical collection/recentering and difficulty increase, a new two-face easy
zone, and clearance across an open/open border. See [implementation](./modifier-implementation.md).

## Evidence to inspect

- `{rotation,run,mounted,fade,options,collision,modifiers,difficulty}_contact_sheet.png`: six checkpoints each,
  ordered left-to-right, top-to-bottom.
- `{rotation,run,mounted,fade,options,collision,modifiers,difficulty}_*.png`: individual 1280×720 screenshots
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

**Open all eight contact sheets, then inspect individual frames where needed.** Verify
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

Space checks whether the **whole circular window** fits within the union of open
radial sectors. A single-sector fit is the fast path; otherwise the projected
convex window polygon is clipped against all solid sectors, rejecting any
intersection. Adjacent open/open borders therefore do not act as invisible walls.
Multi-face passages collect only the face under the window center. With fixed
orientation and uniform radial growth, these edge planes do not change, so a
successful commit freezes/fades the figure
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
