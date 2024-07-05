"""Script to get cnfgi file located at user:// space"""

import os
import sys
import argparse
from pathlib import Path

app_name = "SuperIcosahedron"
config_name = "settings.cfg"
opener = "xdg-open"
default_config = Path("./src/components/settings/default_settings.cfg")


def get_config_path(project_name: str) -> Path:
    if sys.platform.startswith("win"):
        path = Path(os.getenv("APPDATA")) / "Godot" / "app_userdata" / project_name # type: ignore
    elif sys.platform == "darwin":
        path = (
            Path.home()
            / "Library"
            / "Application Support"
            / "Godot"
            / "app_userdata"
            / project_name
        )
    else:
        path = (
            Path.home() / ".local" / "share" / "godot" / "app_userdata" / project_name
        )
    return path


def main():
    parser = argparse.ArgumentParser(description="Find or Open Godot Project Config")
    parser.add_argument(
        "-p",
        "--project",
        required=False,
        help="Project Name",
        default=app_name,
    )
    parser.add_argument(
        "-s",
        "--show",
        action="store_true",
        help="Show Config File Path",
    )
    parser.add_argument(
        "-o",
        "--open",
        action="store_true",
        help="Open Config File",
    )
    parser.add_argument(
        "-e",
        "--editor",
        action="store_true",
        help="Set editor",
        default=opener,
    )
    parser.add_argument(
        "-d",
        "--default",
        action="store_true",
        help="Use default config",
    )

    args = parser.parse_args()

    project_path = get_config_path(args.project)
    config_file = project_path / config_name
    if args.default:
        config_file = default_config

    if args.open:
        try:
            if sys.platform.startswith("win") and args.editor == opener:
                os.startfile(config_file)
            else:
                os.system(f"{args.editor} {config_file}")
        except Exception as e:
            print(f"Error opening file: {e}")
    elif args.show:
        print(f"Config File Path: {config_file}")
    elif len(sys.argv) == 1:
        print(config_file)


if __name__ == "__main__":
    main()
