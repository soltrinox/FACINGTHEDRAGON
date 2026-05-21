#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BS="$(cd "$(dirname "$0")" && pwd)"
source "$BS/lib.sh"

TOC="$ROOT/00-toc.md"

python3 - "$MANIFEST" "$TOC" <<'PY'
import sys, yaml
from pathlib import Path

manifest = yaml.safe_load(Path(sys.argv[1]).read_text())
toc_path = Path(sys.argv[2])

parts_order = []
part_links = {}
current_part = None

for f in manifest["files"]:
    if f["new_file"] in ("00-title.md", "00-toc.md"):
        continue
    part = f.get("part") or "Other"
    title = f["title"]
    nf = f["new_file"]
    ch = f.get("chapter")
    if part not in parts_order:
        parts_order.append(part)
        part_links[part] = []
    if ch:
        label = f"Chapter {ch} — {title}"
    else:
        label = title
    part_links[part].append(f"[**{label}**]({nf})")

part_headers = {
    "I Foundation": "PART ONE: FOUNDATION",
    "II Parables": "PART TWO: THE STORIES (THE DRAGON PARABLES)",
    "III Patterns": "PART THREE: PATTERNS OF THE HEART",
    "IV Worksheets": "PART FOUR: WORKSHEETS",
    "V Workbook": "PART FIVE: WRITING YOUR LIFE",
    "VI Tools": "PART SIX: PRACTICAL TOOLS",
    "Appendices": "APPENDICES",
}

lines = []
for part in parts_order:
    header = part_headers.get(part, part.upper())
    lines.append(f"## {header}")
    lines.append("")
    for link in part_links[part]:
        lines.append(link)
        lines.append("")
    lines.append("---")
    lines.append("")

body = "\n".join(lines).rstrip() + "\n"

# preserve nav from existing or rebuild
nav = "[← Previous: Title / Copyright / Preface](00-title.md) | [Table of Contents](00-toc.md) | [Next: Chapter 1 — Warriors Facing Dragons →](01-warriors-facing-dragons.md)\n\n"
toc_path.write_text(nav + body)
print(f"fix-toc: wrote {toc_path}")
PY

echo "fix-toc.sh: done"
