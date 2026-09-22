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

## Enabled mechanics

Each pickup in `game/gameplay/config/upgrades.json` accepts `enabled` (boolean,
default `true`). Disabled pickups are excluded from procedural generation and the
modifier library, even when previously discovered. Points, Tier, and Forge must
remain enabled because lesson progression requires them. Sign (both colors),
Echo, All-in, and Inversion are disabled by default; set `enabled: true` to restore
them. Their implementations and developer lab previews remain available for testing.

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
Tier → Points until banked chains (default 10), configured in
`game/gameplay/config/upgrades.json`. The counter cap, HUD denominator, and
completion check all use this positive integer CMS field. Merely passing nodes
or collecting multiple Tier pickups in one chain does not satisfy extra chains.

After the final pickup resolves, the next level is unlocked and a deferred
transition starts a fresh level 2: score, modifiers, counters, and old shells
are cleared. There is no Enter-next-level button. The controls tutorial also
advances automatically after its configured control exercises. Level 2 counts
completed Forge recipes (not ingredients or merely collecting Forge). After
`crafts_required_for_level_3` recipes (default 10), it unlocks and starts a fresh
level 3 using the existing harder layout. The HUD shows completed crafts; both
POINTS and TIER recipes count once, regardless of slot count. Level 3 is free play
with no further automatic lesson transition.

## Forge (level 2+)

Forge uses an anvil icon with two or three slots (internal values 1/2).
The first POINTS or TIER ingredient chooses the recipe and its base strength.
Later ingredients match by kind, even if their strengths differ. The HUD shows
filled slots and remaining ingredients; stored pickups do not activate until the
recipe completes.

POINTS recipes pay immediately when they complete. Every stored POINTS ingredient
pays its ordinary value, using any already-active chain normally, and the recipe
then cashes out that chain. Forge strength is not a points multiplier and does
not add a tier, so POINTS + POINTS remains ordinary POINTS without silently
throwing away the stored ingredients. This also means no extra POINTS pickup is
needed after crafting.

TIER + TIER activates a tier streak and awards `streak_points` (default 200)
immediately. Each subsequent consecutive TIER pickup awards another
`streak_increment` (default 50) on top of that base. A non-TIER pickup resets
the streak. The ordinary tier chain remains available for later POINTS.
Collecting TIER immediately before FORGE upgrades the Forge from two to three
slots (capped at three), rather than losing the TIER pickup. Forge-first TIER
pickups can still form a TIER recipe. Completed TIER recipes use the ordinary
strength of their first ingredient and award the same streak payout.

Nonmatching pickups activate normally. Sign is binary, so Sign, Echo, All-in,
Inversion, and Forge are not ordinary recipe ingredients. A second Forge keeps
the current recipe rather than replacing or nesting it. Death and restart
still discard both the chain and any stored recipe.

ECHO can arm without a chain and doubles the next POINTS reward (one charge)
or TIER strength. It does not stack and SIGN preserves it. Storing ingredients
does not consume ECHO; a nonmatching eligible activation may consume it first.
ALL-IN doubles the pot, including the next POINTS reward, and that pickup banks
immediately regardless of remaining TIER strength. It bypasses FORGE storage
without consuming the recipe. Neutral or non-POINTS passages lose the chain,
but leave the independent recipe intact. Death and restart discard both.

INVERSION flips the chain's sign and doubles accumulated points, without changing
future POINTS rewards or granting a tier. A negative pot can be rescued with
INVERSION or +SIGN; banking before conversion scores a negative total.
ECHO, ALL-IN, and INVERSION have catalog value 2 and distinct animated passage
effects. ALL-IN uses accelerating inward triangular pulses.

Forge is sampled only in difficulty profile 2 or higher, including without a
pending chain. Profile 1 remains unchanged. There is no scripted introductory
pickup sequence or ingredient flight animation yet; feedback uses the persistent
text tray and collection messages.

## Central JSON / CMS handoff

Edit **`game/gameplay/config/upgrades.json`**, schema version **2**.
`choices_per_figure` is removed. Open counts emerge from the selected difficulty
profile, distance-based probabilities, and required pickups.

Queue play generates seeded 3–5-shell movement phrases (move, hold, change,
recover), independent of live player aim after initial alignment. A neutral route
moves at most one adjacent face per shell; points and tier rewards start two
steps away. No face stays open for three consecutive shells, including pickup
openings. A reserved closed neighbor keeps the next survival step available.
Recovery shells request three nearby openings, subject to streak exclusions.
Normal profiles request two, one–two, then one nearby opening. Far openings are
capped at eight so streak exclusions cannot exhaust required reward placement.
The generator checks a one-edge turn budget with 25% margin against configured
rotation speed and spawn spacing; this conservative heuristic is not a full
controller replay. Already-visible layouts are never changed to counter aim.

| Field | Meaning |
| --- | --- |
| `streak_points` | Positive integer payout for the first completed/consecutive TIER combination |
| `streak_increment` | Positive integer added by each subsequent consecutive TIER pickup |
| `points_by_tier` | Positive integer score magnitudes, indexed from tier 1 |
| `difficulty_levels[].tiers_required` | Increasing cumulative tier-unit threshold; first must be 0 |
| `difficulty_levels[].easy_open_faces` | Inclusive `[min, max]` requested openings among steps 0–1, each 1–3; streak exclusions may reduce these, recovery requests 3 |
| `difficulty_levels[].easy_pickup_chance` | Chance an unreserved open neighbor gets a non-points pickup rather than staying neutral |
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
