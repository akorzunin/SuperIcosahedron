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

### Build from linux(WSL)

NOTE: Export templates should be installed

Build for web

    godot --headless --export-release "Web" ./build/web/index.html

Build for Windows

    rm -f ./build/pc/*.exe || true && godot --headless --export-release "Windows Desktop" ./build/pc/SuperHexagon-$(./scripts/get_version.sh --short).exe

Build for linux

    rm -f ./build/linux/*.x86_64 || true && godot --headless --export-release "Linux/X11" .
/build/linux/SuperHexagon-$(./scripts/get_version.sh --short).x86_64

Build for android (need to setup Jave and Android SDK)

    rm -f ./build/android/*.apk || true && godot --headless --export-release "Andro
id" ./build/android/SuperHexagon-$(./scripts/get_version.sh --short).apk

    ansible-playbook ./deploy/dev/deploy_local.yaml -l local_pi,
