import json
import subprocess
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class HarnessTests(unittest.TestCase):
    def test_verifier_passes(self):
        result = subprocess.run(
            [sys.executable, str(ROOT / "scripts" / "verify_harness.py")],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_official_sources_are_unique_and_https(self):
        payload = json.loads((ROOT / "config" / "official-sources.json").read_text(encoding="utf-8"))
        urls = [source["url"] for source in payload["sources"]]
        self.assertGreaterEqual(len(urls), 30)
        self.assertEqual(len(urls), len(set(urls)))
        self.assertTrue(all(url.startswith("https://docs.thucchien.ai/docs/round-2") for url in urls))

    def test_workspace_boundaries_exist(self):
        for relative in ("workspace/product", "workspace/evidence", "workspace/submission"):
            self.assertTrue((ROOT / relative).is_dir(), relative)


if __name__ == "__main__":
    unittest.main()
