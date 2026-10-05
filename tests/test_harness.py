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

    def test_reusable_kit_policies_match_team_rules(self):
        routing = json.loads((ROOT / "kit" / "config" / "routing.json").read_text(encoding="utf-8"))
        budget = json.loads((ROOT / "kit" / "config" / "budget.json").read_text(encoding="utf-8"))
        self.assertEqual(routing["provider"]["environment_key"], "THUCCHIEN_API_KEY")
        self.assertEqual(routing["provider"]["wire_api"], "responses")
        self.assertTrue(routing["policy"]["gateway_only"])
        self.assertFalse(routing["policy"]["personal_provider_fallback"])
        self.assertEqual(budget["gates"], {
            "leader_review": 35,
            "economy_mode": 42,
            "block_nonessential": 45,
        })
        self.assertEqual(sum(budget["planning_envelope"].values()), budget["organizer_cap"])

    def test_official_training_screenshots_are_preserved(self):
        screenshots = list((ROOT / "kit" / "references" / "official-training" / "screenshots").glob("*.png"))
        self.assertEqual(len(screenshots), 23)
        self.assertFalse(any(path.name.startswith("_contact_") for path in screenshots))

    def test_kit_uses_organizer_credential_names(self):
        deprecated = ("AITC_" + "AGENT_KEY", "AITC_" + "PRODUCT_KEY", "AITC_" + "LOG_KEY")
        for path in (ROOT / "kit").rglob("*"):
            if not path.is_file() or "source-material" in path.parts or path.suffix.lower() not in {".md", ".json", ".ps1", ".toml"}:
                continue
            text = path.read_text(encoding="utf-8", errors="replace")
            for name in deprecated:
                self.assertNotIn(name, text, str(path.relative_to(ROOT)))

    def test_workspace_boundaries_exist(self):
        for relative in ("workspace/product", "workspace/evidence", "workspace/submission"):
            self.assertTrue((ROOT / relative).is_dir(), relative)


if __name__ == "__main__":
    unittest.main()
