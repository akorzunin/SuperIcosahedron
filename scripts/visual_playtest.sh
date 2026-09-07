#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Fresh evidence per run: a failed launch must never look like old passing output.
mkdir -p build/visual-playtest
touch build/visual-playtest/.gdignore
output="$(mktemp -d "$PWD/build/visual-playtest/run.XXXXXX")"
printf 'Visual playtest evidence: %s\n' "$output"

# timeout bounds hangs (including script errors before a report can be written).
# Rendering uses the project default unless explicit Godot flags are supplied.
status=0
timeout 120s godot --headless --path . --import \
    >"$output/import.log" 2>&1 || status=$?
# Editor plugins currently emit shutdown-leak errors. Keep the import log, but
# gate errors strictly in the runtime log; gate import errors too once plugins are fixed.
if [[ "$status" -eq 0 ]]; then
    timeout 120s godot --path . --windowed --resolution 1280x720 \
        --fixed-fps 60 --audio-driver Dummy --disable-vsync \
        --log-file "$output/engine.log" "$@" \
        res://dev/visual/VisualPlaytest.tscn -- --output="$output" \
        >"$output/runtime.log" 2>&1 || status=$?
else
    status=1
fi

if [[ "$status" -ne 0 ]] || [[ ! -s "$output/report.json" ]] || \
    grep -Eq 'SCRIPT ERROR:|ERROR:' "$output/runtime.log"; then
    printf 'Visual playtest FAILED or incomplete. Inspect logs: %s\n' "$output" >&2
    exit 1
fi
printf 'State checks passed; visual review is still REQUIRED.\n'
printf 'Open %s/{rotation,run}_contact_sheet.png and report.json\n' "$output"
