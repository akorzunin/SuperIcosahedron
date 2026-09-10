# Gameplay configuration / CMS handoff

- `gameplay.json`: gameplay tuning, under `game_settings`.
- `upgrades.json`: modifier pickups, colors, tier strengths, and choice count.
  See [modifier rules](../../../docs/modifier-implementation.md).

Both files use `schema_version: 1` and are included by every export preset.
Defaults are unchanged by this migration.

## Gameplay fields

| Key | Default | Meaning / constraints |
| --- | --- | --- |
| `GAME_SPEED` | 10 | Positive pacing value. Affects spawn interval and shell growth. |
| `SPAWN_SPEED` | 10 | Positive spawn-rate factor. Interval in seconds is `100 / (SPAWN_SPEED * GAME_SPEED)`. |
| `SCALE_FACTOR` | 10 | Positive growth factor. Every 10 ms, shell scale multiplies by `1 + SCALE_FACTOR / 1000 * (0.5 + GAME_SPEED / (10 + GAME_SPEED))`. |
| `ROTATION_SPEED` | 12 | Nonnegative steering speed; also used for menu rotation. |
| `SPAWN_MODE` | 2 | Integer: 0 tutorial, 1 debug, 2 normal modifier gameplay. |
| `DESPAWNER_MODE` | 16633 | Nonnegative cleanup-plane X position in thousandths of world units. |
| `MAX_LEVEL` | 0 | Integer 0–10, legacy menu level-selection cap; not modifier strength or tier cap. |

All numeric fields must be finite. Speeds may be fractional. Enum/index fields
are converted back to integers after parsing JSON. Development builds validate
required fields, types, and the ranges above. Extremely high speeds can still
make gameplay impossible; validation is not a balance or collision-safety proof.
The physics tick and collision geometry are not CMS knobs.

## Precedence and persistence

Gameplay JSON is authoritative whenever settings are loaded. Old `[game_settings]`
sections in `user://settings.cfg` are removed during migration, so an old saved
`GAME_SPEED` cannot override newly shipped tuning. The existing nested and flat
`G.settings` keys remain available to gameplay code.

Graphics, audio, debug-display toggles, control mode, and inversion remain player
preferences in `[user_settings]`. They are preserved when migrating. Config sync
also writes preferences only, not a stale copy of gameplay values.

For development, edit JSON and restart the game. Gameplay JSON is reread on the
existing settings reload path too; restarting is recommended because some nodes
apply settings only when initialized. Upgrade definitions are cached until the
process restarts. Published games need a new export containing the edited JSON;
this is a shipped-content format, not a remote CMS client or hot-reload service.

Run `task test` and `task visual-playtest` after tuning. Inspect the generated
contact sheets and relevant full-size frames; passing replay checks alone do not
establish readable presentation or playable speed.
