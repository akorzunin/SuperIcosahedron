"""Debug exports from disposable trees. Invoked inside docker/game.Dockerfile."""

import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

TARGETS = {
    "linux": ("Linux/X11", "SuperIcosahedron.x86_64"),
    "windows": ("Windows Desktop", "SuperIcosahedron.exe"),
    "web": ("Web", "index.html"),
    "android": ("Android", "SuperIcosahedron.apk"),
}


def prepare(source, work, target, version, commit, discord_app_id):
    shutil.copytree(source, work)
    project = work / "project.godot"
    text = project.read_text()
    # Editor plugins aren't needed for import/export and can leak on headless exit.
    text = re.sub(r'^enabled=PackedStringArray\(.*\)$', 'enabled=PackedStringArray()', text, flags=re.M)
    if target in ("web", "android"):
        text = re.sub(r'^DiscordRPCLoader=.*\n', '', text, flags=re.M)
        shutil.rmtree(work / "addons/discord-rpc-gd")
        # Desktop-only script refers to the extension's native class at parse time.
        for path in (work / "game/services/discord").glob("DiscordStatus.gd*"):
            path.unlink()
    project.write_text(text)
    (work / "game/app/version.gd").write_text(
        'extends RefCounted\n\n'
        f'const VERSION = {json.dumps(version)}\n'
        f'const COMMIT = {json.dumps(commit)}\n'
    )
    (work / "game/app/env.gd").write_text(
        f'extends RefCounted\nclass_name ENV\n\nconst DISCORD_APP_ID = {discord_app_id}\n'
    )
    if target != "test":
        shutil.rmtree(work / "dev")
        shutil.rmtree(work / "test")
        shutil.rmtree(work / "addons/gut")
    if target == "android":
        presets = work / "export_presets.cfg"
        # Prebuilt APK only: custom Android plugins will require a Gradle build path.
        presets.write_text(presets.read_text().replace(
            'gradle_build/use_gradle_build=true', 'gradle_build/use_gradle_build=false'
        ))


def godot(work, log, *args):
    result = subprocess.run(
        ["godot", "--headless", "--path", str(work), *args],
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True,
    )
    log.write_text(result.stdout)
    print(result.stdout, end="", flush=True)
    # Godot sometimes reports script failures with a successful process exit.
    if result.returncode or "SCRIPT ERROR:" in result.stdout or "ERROR:" in result.stdout:
        raise SystemExit(f"Godot failed; see {log}")


def main():
    target = sys.argv[1] if len(sys.argv) == 2 else ""
    if target not in (*TARGETS, "all", "test"):
        raise SystemExit("Target must be linux, windows, web, android, all, or test")
    version = os.environ.get("GAME_VERSION", "dev")
    commit = os.environ.get("GAME_COMMIT", "unknown")
    app_id = os.environ.get("DISCORD_APP_ID", "0")
    if not app_id.isascii() or not app_id.isdecimal() or int(app_id) > 2**63 - 1:
        raise SystemExit("DISCORD_APP_ID must be a nonnegative signed 64-bit integer")
    out = Path("/out")
    logs = out / "logs"
    logs.mkdir(parents=True)
    targets = list(TARGETS) if target == "all" else [target]
    for name in targets:
        work = Path("/work") / name
        prepare(Path("/source"), work, name, version, commit, int(app_id))
        godot(work, logs / f"{name}-import.log", "--editor", "--import")
        if name == "test":
            godot(work, logs / "gut.log", "-s", "addons/gut/gut_cmdln.gd",
                  "-gdir=res://test", "-ginclude_subdirs", "-gexit")
        else:
            preset, filename = TARGETS[name]
            destination = out / name / filename
            destination.parent.mkdir()
            godot(work, logs / f"{name}-export.log", "--export-debug", preset, str(destination))
            if not destination.is_file() or not destination.stat().st_size:
                raise SystemExit(f"Missing export: {destination}")
        shutil.rmtree(work)
    (out / "build-info.json").write_text(json.dumps({
        "version": version, "commit": commit, "godot": os.environ["GODOT_VERSION"],
        "mode": "debug", "targets": targets, "discord_app_id": int(app_id),
    }, indent=2) + "\n")


if __name__ == "__main__":
    main()
