# Docker game builds

The game builder is separate from `web/Dockerfile` (the frontend). CI and
deployment are not changed by this build path.

## Commands

Requires Docker with Buildx, Bash, and optionally Task. No host Godot, Java,
Android SDK, Python, cloud credentials, or source `assets/` are needed.

```sh
task build                    # all four debug exports
task build TARGET=web          # or linux, windows, android
task test-docker               # GUT, using the same pinned builder

# Without Task:
TARGET=all bash scripts/build_game.sh
TARGET=test bash scripts/build_game.sh
```

The builder runs as `linux/amd64`. ARM hosts need Docker's amd64 emulation.
Linux and Windows exports are x86_64; Android is arm64-v8a, as in the presets.
Outputs are under `build/docker/<TARGET>/`:

- `linux/SuperIcosahedron.x86_64` and required shared libraries
- `windows/SuperIcosahedron.exe` and required DLLs
- `web/index.html` and companion files
- `android/SuperIcosahedron.apk`
- `logs/` and `build-info.json`

Distribute the **whole platform directory**, not just the executable. Single-target
builds contain only that platform. Buildx creates host-owned output files without
mounting or modifying the source checkout. The local exporter merges into an
existing output directory; remove that target's output directory first if you
need to rule out stale files from older toolchains. A failed build does not
publish new artifacts: check the command's exit status, not existing files.
Failure logs are printed by Docker; successful logs are also exported.

## Metadata and Discord

```sh
task build TARGET=all GAME_VERSION=v1.2.3 GAME_COMMIT=0123456789abcdef DISCORD_APP_ID=123456789
# Equivalent environment variables work without Task.
```

Version defaults to `git describe --tags --always --dirty`, commit to full HEAD.
Without Git metadata they default to `dev` / `unknown`. Supply both explicitly
for a future tag-triggered CI build; CI can run exactly the same Task command.
These strings are injected inside Docker, not through the legacy prebuild scripts.
Untracked files are not reflected by Git's dirty marker: build a clean checkout
for release provenance.

`game/app/env.gd` is excluded and generated inside the builder. `DISCORD_APP_ID`
is a **public application identifier**, not a token or signing secret. Its default
is `0` (placeholder; working Discord integration requires the real ID). Desktop
exports retain the Discord extension. Web/Android remove the extension, autoload,
and desktop-only service script; runtime already selects the dummy service there.
Editor plugins are disabled in disposable build copies. Renderer settings are
left unchanged; this does not validate Web renderer compatibility or visuals.

## Reproducibility boundary

`docker/game.Dockerfile` pins the Debian base digest, Debian package snapshot,
Godot **4.7.2** and matching templates, Android build-tools **36.1.0**, and platform-tools
**36.0.2**. Downloads have checked-in checksums. Update versions, checksums and
Godot editor-settings/template paths together. The first build needs network
access to those upstream archives; subsequent builds reuse Docker layers.
The actual import, test, and export step runs with Docker networking disabled.

The Dockerfile-specific context allowlist excludes root `assets/`, `.godot/`,
`.git/`, previous builds, local environment files, and keystores. Runtime assets
must be committed under `game/` (or the owning addon), never fetched from the
cloud during a build. The addon `bin/` files are intentionally included: the
frontend's root `.dockerignore` would exclude these required native libraries.

Android uses the prebuilt debug APK template, **not Gradle**, despite the legacy
preset enabling Gradle. There are currently no custom Android plugins. Adding
those requires a Gradle build path and pinned SDK/Gradle dependencies. Java and
the Android build/platform tools suffice for this APK export path.

This is repeatable tooling/input isolation, **not a byte-identical build guarantee**:
Godot may embed timestamps and the builder generates an Android debug signing key.
Rebuilding the toolchain image generates a new key, so an existing debug Android
install may need uninstalling before installing the new APK (losing its local data).
Do not use this disposable key for production. Release exports/signing and SDK
license management for a redistributed builder image are outside this first step.
No signing credentials should be passed as build arguments or copied into layers.

## Validation

```sh
python3 -B -m unittest discover -s docker -p 'test_*.py'
task test-docker
task build TARGET=all
```

GUT is explicit, not silently coupled to every export. Import/export fail on
nonzero exit status **or** logged Godot errors, including script errors that Godot
can report with exit status zero. Validate from a clean checkout to catch
untracked runtime dependencies. Export success is not a browser, device, or
rendered gameplay smoke test; see `docs/visual-playtest.md` for visual validation.

### Initial validation evidence

Local evidence is under `build/docker-validation/` (generated, not committed):

- `clean-build-offline.log`: all four exports from tracked files plus the new build
  scripts, without `.git`, local config or cloud assets; export networking disabled.
  `clean-path.txt` records the temporary source/artifact directory.
- `test-host.log`, `test-docker-offline.log`: host and container GUT results.
- `python-tests.log`: preparation isolation and error-gating unit tests.
- `linux-smoke.log`: exported Linux executable starts headlessly, but logs Discord
  unavailability and a resource-in-use error at forced shutdown. This is **not**
  a clean runtime/visual validation pass.
- `pre-commit.log`: lint blocked by the existing invalid `^*.lock.*$` regex in
  `.pre-commit-config.yaml`; that unrelated configuration was not changed.

Exports also report existing Discord addon UID fallbacks and an ADB-daemon
shutdown connection message. No browser, Windows runtime, Android device, or
rendered gameplay validation was performed. Renderer settings were not changed.

Legacy `dev-build-*` and deployment tasks still use host tooling and their old
artifact layout. Use `task build` for this Docker path; switching deployment and
adding tag-triggered CI are separate follow-ups.
