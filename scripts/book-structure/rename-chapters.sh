#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BS="$(cd "$(dirname "$0")" && pwd)"
source "$BS/lib.sh"

DRY=0
[[ "${1:-}" == "--dry-run" ]] && DRY=1

while IFS='|' read -r legacy new_file chapter part title slug parable nav_prev nav_next nav_prev_label nav_next_label; do
  [[ -z "$legacy" || "$legacy" == "None" ]] && continue
  src="$ROOT/$legacy"
  dst="$ROOT/$new_file"
  if [[ ! -f "$src" ]]; then
    echo "rename-chapters.sh: missing legacy $legacy" >&2
    exit 1
  fi
  if [[ -f "$dst" ]]; then
    echo "rename-chapters.sh: target exists $dst" >&2
    exit 1
  fi
  if [[ $DRY -eq 1 ]]; then
    echo "git mv $legacy -> $new_file"
  else
    git mv "$src" "$dst"
    echo "Renamed $legacy -> $new_file"
  fi
done < <(load_manifest)

echo "rename-chapters.sh: done"
