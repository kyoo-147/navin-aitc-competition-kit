"""Fail-closed structural and secret checks for the NR-00 harness."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = [
    "AGENTS.md",
    "README.md",
    "docs/competition/ROUND-2-RULES.md",
    "docs/competition/AI-LOG-COMPLIANCE.md",
    "docs/competition/COMPETITION-DAY-CHECKLIST.md",
    "docs/competition/SOURCE-REGISTER.md",
    "docs/operations/WORKFLOW.md",
    "config/official-sources.json",
    "kit/README.md",
    "kit/RULES.md",
    "kit/docs/OFFICIAL-REPO-BOUNDARY.md",
    "kit/scripts/preflight.ps1",
    "kit/scripts/sync-variant.ps1",
    "kit/MANIFEST.json",
]
TEXT_SUFFIXES = {".md", ".json", ".py", ".yml", ".yaml", ".toml", ".sh", ".ps1"}
SECRET_PATTERNS = {
    "private key": re.compile(r"-----BEGIN (?:RSA |OPENSSH |EC )?PRIVATE KEY-----"),
    "GitHub token": re.compile(r"\b(?:ghp|github_pat)_[A-Za-z0-9_]{20,}\b"),
    "AITC token": re.compile(r"\baitc_[A-Za-z0-9]{12,}\b"),
}


def candidate_files():
    for path in ROOT.rglob("*"):
        if not path.is_file() or ".git" in path.parts or ".cache" in path.parts or ".ai-log" in path.parts:
            continue
        if path.suffix.lower() in TEXT_SUFFIXES or path.name in {"AGENTS.md", "GEMINI.md"}:
            yield path


def main() -> int:
    errors = []
    for relative in REQUIRED:
        if not (ROOT / relative).is_file():
            errors.append(f"missing required file: {relative}")
    registry_path = ROOT / "config" / "official-sources.json"
    if registry_path.is_file():
        registry = json.loads(registry_path.read_text(encoding="utf-8"))
        urls = [item.get("url", "") for item in registry.get("sources", [])]
        if len(urls) < 30:
            errors.append(f"official source registry unexpectedly small: {len(urls)}")
        if len(urls) != len(set(urls)):
            errors.append("official source registry contains duplicate URLs")
        if any(not url.startswith("https://docs.thucchien.ai/docs/round-2") for url in urls):
            errors.append("official source registry contains an out-of-scope URL")
    for path in candidate_files():
        text = path.read_text(encoding="utf-8", errors="replace")
        for label, pattern in SECRET_PATTERNS.items():
            if pattern.search(text):
                errors.append(f"possible {label}: {path.relative_to(ROOT)}")
    if errors:
        print("HARNESS CHECK FAILED")
        print("\n".join(f"- {error}" for error in errors))
        return 1
    print("HARNESS CHECK PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
