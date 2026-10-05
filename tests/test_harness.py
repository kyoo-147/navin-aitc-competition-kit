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

    def test_competition_budget_policy_is_bounded(self):
        policy = json.loads(
            (ROOT / "config" / "competition" / "budget-policy.json").read_text(encoding="utf-8")
        )
        self.assertEqual(sum(policy["envelopes"].values()), policy["team_budget"])
        thresholds = policy["thresholds"]
        self.assertLess(thresholds["leader_review"], thresholds["economy_mode"])
        self.assertLess(thresholds["economy_mode"], thresholds["nonessential_hard_stop"])
        self.assertLess(thresholds["nonessential_hard_stop"], policy["team_budget"])

    def test_router_policy_has_ordered_tiers(self):
        policy = json.loads(
            (ROOT / "config" / "competition" / "router-policy.json").read_text(encoding="utf-8")
        )
        self.assertEqual(list(policy["tiers"]), ["T0", "T1", "T2", "T3", "T4"])
        self.assertFalse(policy["tiers"]["T0"]["model_required"])
        self.assertIn("leader_approval", policy["tiers"]["T4"]["requires"])
        self.assertTrue(policy["retry"]["never_retry_auth_failure"])

    def test_model_snapshot_is_explicitly_non_authoritative(self):
        catalog = json.loads(
            (ROOT / "config" / "competition" / "model-catalog.snapshot.json").read_text(encoding="utf-8")
        )
        self.assertEqual(catalog["status"], "SNAPSHOT_NOT_RUNTIME_ALLOWLIST")
        model_ids = [model["id"] for model in catalog["text_models"]]
        self.assertEqual(len(model_ids), len(set(model_ids)))
        self.assertGreater(len(model_ids), 10)

    def test_workspace_boundaries_exist(self):
        for relative in ("workspace/product", "workspace/evidence", "workspace/submission"):
            self.assertTrue((ROOT / relative).is_dir(), relative)


if __name__ == "__main__":
    unittest.main()
