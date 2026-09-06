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
task test          # GUT unit + integration tests
```

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

```sh
    task deploy-build-dev
```

### Build from linux(WSL)

NOTE: Export templates should be installed

dev build

```sh
    task dev-build-all
```

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
