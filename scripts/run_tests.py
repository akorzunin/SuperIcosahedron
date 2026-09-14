"""Run GUT files in parallel; successful runs stay silent."""

import json
import os
import subprocess
import tempfile
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def run(args, env=None):
    result = subprocess.run(
        ["godot", "--headless", "--path", str(ROOT), *args],
        cwd=ROOT, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        text=True,
    )
    # Godot can report script errors while returning success.
    failed = result.returncode != 0 or "SCRIPT ERROR:" in result.stdout
    # Editor plugins leak resources on import exit; only script errors are fatal there.
    if "--import" not in args:
        failed = failed or "ERROR:" in result.stdout
    return failed, result.stdout


def run_test(path):
    with tempfile.TemporaryDirectory(prefix="gut-") as directory:
        temp = Path(directory)
        config = json.loads((ROOT / ".gutconfig.json").read_text())
        config.update(dirs=[], configured_dirs=[], tests=["res://" + path.as_posix()],
                      log_level=0, disable_colors=True)
        config_path = temp / "gut.json"
        config_path.write_text(json.dumps(config))
        # Linux user:// isolation prevents parallel suites sharing saves/settings.
        env = dict(os.environ, XDG_DATA_HOME=str(temp / "data"),
                   XDG_CONFIG_HOME=str(temp / "config"), XDG_CACHE_HOME=str(temp / "cache"))
        # Preserve 60 Hz simulation steps without waiting for wall-clock time.
        # Menu-flow input assertions fail without real-time pacing; keep that
        # suite paced until its input synchronization supports fixed-step runs.
        timing = [] if path.name == "test_main_menu_flow.gd" else ["--fixed-fps", "60"]
        return run([*timing, "-s", "addons/gut/gut_cmdln.gd",
                    f"-gconfig={config_path}", "-gexit"], env)


def main():
    jobs = int(os.environ.get("TEST_JOBS", min(4, os.cpu_count() or 1)))
    if jobs < 1:
        raise SystemExit("TEST_JOBS must be positive")
    tests = sorted(path.relative_to(ROOT) for path in (ROOT / "test").rglob("test_*.gd"))
    if not tests:
        raise SystemExit("No test files found")
    failed, output = run(["--import"])
    if failed:
        print(output, end="")
        return 1
    failures = 0
    with ThreadPoolExecutor(max_workers=jobs) as pool:
        futures = {pool.submit(run_test, path): path for path in tests}
        for future in as_completed(futures):
            failed, output = future.result()
            if failed:
                failures += 1
                print(f"FAIL: {futures[future]}\n{output}", flush=True)
    return int(failures > 0)


if __name__ == "__main__":
    raise SystemExit(main())
