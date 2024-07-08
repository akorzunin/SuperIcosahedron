"""Some pre build checks"""

import argparse
import fileinput
import os
import sys

main_scene = "res://src/scenes/MainScene.tscn"
version_file = "./src/version.gd"


def check_main_scene():
    with open("project.godot") as f:
        for line in f.readlines():
            if line.startswith("run/main_scene="):
                # check scene name
                scene_name = line.split("=")[-1].strip("\n").strip('"')
                if scene_name != main_scene:
                    raise SystemExit(f"Incorrect main scene: {scene_name}")
                break
        else:
            raise SystemExit("main_scene field not found")
        print("main_scene: OK")


def get_version():
    return (
        os.popen("git describe --tags $(git rev-list --tags --max-count=1)")
        .read()
        .strip()
    )


def get_commit():
    return os.popen("git rev-parse --short --verify HEAD").read().strip()


def set_version():
    version = get_version()
    commit = get_commit()
    for line in fileinput.input(version_file, inplace=True):
        if "VERSION" in line:
            new_line = line.replace("__VERSION__", version)
        elif "COMMIT" in line:
            new_line = line.replace("__COMMIT__", commit)
        else:
            new_line = line
        print(new_line, end="")


def clear_version():
    version = get_version()
    commit = get_commit()
    for line in fileinput.input(version_file, inplace=True):
        if "VERSION" in line:
            new_line = line.replace(version, "__VERSION__")
        elif "COMMIT" in line:
            new_line = line.replace(commit, "__COMMIT__")
        else:
            new_line = line
        print(new_line, end="")


def main():
    parser = argparse.ArgumentParser(description="Run scripts before and after build")
    parser.add_argument(
        "-p",
        "--prebuild",
        action="store_true",
        help="run pre build script",
    )
    parser.add_argument(
        "-c",
        "--cleanup",
        action="store_true",
        help="run clean up script",
    )

    args = parser.parse_args()
    if args.prebuild or len(sys.argv) == 1:
        print("running prebuild script")
        check_main_scene()
        set_version()
    elif args.cleanup:
        print("running cleanup script")
        clear_version()


if __name__ == "__main__":
    main()
