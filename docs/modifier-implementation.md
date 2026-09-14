# Modifier chains and face-distance difficulty

Normal play (`SPAWN_MODE = QUEUE`, the default) uses procedural modifier layouts.
Tutorial/debug modes retain single-opening, immediate-score fixtures. Normal
runs do not advance difficulty from elapsed time, node count, or base pickups.

## Movement and the easy point

Face difficulty is shortest-path distance over shared face edges, not angular
error from the camera. Every center has these rings:

| Steps | 0 | 1 | 2 | 3 | 4 | 5 |
| --- | --- | --- | --- | --- | --- | --- |
| Faces | 1 | 3 | 6 | 6 | 3 | 1 |

The first easy point is the face nearest the player window at spawn. Normal
uncommitted shells share accumulated steering, including FaceLock animation;
new shells inherit that orientation. Committed shells stay frozen so steering
the next shell cannot invalidate an accepted passage.

After physical passage, the passed face ID becomes the easy point for future
shells. Already spawned layouts never change, including uncommitted shells.
Difficulty changes likewise affect only newly generated layouts.

## Safe routes and rewards

- When open, the center is a neutral `PASS` route: no score or chain change.
- Each difficulty profile opens 2–3 faces sampled from the entire
  center-plus-three-neighbor easy zone. The center can be blocked, so staying
  still does not guarantee passage.
- A base is placed at the nearest eligible opening. With a pending chain, a tier
  pickup is also placed at the nearest eligible available face. Additional
  pickups are sampled with JSON probabilities and weights.
- Easy openings can stay neutral; additional far openings always have pickups.
- Each pickup defines an allowed step range and its value at each step.
  Defaults: nearby bases start at T1; a base four steps away starts at T4.
  Tier pickups require at least two steps; four steps grants +2, five grants +3.
- The whole player window may span adjacent open faces. Clearance tests the
  projected window polygon against every solid sector, including polygon
  interiors, rather than treating an open/open edge as a wall. Exactly one side
  is collected, using the face under the window center for a multi-face passage.
  Solid boundaries remain fatal; invalid Space commits remain non-punitive.

## Chains and progression

POINTS commits the previous chain, then starts a new positive chain at the
pickup's configured starting tier. Sign pickups replace the sign. Tier pickups
add tier units, capped by the score table. Collection occurs on physical passage,
not Space; each figure resolves once.

Difficulty counts **acquired tier units**, separately from pending chain tier:
`TIER +2` contributes two units. Units still count at the chain tier cap. Base
starting tiers, neutral passages, sign pickups, and chain commits do not advance
difficulty. Upgrades without a pending base do nothing; generation avoids these.

Default cumulative thresholds are 0, 3, 8, 16 units: successive increases require
3, then 5, then 8 more units. The last configured profile remains active afterward.
Add more profiles to extend progression. Death discards the pending chain without
committing it; restart resets score, cumulative tier units, easy point, and shared
orientation. Negative scores are allowed: points are not health.

## Automatic lesson transitions

Level 1 advances automatically after `chains_required_for_level_2` completed
Points → Tier → Points chains (default 3), configured in
`game/gameplay/config/upgrades.json`. The counter cap, HUD denominator, and
completion check all use this positive integer CMS field. Merely passing nodes
or collecting multiple Tier pickups in one chain does not satisfy extra chains.

After the final pickup resolves, the next level is unlocked and a deferred
transition starts a fresh level 2: score, modifiers, counters, and old shells
are cleared. There is no Enter-next-level button. The controls tutorial also
advances automatically after its three completed control exercises. Level 2
has no automatic transition to an unfinished level 3.

## Forge (level 2+)

Forge uses an anvil icon with two or three slots (internal values 1/2).
Two matching ingredients produce ×4; three produce ×8. The first POINTS or
TIER ingredient chooses the recipe and its base strength. Later ingredients
match by kind, even if their strengths differ. The HUD shows filled slots,
remaining ingredients, and the result multiplier; stored pickups do not activate.

Crafted POINTS commits the old chain normally, then starts a new chain at the
first ingredient's tier with a ×4/×8 score multiplier. It pays only on the next
POINTS activation. Crafted TIER applies the first ingredient's tier increment
×4/×8, subject to the existing tier cap. Nonmatching pickups activate normally.
Sign is binary, so Sign, Echo, All-in, Inversion, and Forge are not ingredients.
A second Forge keeps the current recipe rather than replacing or nesting it.

