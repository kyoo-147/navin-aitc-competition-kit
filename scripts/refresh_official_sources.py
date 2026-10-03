# /// script
# requires-python = ">=3.11"
# dependencies = ["requests>=2.32,<3"]
# ///
"""Fetch official AITC source metadata into an ignored local cache."""
from __future__ import annotations

import hashlib
import json
import re
from datetime import datetime, timezone
from pathlib import Path

import requests

ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "config" / "official-sources.json"
CACHE = ROOT / ".cache" / "official-docs"
MANIFEST = CACHE / "manifest.json"


def main() -> None:
    sources = json.loads(REGISTRY.read_text(encoding="utf-8"))["sources"]
    CACHE.mkdir(parents=True, exist_ok=True)
    session = requests.Session()
    session.headers["User-Agent"] = "NAVIN-Research-AITC-source-check/1.0"
    results = []
    for index, source in enumerate(sources, start=1):
        url = source["url"]
        response = session.get(url, timeout=30)
        response.raise_for_status()
        body = response.content
        title_match = re.search(rb"<title[^>]*>(.*?)</title>", body, re.I | re.S)
        title = re.sub(r"\s+", " ", title_match.group(1).decode("utf-8", "replace")).strip() if title_match else ""
        cache_file = CACHE / f"{index:02d}.html"
        cache_file.write_bytes(body)
        results.append({
            "url": url,
            "status": response.status_code,
            "sha256": hashlib.sha256(body).hexdigest(),
            "bytes": len(body),
            "title": title,
        })
        print(f"{response.status_code} {url}")
    payload = {"checked_at": datetime.now(timezone.utc).isoformat(), "sources": results}
    MANIFEST.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote ignored manifest: {MANIFEST}")


if __name__ == "__main__":
    main()
