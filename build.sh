#!/usr/bin/env bash
set -euo pipefail

PLATFORM="${1:-all}"
BUILD_TYPE="${2:-debug}"

case "$BUILD_TYPE" in
    debug)   EXPORT_FLAG="--export-debug" ;;
    release) EXPORT_FLAG="--export-release" ;;
    *)
        echo "Invalid BUILD_TYPE: $BUILD_TYPE (must be debug or release)"
        exit 1
        ;;
esac

case "$PLATFORM" in
    all|linux|windows|web|android) ;;
    *)
        echo "Invalid PLATFORM: $PLATFORM (must be all, linux, windows, web, or android)"
        exit 1
        ;;
esac

echo "=== Building $PLATFORM ($BUILD_TYPE) ==="

git config --global --add safe.directory /project

python3 scripts/on_build.py --prebuild

cleanup() {
    echo "=== Cleanup ==="
    git checkout -- src/version.gd project.godot
}
trap cleanup EXIT

if [[ "$PLATFORM" == "all" || "$PLATFORM" == "linux" || "$PLATFORM" == "windows" ]]; then
    mkdir -p build/linux build/pc
fi

if [[ "$PLATFORM" == "all" || "$PLATFORM" == "web" || "$PLATFORM" == "android" ]]; then
    mkdir -p build/web build/android
fi

if [[ "$PLATFORM" == "all" || "$PLATFORM" == "linux" ]]; then
    echo "=== Export: Linux/X11 ==="
    godot --headless ${EXPORT_FLAG} "Linux/X11" build/linux/SuperIcosahedron.x86_64
fi

if [[ "$PLATFORM" == "all" || "$PLATFORM" == "windows" ]]; then
    echo "=== Export: Windows Desktop ==="
    godot --headless ${EXPORT_FLAG} "Windows Desktop" build/pc/SuperIcosahedron.exe
fi

if [[ "$PLATFORM" == "all" || "$PLATFORM" == "web" || "$PLATFORM" == "android" ]]; then
    echo "=== Disabling Discord RPC ==="
    git apply scripts/no-discord-rpc-project.godot.diff || true
fi

if [[ "$PLATFORM" == "all" || "$PLATFORM" == "web" ]]; then
    echo "=== Export: Web ==="
    godot --headless ${EXPORT_FLAG} "Web" build/web/index.html
fi

if [[ "$PLATFORM" == "all" || "$PLATFORM" == "android" ]]; then
    echo "=== Export: Android ==="
    godot --headless ${EXPORT_FLAG} "Android" build/android/Supericosahedron.apk
fi

if [[ "$PLATFORM" == "all" || "$PLATFORM" == "web" || "$PLATFORM" == "android" ]]; then
    echo "=== Re-enabling Discord RPC ==="
    git apply scripts/no-discord-rpc-project.godot.diff --reverse || true
fi

if [[ -n "${HOST_UID:-}" && -n "${HOST_GID:-}" ]]; then
    find build -type f -exec chown "${HOST_UID}:${HOST_GID}" {} + 2>/dev/null || true
    find build -type d -exec chown "${HOST_UID}:${HOST_GID}" {} + 2>/dev/null || true
fi

echo "=== Build complete ==="
