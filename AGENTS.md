# Validation

For changes affecting gameplay presentation, input, cameras, UI, or shaders:

- Run `go-task test` (GUT unit/integration tests).
- Run `go-task visual-playtest -- --rendering-method gl_compatibility` to ensure visual validation.
- Run `uvx prek run --all-files` to run l inters and formatters, hooks can autoformat/autofix so dont do it manually.
