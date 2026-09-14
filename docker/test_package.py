import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile
import tempfile
import unittest
import zipfile


SCRIPT = Path(__file__).resolve().parents[1] / "scripts/package_build.py"


class PackageTests(unittest.TestCase):
    def test_bundle_and_checksums(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source, output = root / "exports", root / "release"
            source.mkdir()
            info = {"version": "dev-1-abc", "commit": "abc", "mode": "debug"}
            (source / "build-info.json").write_text(json.dumps(info))
            for target in ("linux", "windows", "web", "android"):
                (source / target).mkdir()
                (source / target / "payload").write_bytes(b"game")
            subprocess.run([sys.executable, SCRIPT, source, output], check=True)
            for line in (output / "SHA256SUMS").read_text().splitlines():
                digest, name = line.split()
                self.assertEqual(hashlib.sha256((output / name).read_bytes()).hexdigest(), digest)
            with tarfile.open(output / "deploy.tar.gz") as bundle:
                self.assertIn("web/payload", bundle.getnames())
                self.assertEqual(json.load(bundle.extractfile("build-info.json")), info)
                self.assertNotIn("deploy.tar.gz", bundle.getnames())
            with zipfile.ZipFile(output / "linux.zip") as archive:
                self.assertEqual(archive.read("payload"), b"game")
            # Output is immutable: a second packaging pass must not overwrite it.
            result = subprocess.run([sys.executable, SCRIPT, source, output], capture_output=True)
            self.assertNotEqual(result.returncode, 0)

    def test_missing_export_fails(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / "build-info.json").write_text('{}')
            result = subprocess.run(
                [sys.executable, SCRIPT, root, root / "release"], capture_output=True
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertFalse((root / "release/deploy.tar.gz").exists())


if __name__ == "__main__":
    unittest.main()
