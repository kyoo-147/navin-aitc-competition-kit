import hashlib
import json
import subprocess
import tempfile
import shutil
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class HarnessTests(unittest.TestCase):
    def run_powershell(self, script, *args, cwd=None):
        return subprocess.run(
            ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(script), *map(str, args)],
            cwd=cwd or ROOT, text=True, capture_output=True, check=False,
        )

    def make_gate_fixture(self, base, mode="DRILL", ui=True):
        repo = Path(base) / "repo"
        project = repo / ("chung-khao" if mode == "OFFICIAL" else ".")
        project.mkdir(parents=True)
        for relative in (
            "docs/PROJECT.md", "docs/ARCHITECTURE.md", "docs/UX_FLOW.md", "docs/DECISIONS.md", "docs/TASKS.md",
            "contracts/app-contract.json", "artifacts/architecture.html", "artifacts/ux-flow.html",
        ):
            target = project / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / relative, target)
        contract = json.loads((ROOT / "docs/PROJECT_CONTRACT.json").read_text(encoding="utf-8"))
        contract["scope"]["project_relative_root"] = "chung-khao" if mode == "OFFICIAL" else "."
        contract["screens"]["kind"] = "UI" if ui else "CLI_ONLY"
        contract["screens"]["design_lock_required"] = ui
        if not ui:
            contract["screens"].pop("design_contract", None)
        contract_path = project / "docs/PROJECT_CONTRACT.json"
        contract_path.write_text(json.dumps(contract, indent=2) + "\n", encoding="utf-8")
        if ui:
            for relative in ("DESIGN_BRIEF.md", "DESIGN_SYSTEM.md", "SCREEN_CONTRACTS.md", "COMPONENTS.md", "TOKENS.css", "DESIGN_LOCK.json"):
                target = project / "design" / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(ROOT / "design" / relative, target)
        subprocess.run(["git", "init", "-q", str(repo)], check=True)
        subprocess.run(["git", "-C", str(repo), "config", "user.name", "Fixture"], check=True)
        subprocess.run(["git", "-C", str(repo), "config", "user.email", "fixture@example.invalid"], check=True)
        subprocess.run(["git", "-C", str(repo), "remote", "add", "origin", "https://github.com/ai-thuc-chien/aitc2026-team-918-navin-research.git"], check=True)
        subprocess.run(["git", "-C", str(repo), "add", "."], check=True)
        subprocess.run(["git", "-C", str(repo), "commit", "-qm", "fixture"], check=True)
        return repo, project

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
        thresholds = policy["thresholds"]
        self.assertLess(thresholds["leader_review"], thresholds["economy_mode"])
        self.assertLess(thresholds["economy_mode"], thresholds["nonessential_hard_stop"])
        self.assertLess(thresholds["nonessential_hard_stop"], policy["team_budget"])

    def test_router_policy_has_ordered_tiers(self):
        policy = json.loads(
            (ROOT / "config" / "competition" / "router-policy.json").read_text(encoding="utf-8")
        )
        self.assertEqual(list(policy["tiers"]), ["T0", "T1", "T2", "T3"])
        self.assertFalse(policy["tiers"]["T0"]["model_required"])
        self.assertEqual(policy["tiers"]["T3"]["selection"], "gpt-5.6-sol, only after evidence and only when the cheaper route is insufficient")
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
            "cap_reached": 50,
        })
        self.assertTrue(budget["policy"].startswith("Use total observed team spend thresholds"))

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

    def test_codex_runtime_flow_is_source_controlled(self):
        required = (
            "kit/scripts/codex-runtime-refresh.ps1",
            "kit/scripts/session-preflight.ps1",
            "kit/templates/codex-orca.cmd",
            "kit/docs/CODEX-SCOPES-AND-PI-MIGRATION.md",
        )
        for relative in required:
            self.assertTrue((ROOT / relative).is_file(), relative)

        wrapper = (ROOT / "kit/templates/codex-orca.cmd").read_text(encoding="utf-8")
        self.assertIn("app-server daemon restart", wrapper)
        self.assertIn("AITC_REFRESH_RC", wrapper)
        runtime = (ROOT / "kit/scripts/codex-runtime-refresh.ps1").read_text(encoding="utf-8")
        self.assertIn("fingerprint", runtime)
        self.assertIn("exit 10", runtime)

    def test_competition_skills_include_runtime_evidence(self):
        skill_root = ROOT / "kit/skills"
        expected = {
            "aitc-captain", "aitc-worker", "aitc-reviewer", "aitc-design-studio",
            "accessibility", "best-practices", "commit", "create-cli",
            "frontend-design", "performance", "playwright-cli", "summarize",
            "github", "update-changelog", "taste-skill", "frontend-design-v2",
            "minimalist-skill", "lavish", "chrome-devtools-axi",
        }
        self.assertEqual({path.name for path in skill_root.iterdir() if path.is_dir()}, expected)
        combined = "\n".join((path / "SKILL.md").read_text(encoding="utf-8") for path in skill_root.iterdir())
        self.assertIn("session_meta.model_provider", combined)
        self.assertIn("turn_started", combined)
        self.assertIn("UserPromptSubmit", combined)
        self.assertIn("deepseek-flash", combined)
        skills_manifest = json.loads((ROOT / "manifests/skills.json").read_text(encoding="utf-8"))
        self.assertEqual(set(skills_manifest["profile_allowlists"]["Aitc"]), {
            "aitc-captain", "aitc-worker", "aitc-reviewer", "aitc-design-studio",
            "lavish", "chrome-devtools-axi", "playwright-cli",
        })
        self.assertIn("profile_allowlists", (ROOT / "setup/bootstrap.ps1").read_text(encoding="utf-8"))

    def test_aitc_profile_installs_only_allowlisted_skills(self):
        with tempfile.TemporaryDirectory() as tmp:
            result = self.run_powershell(ROOT / "setup/bootstrap.ps1", "-Profile", "Aitc", "-CodexHome", tmp, "-Apply")
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            installed = {path.name for path in (Path(tmp) / "skills").iterdir() if path.is_dir()}
            self.assertEqual(installed, {"aitc-captain", "aitc-worker", "aitc-reviewer", "aitc-design-studio", "lavish", "chrome-devtools-axi", "playwright-cli"})

    def test_competition_engineering_loop_is_bounded_and_evidence_driven(self):
        loop = (ROOT / "kit/docs/ENGINEERING-LOOP.md").read_text(encoding="utf-8")
        captain = (ROOT / "kit/skills/aitc-captain/SKILL.md").read_text(encoding="utf-8")
        worker = (ROOT / "kit/skills/aitc-worker/SKILL.md").read_text(encoding="utf-8")
        reviewer = (ROOT / "kit/skills/aitc-reviewer/SKILL.md").read_text(encoding="utf-8")
        self.assertIn("at most one to three questions", loop)
        self.assertIn("Never exceed two concurrent writers", loop)
        self.assertIn("GLOSSARY.md", captain)
        self.assertIn("public seam", worker)
        self.assertIn("three to five falsifiable hypotheses", worker)
        self.assertIn("git diff <fixed-point>...HEAD", reviewer)
        self.assertIn("Do not merge or rerank", reviewer)
        self.assertIn("Architecture Lavish LOCK + UX / Design Lavish LOCK", loop)
        self.assertIn("implementation-gate.ps1", captain)
        self.assertIn("Locked decisions cannot be changed by workers", captain)
        rules = (ROOT / "kit/RULES.md").read_text(encoding="utf-8")
        self.assertIn("Anh đang thi chính thức hay drill/chuẩn bị?", rules)
        self.assertIn("Exactly two user-reviewable Lavish artifacts", rules)
        self.assertIn("minute 40-50", rules)
        self.assertIn("PROJECT_CONTRACT.json", rules)
        self.assertIn("app-contract.json", rules)
        self.assertIn("Browser automation safety", rules)
        self.assertIn("A failed attach is a hard stop", rules)
        for relative in (
            "kit/templates/PRODUCT_SPEC.md", "kit/templates/GLOSSARY.md",
            "kit/templates/ADR.md", "kit/templates/VERTICAL_SLICE.md",
            "kit/templates/SHORT_RETRO.md", "kit/templates/SPEC_BROKER.md",
            "kit/templates/PROJECT.md", "kit/templates/ARCHITECTURE.md",
            "kit/templates/UX_FLOW.md", "kit/templates/DECISIONS.md",
            "kit/templates/TASKS.md", "kit/templates/PROJECT_LOCK.template.json",
            "kit/templates/PROJECT_CONTRACT.template.json", "kit/templates/APP_CONTRACT.template.json",
        ):
            self.assertTrue((ROOT / relative).is_file(), relative)

    def test_portable_setup_is_source_controlled_and_safe_by_default(self):
        required = (
            "setup/bootstrap.ps1", "setup/doctor.ps1", "setup/rollback.ps1",
            "setup/update.ps1", "setup/uninstall.ps1", "setup/restore-machine-profile.ps1",
            "setup/export-safe-profile.ps1", "setup/verify-portable.ps1",
            "setup/update-portable-manifest.ps1", "setup/README.md", "setup/MACHINE-REPLICATION.md",
            "profiles/codex/AGENTS.md", "profiles/codex/config.normal.template.toml",
            "profiles/codex/config.aitc.template.toml", "manifests/tools.json",
            "manifests/skills.json", "manifests/portable-files.json", "SECURITY.md",
        )
        for relative in required:
            self.assertTrue((ROOT / relative).is_file(), relative)
        bootstrap = (ROOT / "setup/bootstrap.ps1").read_text(encoding="utf-8")
        self.assertIn("[switch]$Apply", bootstrap)
        self.assertIn("PLAN ONLY", bootstrap)
        self.assertIn("ReplaceConfig", bootstrap)
        doctor = (ROOT / "setup/doctor.ps1").read_text(encoding="utf-8")
        self.assertIn("Browser auto-attach environment is disabled", doctor)
        self.assertIn("value not displayed", doctor)
        security = (ROOT / "SECURITY.md").read_text(encoding="utf-8")
        self.assertIn("Never commit or export", security)
        self.assertIn("One failed attachment attempt is a hard stop", security)

    def test_machine_replication_restores_reviewed_user_skills(self):
        with tempfile.TemporaryDirectory() as tmp:
            result = self.run_powershell(
                ROOT / "setup/restore-machine-profile.ps1",
                "-Profile", "Aitc", "-CodexHome", tmp,
                "-RestoreUserSkills", "-ReplaceConfig", "-Apply",
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            expected = {path.name for path in (ROOT / "profiles/codex/skills").iterdir() if path.is_dir()}
            installed = {path.name for path in (Path(tmp) / "skills").iterdir() if path.is_dir()}
            self.assertEqual(installed, expected)
            self.assertNotIn(".system", installed)
            self.assertIn("Machine profile restoration completed", result.stdout)

    def test_workspace_boundaries_exist(self):
        for relative in ("workspace/product", "workspace/evidence", "workspace/submission"):
            self.assertTrue((ROOT / relative).is_dir(), relative)


    def test_canonical_contract_graph_and_lock_have_no_drift(self):
        contract = json.loads((ROOT / "docs/PROJECT_CONTRACT.json").read_text(encoding="utf-8"))
        boundary = json.loads((ROOT / "contracts/app-contract.json").read_text(encoding="utf-8"))
        lock = json.loads((ROOT / "docs/PROJECT_LOCK.json").read_text(encoding="utf-8"))
        self.assertEqual(contract["status"], "LOCKED")
        self.assertEqual(boundary["status"], "LOCKED")
        self.assertGreaterEqual(lock["schema_version"], 2)
        self.assertEqual(lock["canonical_contract"]["path"], "docs/PROJECT_CONTRACT.json")
        self.assertEqual(lock["boundary_contract"]["path"], "contracts/app-contract.json")
        entries = {entry["path"]: entry["sha256"] for entry in lock["locked_files"]}
        required = {
            "docs/PROJECT_CONTRACT.json", "contracts/app-contract.json",
            "docs/PROJECT.md", "docs/ARCHITECTURE.md", "docs/UX_FLOW.md",
            "docs/DECISIONS.md", "docs/TASKS.md",
            "artifacts/architecture.html", "artifacts/ux-flow.html",
        }
        if contract["screens"].get("design_lock_required"):
            required.update({
                "design/DESIGN_BRIEF.md", "design/DESIGN_SYSTEM.md",
                "design/SCREEN_CONTRACTS.md", "design/COMPONENTS.md",
                "design/TOKENS.css", "design/DESIGN_LOCK.json",
            })
        self.assertEqual(set(entries), required)
        if contract["screens"].get("design_lock_required"):
            self.assertEqual(lock["design"]["status"], "LOCKED")
        for relative, expected in entries.items():
            actual = hashlib.sha256((ROOT / relative).read_bytes()).hexdigest()
            self.assertEqual(actual, expected, f"stale lock or contract drift: {relative}")

    def test_lavish_is_pinned_and_artifacts_are_local_only(self):
        tools = json.loads((ROOT / "manifests/tools.json").read_text(encoding="utf-8"))
        lavish = next(tool for tool in tools["recommended"] if tool["command"] == "lavish-axi")
        self.assertEqual(lavish["exact"], "0.1.63")
        self.assertIn("lavish-axi@0.1.63", tools["npm_global_packages"])
        self.assertNotIn("lavish-axi@latest", tools["npm_global_packages"])
        for relative in ("artifacts/architecture.html", "artifacts/ux-flow.html"):
            text = (ROOT / relative).read_text(encoding="utf-8").lower()
            for forbidden in ("http://", "https://", "cdn.tailwindcss", "fonts.googleapis", "ht-ml.app"):
                self.assertNotIn(forbidden, text, relative)
            self.assertNotRegex(text, r"<script[^>]+src\s*=")
            self.assertNotRegex(text, r"<link[^>]+href\s*=")

    def test_design_studio_is_contract_first_and_local_only(self):
        skill = (ROOT / "kit/skills/aitc-design-studio/SKILL.md").read_text(encoding="utf-8")
        for marker in ("DESIGN BRIEF", "2-3 DESIGN DIRECTIONS", "HUMAN CHOICE", "DESIGN CRITIQUE", "P0", "P1", "P2", "DESIGN LOCK"):
            self.assertIn(marker, skill)
        self.assertIn("Claude Design", skill)
        self.assertIn("lavish-axi share", skill)
        self.assertIn("design_lock_required=false", skill)
        for relative in (
            "design/DESIGN_BRIEF.md", "design/DESIGN_SYSTEM.md",
            "design/SCREEN_CONTRACTS.md", "design/COMPONENTS.md",
            "design/TOKENS.css", "design/DESIGN_LOCK.json",
            "kit/templates/design/DESIGN_BRIEF.md", "kit/templates/design/DESIGN_LOCK.json",
        ):
            self.assertTrue((ROOT / relative).is_file(), relative)

    def test_design_templates_are_product_neutral(self):
        templates = "\n".join((ROOT / "kit/templates/design" / name).read_text(encoding="utf-8") for name in ("DESIGN_BRIEF.md","DESIGN_SYSTEM.md","SCREEN_CONTRACTS.md","COMPONENTS.md","DESIGN_LOCK.json"))
        for forbidden in ("NAVIN AITC leader", "local-first competition kit", "Utility", "DecisionPanel", "ContractBoard", "Architecture Lavish"):
            self.assertNotIn(forbidden, templates)

    def test_multimodal_resource_contract_and_research_rules(self):
        template = json.loads((ROOT / "kit/templates/PROJECT_CONTRACT.template.json").read_text(encoding="utf-8"))
        self.assertIsNone(template["resources"]["api"]["request_cap"])
        self.assertEqual(template["resources"]["generation_policy"], {"cache_by_prompt_hash": True, "duplicate_requests": False, "retry_limit": 1})
        self.assertEqual(template["screens"], {"kind": None, "design_lock_required": None, "routes": [], "states": ["empty", "loading", "error", "success"]})
        captain = (ROOT / "kit/skills/aitc-captain/SKILL.md").read_text(encoding="utf-8")
        for marker in ("official, government, or reputable sources", "one full-stack web app", "structured text request", "normalizes and hashes the prompt", "mandatory video", "MUST HAVE, SHOULD HAVE, and OPTIONAL"):
            self.assertIn(marker, captain)
        self.assertTrue((ROOT / "kit/templates/IMAGE_GENERATION_CONTRACT.template.json").is_file())
        self.assertTrue((ROOT / "kit/templates/STRUCTURED_GENERATION.schema.json").is_file())

    def test_contract_requires_explicit_screen_kind_and_design_decision(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "docs").mkdir()
            (root / "contracts").mkdir()
            shutil.copy2(ROOT / "contracts/app-contract.json", root / "contracts/app-contract.json")
            base = json.loads((ROOT / "kit/templates/PROJECT_CONTRACT.template.json").read_text(encoding="utf-8"))
            base["screens"]["kind"] = "CLI_ONLY"
            base["screens"]["design_lock_required"] = False
            contract_path = root / "docs/PROJECT_CONTRACT.json"
            contract_path.write_text(json.dumps(base), encoding="utf-8")
            ok = self.run_powershell(ROOT / "kit/scripts/contract-validate.ps1", "-ProjectRoot", root)
            self.assertEqual(ok.returncode, 0, ok.stdout + ok.stderr)
            for mutation in ("missing", "null"):
                invalid = json.loads(json.dumps(base))
                if mutation == "missing":
                    invalid["screens"].pop("design_lock_required")
                else:
                    invalid["screens"]["design_lock_required"] = None
                contract_path.write_text(json.dumps(invalid), encoding="utf-8")
                failed = self.run_powershell(ROOT / "kit/scripts/contract-validate.ps1", "-ProjectRoot", root)
                self.assertNotEqual(failed.returncode, 0, mutation)

    def test_official_chung_khao_gate_and_conditional_design_lock(self):
        with tempfile.TemporaryDirectory() as tmp:
            repo, project = self.make_gate_fixture(tmp, mode="OFFICIAL", ui=True)
            lock = self.run_powershell(ROOT / "kit/scripts/lock-project.ps1", "-ProjectRoot", project, "-RepositoryRoot", repo, "-SessionMode", "OFFICIAL", "-ApprovedBy", "fixture")
            self.assertEqual(lock.returncode, 0, lock.stdout + lock.stderr)
            self.assertIn("PROJECT_RELATIVE_ROOT=chung-khao", lock.stdout)
            subprocess.run(["git", "-C", str(repo), "add", "chung-khao/docs/PROJECT_LOCK.json"], check=True)
            subprocess.run(["git", "-C", str(repo), "commit", "-qm", "lock"], check=True)
            gate = self.run_powershell(ROOT / "kit/scripts/implementation-gate.ps1", "-ProjectRoot", project, "-RepositoryRoot", repo)
            self.assertEqual(gate.returncode, 0, gate.stdout + gate.stderr)
            lock_path = project / "docs/PROJECT_LOCK.json"
            payload = json.loads(lock_path.read_text(encoding="utf-8"))
            payload["design"]["status"] = "SKIPPED"
            lock_path.write_text(json.dumps(payload), encoding="utf-8")
            blocked = self.run_powershell(ROOT / "kit/scripts/implementation-gate.ps1", "-ProjectRoot", project, "-RepositoryRoot", repo)
            self.assertNotEqual(blocked.returncode, 0)
            subprocess.run(["git", "-C", str(repo), "checkout", "--", "chung-khao/docs/PROJECT_LOCK.json"], check=True)
            subprocess.run(["git", "-C", str(repo), "checkout", "-q", "--detach", payload["base_commit"]], check=True)
            writer = self.run_powershell(ROOT / "kit/scripts/writer-preflight.ps1", "-RepositoryRoot", repo, "-WorktreePath", repo, "-LockBaseSha", payload["base_commit"], "-SessionMode", "OFFICIAL", "-ProjectRelativeRoot", "chung-khao")
            self.assertEqual(writer.returncode, 0, writer.stdout + writer.stderr)

    def test_cli_project_explicitly_skips_design_lock(self):
        with tempfile.TemporaryDirectory() as tmp:
            repo, project = self.make_gate_fixture(tmp, mode="DRILL", ui=False)
            lock = self.run_powershell(ROOT / "kit/scripts/lock-project.ps1", "-ProjectRoot", project, "-RepositoryRoot", repo, "-SessionMode", "DRILL", "-ApprovedBy", "fixture")
            self.assertEqual(lock.returncode, 0, lock.stdout + lock.stderr)
            payload = json.loads((project / "docs/PROJECT_LOCK.json").read_text(encoding="utf-8"))
            self.assertFalse(payload["design"]["required"])
            self.assertEqual(payload["design"]["status"], "SKIPPED")
            self.assertFalse(any(item["path"].startswith("design/") for item in payload["locked_files"]))

    def test_aitc_shell_policy_filters_secret_environment_defaults(self):
        for relative in ("profiles/codex/config.aitc.template.toml", "kit/config/codex-config.template.toml"):
            text = (ROOT / relative).read_text(encoding="utf-8")
            self.assertIn("[shell_environment_policy]", text)
            self.assertIn("ignore_default_excludes = false", text)

    def test_sync_variant_blocks_official_mode(self):
        result = self.run_powershell(ROOT / "kit/scripts/sync-variant.ps1", "-OfficialRepo", ROOT, "-SessionMode", "OFFICIAL")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("SYNC VARIANT BLOCKED", result.stdout + result.stderr)

    def test_generation_cache_reuses_success_and_blocks_duplicate(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "data").mkdir()
            shutil.copy2(ROOT / "kit/templates/data/generation-manifest.json", root / "data/generation-manifest.json")
            shutil.copy2(ROOT / "kit/templates/data/request-ledger.json", root / "data/request-ledger.json")
            script = ROOT / "kit/scripts/generation-cache.ps1"
            start = self.run_powershell(script, "-ProjectRoot", root, "-Operation", "RECORD", "-Prompt", "A calm hero", "-AssetId", "hero", "-Type", "image", "-Purpose", "hero", "-OutputPath", "public/generated/images/hero.webp", "-Status", "STARTED")
            self.assertEqual(start.returncode, 0, start.stdout + start.stderr)
            duplicate = self.run_powershell(script, "-ProjectRoot", root, "-Operation", "RECORD", "-Prompt", "A  calm hero", "-AssetId", "hero-duplicate", "-Type", "image", "-Purpose", "hero", "-Status", "STARTED")
            self.assertNotEqual(duplicate.returncode, 0)
            output = root / "public/generated/images/hero.webp"
            output.parent.mkdir(parents=True)
            output.write_bytes(b"fixture")
            success = self.run_powershell(script, "-ProjectRoot", root, "-Operation", "RECORD", "-Prompt", "A calm hero", "-AssetId", "hero", "-Type", "image", "-Purpose", "hero", "-OutputPath", "public/generated/images/hero.webp", "-Status", "SUCCESS", "-ResultStatus", "200")
            self.assertEqual(success.returncode, 0, success.stdout + success.stderr)
            reuse = self.run_powershell(script, "-ProjectRoot", root, "-Operation", "CHECK", "-Prompt", "A calm hero")
            self.assertEqual(reuse.returncode, 0, reuse.stdout + reuse.stderr)
            self.assertIn("GENERATION REUSE", reuse.stdout)
            ledger_text = (root / "data/request-ledger.json").read_text(encoding="utf-8").lower()
            self.assertNotIn("authorization", ledger_text)
            self.assertNotIn("api_key", ledger_text)

    def test_route_requires_model_endpoint_harness_tool_smoke(self):
        registry = json.loads((ROOT / "kit/knowledge/verified-routes.json").read_text(encoding="utf-8"))
        tuples = {(r["model"], r["endpoint"], r["harness"]) for r in registry["routes"]}
        self.assertIn(("gpt-6-luna", "responses", "codex"), tuples)
        self.assertIn(("gpt-5.6-luna", "responses", "codex"), tuples)
        self.assertNotIn(("deepseek-flash", "responses", "codex"), tuples)
        rejection = {(r["model"], r["endpoint"], r["harness"]) for r in registry["explicit_rejections"]}
        self.assertIn(("deepseek-flash", "responses", "codex"), rejection)
        script = (ROOT / "kit/scripts/route-compatibility.ps1").read_text(encoding="utf-8")
        self.assertIn("tool_call_smoke", script)
        self.assertIn("provider", script)

    def test_early_canary_and_final_provenance_are_separate_gates(self):
        canary = (ROOT / "kit/scripts/integration-canary.ps1").read_text(encoding="utf-8")
        final_gate = (ROOT / "kit/scripts/final-gate.ps1").read_text(encoding="utf-8")
        self.assertIn("INTEGRATION CANARY VERIFIED", canary)
        self.assertIn("frontend_proof", canary)
        self.assertIn("backend_endpoint", canary)
        self.assertIn("merge-base --is-ancestor", final_gate)
        self.assertIn("submit_log.py", final_gate)
        self.assertIn("RequireServerLog", final_gate)
        self.assertLess(final_gate.index("merge-base --is-ancestor"), final_gate.index("submit_log.py"))

    def test_repo_root_origin_and_ai_hooks_are_fail_closed(self):
        doctor = (ROOT / "setup/doctor.ps1").read_text(encoding="utf-8")
        preflight = (ROOT / "kit/scripts/preflight.ps1").read_text(encoding="utf-8")
        common = (ROOT / "kit/scripts/lib/Aitc.Common.ps1").read_text(encoding="utf-8")
        for marker in ("rev-parse --show-toplevel", "remote get-url origin", "UserPromptSubmit", "PostToolUse", "Stop"):
            self.assertIn(marker, doctor)
        self.assertIn("must equal Git top-level", preflight)
        self.assertIn("github\\.com", doctor)
        self.assertIn("Test-AitcOfficialOrigin", common)
        self.assertIn("github\\.com", common)

    def test_model_turn_concurrency_uses_live_key_info(self):
        policy = json.loads((ROOT / "config/competition/router-policy.json").read_text(encoding="utf-8"))
        turns = policy["model_turn_concurrency"]
        self.assertEqual(turns["source"], "live /key/info")
        self.assertEqual(turns["drill_default"], 2)
        self.assertEqual(turns["official_default"], 6)
        self.assertTrue(turns["reserve_headroom"])
        script = (ROOT / "kit/scripts/concurrency-policy.ps1").read_text(encoding="utf-8")
        self.assertIn("Get-AitcKeyInfo", script)
        self.assertIn("reserved_headroom", script)

if __name__ == "__main__":
    unittest.main()
