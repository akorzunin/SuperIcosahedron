# Modifiers lab

Run `go-task lab-modifiers`.

The center is a production `Icosahedron` with catalog pickups rendered by
`MeshIcosahedron`, including the real face shaders. Drag to rotate, click a pickup
face to select it, or use the compact selector to bring a hidden modifier forward.
Strength changes update that face. Space passes the selected pickup through
`RunState.resolve_side`; it does not directly simulate scoring.

Left: played history and an editable replay sequence. Right: banked/pending points,
chain/Forge state, tier statistics and actual level conditions. Bottom: reset,
step/replay, presets, clipboard reproductions and per-passage state differences.

Starting-state fields apply on Reset, which preserves selection and sequence.
These are raw debugging fields: inconsistent chains/Forge recipes are deliberately
possible. Pending points are derived from tier, sign and multiplier, not independently
editable. Tutorial mode supplies a confirmed passage for each action; it does not
simulate steering. Empty passage means passing safely without a pickup, not hitting
a solid face. Completion uses the gameplay predicate but never navigates or unlocks
persistent progress. Clipboard imports require matching production condition thresholds.
