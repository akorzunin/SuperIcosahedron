# SuperIcosahedron

Indie arcade game made with Godot engine.
Players navigate through a mesmerizing journey of rotating icosahedrons,
aligning spots to progress to the next challenge. Its minimalist aesthetic
complements the intricate gameplay, offering a unique blend of skill and strategy.

Game mostly inspired by Super Hexagon

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

    task deploy-build-dev

### Build from linux(WSL)

NOTE: Export templates should be installed

dev build

    task dev-build-all

## Downloading assets

Install rclone

    winget install rclone

Configure connection w/ GUI in Configs>Create

    rclone rcd --rc-web-gui

Get assets from cloud

    task get-assets

Upload new assets

    task push-assets
