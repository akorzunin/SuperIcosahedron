# Validation

For changes affecting gameplay presentation, input, cameras, UI, or shaders:

- Run `go-task test` (GUT unit/integration tests).
- Run `go-task visual-playtest -- --rendering-method gl_compatibility` to ensure visual validation.
