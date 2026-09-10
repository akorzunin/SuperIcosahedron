# Modifier-chain playable slice

Normal play (`SPAWN_MODE = QUEUE`, the existing default) now generates pickup
choices instead of consuming level patterns. Tutorial/debug modes retain their
single-opening, immediate-score fixtures. Normal runs no longer level up from
node count. Steering, Space commit, physical passage, and fatal solid collisions
are unchanged.

## Rules

- POINTS starts a positive tier-1 chain. The next POINTS applies the previous
  chain and starts a new positive tier-1 chain.
- Sign pickups replace the sign; repeated signs do not multiply it.
- Tier pickups add strength, capped at the length of `points_by_tier`.
- Upgrades without a pending base do nothing. Generation offers only bases until
  a chain exists, then one guaranteed base and random upgrade choices.
- Effects happen on physical passage, not Space. Each figure resolves once.
- Negative scores are allowed; points are not health. Death discards the pending
  chain without committing it. Restart clears score, chain, and activation text.
- Spawned figures retain their choices even if the chain changes afterward.

## Editing / CMS handoff

All pickup definitions and balance values live in:

`game/gameplay/config/upgrades.json`

General gameplay tuning (speed, growth, spawning, rotation) lives alongside it in
[`gameplay.json`](../game/gameplay/config/gameplay.json). See the
[configuration reference](../game/gameplay/config/README.md) for units and migration rules.

| Field | Meaning |
| --- | --- |
| `schema_version` | Currently `1` |
| `points_by_tier` | Positive integer score magnitudes, indexed from tier 1 |
| `choices_per_figure` | 2–3 distinct, nonadjacent open faces |
| `pickups[].id` | Unique stable identifier |
| `pickups[].title` | Displayed face label; keep short |
| `pickups[].kind` | `base`, `sign`, or `tier` |
| `pickups[].value` | Base: unused; sign: -1/+1; tier: positive integer increment |
| `pickups[].color` | HTML hex label color |

Exactly one base is supported, always affecting points. Non-base entries are
sampled uniformly, with replacement, so duplicate upgrade choices are possible.
The base must have at least one upgrade companion. Edit data, restart Godot, and
run `task test`; the current tests intentionally pin the initial balance values.
`UpgradeCatalog.gd` asserts catalog invariants in development. This is a trusted,
shipped catalog, not an untrusted remote-content loader or a live CMS connection.
All export presets explicitly include this JSON. No generated art is required:
labels use Godot fonts and the existing shell/outline rendering.

Generation uses the spawner's run-local RNG. For a reproducible fixture call
`spawner.reset(seed)` before spawning. Normal restarts get a fresh seed. Choices
are separated by solid borders because the current passage predictor requires
the entire player window inside one opening; adjacent-opening traversal would
need a union-of-sectors clearance test first.

## Presentation and scope

Only the controlled shell displays pickup text. Labels stay screen-sized during
growth and appear on camera-facing openings; rotate to discover rear choices.
The bottom HUD shows score, pending effect, activation instruction, and the last
committed effect. No new textures, shaders, dependencies, or CMS framework.

This slice does **not** implement multiplier/speed effects, rarity, mutations,
contracts, timers, spikes, or points-as-health. Red signs are a penalty rather
than a complete risk/reward economy yet. Distant labels can cluster while the
shell is tiny; screen-space label placement is a future presentation improvement.

## Validation evidence

- Before: `build/visual-playtest/run.NdXdZK`.
- After: `build/visual-playtest/run.o6SzEB`, default Vulkan Mobile renderer.
- Reviewed all six original contact sheets before/after and the new
  `modifiers_contact_sheet.png`. Inspected full-size before/after
  `mounted_02_approaching_hole.png`, plus after `modifiers_03_choices.png` and
  `modifiers_06_collected.png`.
- Visible acceptance: open faces have readable, colored pickup labels rather
  than the single gold locator; shell outlines remain. The tier label stays
  inside the opening at approach scale. Pending T1 becomes T2 after passage,
  then score becomes 250 with fresh T1 and `Activated: +250 points`. HUD text is
  separated from the top stats. Rotation/release/reset, burst fade, game over,
  restart, and menu return remain visibly consistent.
- An intermediate rendered pass (`run.9c7LRG`) exposed oversized overlapping
  labels. Final labels cancel inherited shell scale and suppress rear labels.
- Existing lab-panel/top-HUD overlap remains unapproved. Sparse scripted captures
  do not establish natural steering difficulty or economy balance. The added
  modifier replay uses production generation and physical collisions but aligns
  faces programmatically and stops spawn/growth timers between checkpoints.
- `task test`: 42 tests / 1588 assertions passed. Rendered state checks passed,
  including physical POINTS → TIER → POINTS activation and restart cleanup.
