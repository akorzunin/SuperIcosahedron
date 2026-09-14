# SuperIcosahedron

Indie arcade game made with Godot engine.
Players navigate through a mesmerizing journey of rotating icosahedrons,
aligning spots to progress to the next challenge. Its minimalist aesthetic
complements the intricate gameplay, offering a unique blend of skill and strategy.

Game mostly inspired by Super Hexagon

## Project layout

- `game/` contains shipped runtime code, organized by feature.
- `game/game-assets/` contains shared runtime assets (fonts, themes, sky).
- Scene-specific assets live beside their scene or feature.
- `assets/` contains cloud-synced source assets; Godot ignores it.
- `dev/labs/` contains only RunLab and RotationLab; exports exclude it.
- `test/` contains automated GUT unit and integration tests.

See [file structure and dependency boundaries](docs/file-structure.md).

## Fast iteration

Open either scene and press **F6**, or run:

```sh
task lab-run       # production game loop, no menu
task lab-rotation  # production controls, isolated figure
task test          # parallel GUT tests; output only on failure (default: up to 4 workers)
TEST_JOBS=2 task test # override test concurrency (Linux user data isolated per suite)
task visual-playtest # rendered replays + screenshots on a private display (Linux)
```

Visual playtests require `Xvfb`, `xvfb-run`, and `xauth` (Debian/Ubuntu:
`sudo apt install xvfb xauth`; Arch: `sudo pacman -S xorg-server-xvfb xorg-xauth`).
They render on an isolated virtual display without opening desktop windows or
stealing focus. Screenshots and contact sheets are captured automatically under
`build/visual-playtest/run.*`; no desktop recording or frame splitting is needed.
The project renderer is preserved, so working Vulkan drivers are still required
for the default renderer.

For visual changes, run the playtest before and after editing, then **open and
inspect** the generated contact sheets. Passing state checks alone is not visual
validation. See [rendered playtests](docs/visual-playtest.md) for evidence paths,
checkpoints, and renderer requirements.

The legacy end detector is still awaiting its collider rewrite. RunLab does not
imply that collision/pass-fail behavior is correct yet.

## Formatting and code style

Format all shader files

```sh
task format-shaders
```

Other checks run w/ pre-commit

```sh
pip install pre-commit
pre-commit install
```

## Dev dependensies

### Ubuntu

```sh
sudo apt install clang-format
npm install -g @go-task/cli
```

### Windows

```sh
# for clang-format
choco install llvm
choco install go-task
```

## Build and deploy

Build the game with Docker (no host Godot or cloud assets required):

```sh
task build                    # Linux, Windows, Web, Android debug builds
task build TARGET=web         # one platform
task test-docker              # containerized GUT tests
```

Artifacts: `build/docker/<TARGET>/`. Exports currently use debug mode, including
Android debug signing. Without Task, run `./scripts/build_game.sh` with optional
`TARGET`, `GAME_VERSION`, `GAME_COMMIT`, and `DISCORD_APP_ID` environment variables.

CI publishes default-branch prereleases and tagged releases, archives them on
`remote_workstation`, and updates the live game on default-branch pushes.
See [deployment and migration](docs/deployment.md) for configuration and rollback.
Legacy `dev-build-*` tasks still use host tooling and the old output layout.

## Downloading assets

Install rclone

```sh
winget install rclone
yay -S rclone
sudo apt install rclone
```

Setup remote

```sh
task setup-rclone:USERMAIL:PASSWORD
```

Get assets from cloud

```sh
task pull-assets
```

Upload assets to cloud

```sh
task push-assets
```
