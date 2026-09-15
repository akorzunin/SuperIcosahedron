#!/usr/bin/env python3
"""Package Docker exports once for GitHub Releases and host deployment."""

import hashlib
import json
import shutil
import sys
from pathlib import Path


def main():
    source, output = map(Path, sys.argv[1:])
    info = json.loads((source / "build-info.json").read_text())
    output.mkdir(parents=True, exist_ok=False)
    for target in ("linux", "windows", "android"):
        directory = source / target
        if not directory.is_dir() or not any(directory.iterdir()):
            raise SystemExit(f"Missing export: {directory}")
        if target == "android":
            for path in directory.iterdir():
                shutil.copy2(path, output / path.name)
        else:
            shutil.make_archive(str(output / target), "zip", directory)
    shutil.copy2(source / "build-info.json", output / "build-info.json")
    checksums = []
    for path in sorted(output.iterdir()):
        with path.open("rb") as stream:
            digest = hashlib.file_digest(stream, "sha256").hexdigest()
        checksums.append(f"{digest}  {path.name}\n")
    (output / "SHA256SUMS").write_text("".join(checksums))
    print(f"Packaged {info['version']} ({info['mode']})")


if __name__ == "__main__":
    main()