Echo is consumed only by a SIGN/TIER activation, not by storing ingredients;
a nonmatching eligible activation may consume it before the craft finishes.
POINTS activation still resets Echo as part of its normal chain reset. All-in
retains its next-shell rule: Points ingredients preserve it, but neutral or
non-Points pickups (including Forge) lose the chain. Losing a chain to All-in
does not erase the independent recipe. Death and restart discard both.

Forge is sampled only in difficulty profile 2 or higher, including without a
pending chain. Profile 1 remains unchanged. There is no scripted introductory
pickup sequence or ingredient flight animation yet; feedback uses the persistent
text tray and collection messages.

## Central JSON / CMS handoff

Edit **`game/gameplay/config/upgrades.json`**, schema version **2**.
`choices_per_figure` is removed. Open counts emerge from the selected difficulty
profile, distance-based probabilities, and required pickups.

| Field | Meaning |
| --- | --- |
| `points_by_tier` | Positive integer score magnitudes, indexed from tier 1 |
| `difficulty_levels[].tiers_required` | Increasing cumulative tier-unit threshold; first must be 0 |
| `difficulty_levels[].easy_open_faces` | Inclusive `[min, max]` total openings among steps 0–1, each 2–3 |
| `difficulty_levels[].easy_pickup_chance` | Chance an unreserved open neighbor gets a pickup rather than staying neutral |
| `difficulty_levels[].open_chance_by_steps` | Six probabilities indexed 0–5; indices 2–5 control optional far openings; 0–1 are ignored in favor of the easy-zone rule |
| `pickups[].id` | Unique stable identifier |
| `pickups[].title` | Short display name; generated labels append strength and distance |
| `pickups[].kind` | `points`, `sign`, `tier`, `echo`, `all_in`, `inversion`, or `forge` |
| `pickups[].min_steps`, `max_steps` | Inclusive integer acquisition-distance bounds, 0–5 |
| `pickups[].weight` | Positive relative weight among eligible entries at that distance |
| `pickups[].value_by_steps` | Six integer values indexed 0–5, including unused distances |
| `pickups[].value` | Fallback value for direct/debug pickups without a placement distance |
| `pickups[].color` | HTML hex label color |

Values mean starting chain tier for `base`, added tier units for `tier`, and
-1/+1 for `sign`. Sign effects are binary; their difficulty is placement, not a
larger numerical sign. Exactly one base effect (points) and at least one tier
entry are supported. Bases must permit a non-center face, tier entries must
permit steps 2 or greater, and base/all tiers cannot compete exclusively for the
single opposite face. These constraints preserve access to chain activation and
voluntary progression. Required placements ignore optional opening probability,
but respect pickup distance bounds. Sampling is with replacement, so repeated
pickup types may appear on a shell.

Catalog assertions catch invalid shipped configuration in development. This is
not an untrusted remote-content loader or live CMS connection. Restart Godot
after editing and run `task test`; balance tests intentionally pin the initial
values. Export presets explicitly include the JSON. For repeatable generation,
call `spawner.reset(seed)` before spawning, with the same chain/tier/easy-point
state. Normal restarts choose a new seed.

## Presentation and limitations

Only the controlled shell shows labels. They stay screen-sized, show configured
strength and step distance, and hide on rear faces. Nearby screen-space labels
suppress overlapping ones, prioritizing the label closest to screen center;
rotate to reveal hidden choices. This is not a full label-layout system. HUD
shows score, difficulty, acquired tiers, pending chain, and last activation.

Distance measures face-graph travel from the easy point, not actual player input
history or free-spin travel time. This is a tunable difficulty heuristic, not an
established balance curve. Predictive clearance assumes convex regular shells,
uniform radial growth and the fixed gameplay camera; moving/deforming geometry
would need swept collision prediction. Multiplier/speed effects, rarity,
mutations, contracts, and points-as-health remain outside this slice.

## Validation

See the face-distance entry in `docs/visual-playtest.md` for reviewed evidence.
Tests cover all 20 distance maps, all 400 recenter mappings, seeded placement,
value-by-distance, easy-zone bounds at every profile, tier-only progression,
neutral and duplicate passage, shared free-spin/FaceLock and spawn orientation,
committed-shell freeze, recentering, restart, and adjacent-opening physical
passage alongside existing solid/near-edge collision regressions.
