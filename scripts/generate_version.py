#!/usr/bin/env python
import subprocess
import json


# Function to execute shell command and return output
def execute_shell_command(command):
    result = subprocess.run(
        command,
        capture_output=True,
        text=True,
        shell=True,
    )
    return result.stdout.strip()


def main():

    # Get version and commit information
    version = execute_shell_command("./scripts/get_version.sh --tag")
    commit = execute_shell_command("./scripts/get_version.sh --short")

    # Create JSON object
    game_version = {
        "version": version,
        "commit": commit,
    }
    # Write JSON object to file
    with open("./build/latest_version.json", "w") as f:
        json.dump(game_version, f, indent=4)
    print(f"GameVersion {version} {commit} saved to latest_version.json")


if __name__ == "__main__":
    main()
