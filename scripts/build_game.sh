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

docker buildx build \
    --platform linux/amd64 \
    --file docker/game.Dockerfile \
    --target artifacts \
    --build-arg "TARGET=$TARGET" \
    --build-arg "GAME_VERSION=$GAME_VERSION" \
    --build-arg "GAME_COMMIT=$GAME_COMMIT" \
    --build-arg "DISCORD_APP_ID=${DISCORD_APP_ID:-0}" \
    --output "type=local,dest=build/docker/$TARGET" \
    .
