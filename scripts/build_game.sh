#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

TARGET=${TARGET:-all}
case "$TARGET" in
    linux|windows|web|android|all|test) ;;
    *) echo "Invalid TARGET: $TARGET (use linux, windows, web, android, all, test)" >&2; exit 2 ;;
esac
# Explicit metadata also supports source archives without .git (e.g. future CI).
GAME_VERSION=${GAME_VERSION:-$(git describe --tags --always --dirty 2>/dev/null || printf dev)}
GAME_COMMIT=${GAME_COMMIT:-$(git rev-parse HEAD 2>/dev/null || printf unknown)}

signing_args=()
if [[ "$TARGET" == android || "$TARGET" == all ]]; then
    keystore=${ANDROID_DEBUG_KEYSTORE:-${XDG_DATA_HOME:-$HOME/.local/share}/godot/keystores/debug.keystore}
    if [[ ! -r "$keystore" ]]; then
        echo "Missing Android debug keystore: $keystore (set ANDROID_DEBUG_KEYSTORE; see docs/deployment.md)" >&2
        exit 1
    fi
    # BuildKit secret contents do not invalidate cached exports by themselves.
    keystore_hash=$(sha256sum "$keystore")
    signing_args=(
        --secret "id=android_debug_keystore,src=$keystore"
        --build-arg "ANDROID_DEBUG_KEYSTORE_SHA256=${keystore_hash%% *}"
    )
fi

docker buildx build \
    "${signing_args[@]}" \
    --platform linux/amd64 \
    --file docker/game.Dockerfile \
    --target artifacts \
    --build-arg "TARGET=$TARGET" \
    --build-arg "GAME_VERSION=$GAME_VERSION" \
    --build-arg "GAME_COMMIT=$GAME_COMMIT" \
    --build-arg "DISCORD_APP_ID=${DISCORD_APP_ID:-}" \
    --output "type=local,dest=build/docker/$TARGET" \
    .
