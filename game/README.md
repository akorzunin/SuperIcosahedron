# Runtime code

`game/` contains only shipped code and assets. Scenes and their scripts live
beside each other, grouped by feature. See `docs/file-structure.md` for boundaries.

- `app/`: application composition and navigation.
- `gameplay/`: reusable game loop, run rules, figures, controls, level, modifiers.
- `menu/`: 3D menu and menu items (also used by the current game-over presentation).
- `ui/`: HUD and shared UI controls.
- `services/`: settings, audio, Discord.
- `game-assets/`: shared runtime assets without a single owning scene.
- `shared/`: existing cross-feature math/platform helpers.

Development scenes belong in `dev/labs/`, assertions in `test/`.
Do not introduce runtime dependencies on either directory.
