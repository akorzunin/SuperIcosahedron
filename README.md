# SuperIcosahedron

Game written w/ Godot and inspired by Super Hexagon

# Utils

## GdShader formatting

Create config

```sh
clang-format -style='{UseTab : false, IndentWidth : 4, TabWidth : 4}' -dump-config > .clang-format
```

Format all .gdshader files

```sh
task format-shaders
```

## Installs

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
