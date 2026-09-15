import hashlib
import json
import subprocess
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/package_build.py"


class PackageTests(unittest.TestCase):
    def test_release_assets_and_checksums(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source, output = root / "exports", root / "release"
            source.mkdir()
            info = {"version": "dev-1-abc", "commit": "abc", "mode": "debug"}
            (source / "build-info.json").write_text(json.dumps(info))
            for target in ("linux", "windows", "web", "android"):
                (source / target).mkdir()
                if target == "android":
                    (source / target / "SuperIcosahedron.apk").write_bytes(b"apk")
                    (source / target / "SuperIcosahedron.apk.idsig").write_bytes(
                        b"signature"
                    )
                else:
                    (source / target / "payload").write_bytes(b"game")
            subprocess.run([sys.executable, SCRIPT, source, output], check=True)
            self.assertFalse((output / "android.zip").exists())
            android_files = {
                "SuperIcosahedron.apk": b"apk",
                "SuperIcosahedron.apk.idsig": b"signature",
            }
            checksums = (output / "SHA256SUMS").read_text()
            for name, content in android_files.items():
                self.assertEqual((output / name).read_bytes(), content)
                self.assertIn(f"  {name}\n", checksums)
            for line in checksums.splitlines():
                digest, name = line.split()
                self.assertEqual(
                    hashlib.sha256((output / name).read_bytes()).hexdigest(), digest
                )
            self.assertEqual(
                {path.name for path in output.iterdir()},
                {
                    "linux.zip",
                    "windows.zip",
                    "build-info.json",
                    "SHA256SUMS",
                    *android_files,
                },
            )
            self.assertEqual(json.loads((output / "build-info.json").read_text()), info)
            with zipfile.ZipFile(output / "linux.zip") as archive:
                self.assertEqual(archive.read("payload"), b"game")
            # Output is immutable: a second packaging pass must not overwrite it.
            result = subprocess.run(
                [sys.executable, SCRIPT, source, output],
                capture_output=True,
                check=False,
            )
            self.assertNotEqual(result.returncode, 0)

    def test_missing_export_fails(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / "build-info.json").write_text("{}")
            result = subprocess.run(
                [sys.executable, SCRIPT, root, root / "release"],
                capture_output=True,
                check=False,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertFalse((root / "release/deploy.tar.gz").exists())


if __name__ == "__main__":
    unittest.main()
