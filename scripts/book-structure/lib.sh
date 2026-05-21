#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BS="$(cd "$(dirname "$0")" && pwd)"
MANIFEST="$BS/manifest.yaml"
RESULTS="$ROOT/test-results/book-structure"

mkdir -p "$RESULTS"

load_manifest() {
  python3 - "$MANIFEST" <<'PY'
import sys, yaml
from pathlib import Path
data = yaml.safe_load(Path(sys.argv[1]).read_text())
for f in data["files"]:
    row = [
        f.get("legacy") or "",
        f["new_file"],
        str(f.get("chapter") or ""),
        f.get("part") or "",
        f["title"],
        f.get("slug") or "",
        "1" if f.get("parable") else "0",
        f.get("nav_prev") or "",
        f.get("nav_next") or "",
        f.get("nav_prev_label") or "",
        f.get("nav_next_label") or "",
    ]
    print("|".join(row))
PY
}

timestamp() {
  date +%Y%m%d-%H%M%S
}

manuscript_glob() {
  python3 - "$ROOT" <<'PY'
import sys
from pathlib import Path
root = Path(sys.argv[1])
skip = {"README.md", "EDITORIAL_REVIEW.md", "Parables.Shortened.md", "PRODUCTION_READY_EXECUTION_REPORT.md"}
for p in sorted(root.glob("*.md")):
    if p.name in skip:
        continue
    print(p.name)
PY
}
