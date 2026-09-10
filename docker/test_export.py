"""Build preparation checks; no Godot or Docker required."""

import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
import subprocess

from export import godot, prepare


class ExportTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.source = self.root / "source"
        for directory in (
            "game/app", "game/services/discord", "addons/discord-rpc-gd/bin",
            "addons/gut", "dev", "test",
        ):
            (self.source / directory).mkdir(parents=True, exist_ok=True)
        (self.source / "project.godot").write_text(
            '[autoload]\nDiscordRPCLoader="*res://addons/discord-rpc-gd/nodes/discord_autoload.gd"\n'
            '[editor_plugins]\nenabled=PackedStringArray("plugin")\n'
        )
        (self.source / "export_presets.cfg").write_text('gradle_build/use_gradle_build=true\n')
        (self.source / "game/app/version.gd").write_text('const VERSION = "__VERSION__"\n')
        (self.source / "game/services/discord/DiscordStatus.gd").write_text('DiscordRPC.refresh()\n')

    def test_platform_isolation(self):
        original = (self.source / "project.godot").read_text()
        for target in ("linux", "windows", "web", "android", "test"):
            with self.subTest(target=target):
                work = self.root / target
                prepare(self.source, work, target, 'v1.0"test', "abc123", 123)
                desktop = target not in ("web", "android")
                self.assertEqual((work / "addons/discord-rpc-gd/bin").exists(), desktop)
                self.assertEqual("DiscordRPCLoader" in (work / "project.godot").read_text(), desktop)
                self.assertEqual((work / "game/services/discord/DiscordStatus.gd").exists(), desktop)
                self.assertEqual((work / "test").exists(), target == "test")
                self.assertEqual((work / "dev").exists(), target == "test")
                self.assertIn('enabled=PackedStringArray()', (work / "project.godot").read_text())
                self.assertIn('v1.0\\"test', (work / "game/app/version.gd").read_text())
                self.assertIn('DISCORD_APP_ID = 123', (work / "game/app/env.gd").read_text())
                self.assertEqual(
                    'use_gradle_build=false' in (work / "export_presets.cfg").read_text(),
                    target == "android",
                )
        self.assertEqual((self.source / "project.godot").read_text(), original)
        self.assertIn("__VERSION__", (self.source / "game/app/version.gd").read_text())
        self.assertFalse((self.source / "game/app/env.gd").exists())

    def test_godot_errors_fail_even_with_zero_exit(self):
        for output, code in (("SCRIPT ERROR: parse failed\n", 0), ("ERROR: missing file\n", 0), ("failed\n", 1)):
            with self.subTest(output=output), patch(
                'export.subprocess.run', return_value=subprocess.CompletedProcess([], code, output)
            ), self.assertRaises(SystemExit):
                godot(self.source, self.root / "engine.log", "--import")
            self.assertEqual((self.root / "engine.log").read_text(), output)

    def test_godot_success(self):
        with patch('export.subprocess.run', return_value=subprocess.CompletedProcess([], 0, "OK\n")):
            godot(self.source, self.root / "engine.log", "--import")
        self.assertEqual((self.root / "engine.log").read_text(), "OK\n")


if __name__ == "__main__":
    unittest.main()
