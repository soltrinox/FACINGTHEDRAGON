#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BS="$(cd "$(dirname "$0")" && pwd)"
source "$BS/lib.sh"

build_nav_line() {
  local new_file="$1" nav_prev="$2" nav_next="$3" nav_prev_label="$4" nav_next_label="$5"
  local line=""

  if [[ "$new_file" == "00-title.md" ]]; then
    line="[Table of Contents](00-toc.md) | [Next: Chapter 1 — Warriors Facing Dragons →](01-warriors-facing-dragons.md)"
    echo "$line"
    return
  fi

  if [[ -n "$nav_prev" ]]; then
    line="[← Previous: ${nav_prev_label}](${nav_prev})"
  fi
  if [[ -n "$line" ]]; then
    line="$line | [Table of Contents](00-toc.md)"
  else
    line="[Table of Contents](00-toc.md)"
  fi
  if [[ -n "$nav_next" ]]; then
    line="$line | [Next: ${nav_next_label} →](${nav_next})"
  fi
  echo "$line"
}

while IFS='|' read -r legacy new_file chapter part title slug parable nav_prev nav_next nav_prev_label nav_next_label; do
  [[ ! -f "$ROOT/$new_file" ]] && continue
  nav_line=$(build_nav_line "$new_file" "$nav_prev" "$nav_next" "$nav_prev_label" "$nav_next_label")

  tmp="$(mktemp)"
  python3 - "$ROOT/$new_file" "$nav_line" <<'PY'
import sys, re
path, nav = sys.argv[1], sys.argv[2]
text = open(path).read()
lines = text.splitlines()
# strip existing nav lines
while lines and re.match(r'^\[(← Previous|Table of Contents)', lines[0]):
    lines.pop(0)
while lines and lines[0].strip() == '':
    lines.pop(0)
# strip trailing nav
while lines and re.match(r'^\[(← Previous|Table of Contents)', lines[-1]):
    lines.pop()
while lines and lines[-1].strip() == '':
    lines.pop()
out = [nav, ''] + lines + ['', nav, '']
open(path, 'w').write('\n'.join(out).rstrip() + '\n')
PY
  echo "fix-nav: $new_file"
done < <(load_manifest)

echo "fix-nav.sh: done"
