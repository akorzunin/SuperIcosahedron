# Validation

For changes affecting gameplay presentation, input, cameras, UI, or shaders:

- Run `task test` (GUT unit/integration tests).
- Run `task visual-playtest` before and after the change.
- Open both generated contact sheets and inspect relevant full-size PNGs; capture
  success and passing state checks are not visual validation.
- Report visible acceptance criteria, observations, renderer, and evidence paths.
- If rendering fails or only an alternate renderer works, report default-renderer
  visual validation as incomplete. Never silently approve visual baselines.

See `docs/visual-playtest.md` for commands without Task, scenario coverage, artifact
layout, and limitations. Add targeted evidence when these two replays do not cover
the change being made.
