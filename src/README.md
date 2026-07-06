# Runtime source layout

`src/` should contain only code and assets needed by the shipped game.

- `scenes/` — runtime entry scenes (`MainScene`, menu, loop) plus scene scripts in `scenes/init/`.
- `components/` — reusable runtime nodes and helpers used by scenes.
- `models/` — runtime 3D/game model scenes, scripts, and assets.
- `side/` and `ecs/` — gameplay data and modifier systems.
- `themes/`, `fonts/`, `shaders/`, `sfx/` — runtime presentation assets.

Debug scenes, shader experiments, manual tests, and scratch scripts live in `dev/` and are excluded from export.
