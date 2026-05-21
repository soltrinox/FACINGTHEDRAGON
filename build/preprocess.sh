#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build"
ORDER="$BUILD/order.txt"
OUT="$BUILD/combined.md"

: > "$OUT"

first=1
while IFS= read -r file || [[ -n "$file" ]]; do
  [[ -z "$file" || "$file" =~ ^# ]] && continue
  src="$ROOT/$file"
  if [[ ! -f "$src" ]]; then
    echo "preprocess.sh: missing file: $src" >&2
    exit 1
  fi

  if [[ $first -eq 0 ]]; then
    printf '\n\\newpage\n\n' >> "$OUT"
  fi
  first=0

  base="${file%.md}"
  id="${base,,}"

  tmp="$(mktemp)"
  sed -E \
    -e '/^\[← Previous/d' \
    -e '/\[Table of Contents\]\(000\.md\)/d' \
    "$src" > "$tmp"

  python3 - "$tmp" "$id" "$file" <<'PY'
import re, sys
from pathlib import Path
path, chap_id, filename = sys.argv[1], sys.argv[2], sys.argv[3]
text = Path(path).read_text()
lines = text.splitlines(keepends=True)
out = []
has_h1 = any(re.match(r'^# ', l) for l in lines)
for i, line in enumerate(lines):
    if not has_h1 and filename == "000.md" and i == 0:
        out.append("# Table of Contents {#000}\n\n")
    if re.match(r'^# ', line) and not re.search(r'\{#', line):
        if not any(re.match(r'^# ', l) and re.search(r'\{#', l) for l in out):
            line = line.rstrip("\n") + f" {{#{chap_id}}}\n"
        elif re.match(r'^# \d+\.', line):
            m = re.match(r'^# (\d+)\.\s+(.*?)\s*$', line)
            if m:
                n, rest = m.group(1), m.group(2)
                slug = re.sub(r'[^a-z0-9]+', '-', rest.lower().strip(':.')).strip('-')
                line = f"# {n}. {rest} {{#{n}-{slug}}}\n"
    elif not has_h1 and re.match(r'^## ', line) and not any(re.match(r'^# ', l) for l in out):
        title = re.sub(r'^## ', '', line).strip()
        line = f"# {title} {{#{chap_id}}}\n"
    out.append(line)
open(path, 'w').writelines(out)
PY

  "$BUILD/rewrite-links.pl" "$tmp" >> "$OUT"
  rm -f "$tmp"
done < "$ORDER"

echo "preprocess.sh: wrote $OUT ($(wc -l < "$OUT" | tr -d ' ') lines)"
