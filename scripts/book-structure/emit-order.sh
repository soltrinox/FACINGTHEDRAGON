#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BS="$(cd "$(dirname "$0")" && pwd)"
source "$BS/lib.sh"

OUT="$ROOT/build/order.txt"
: > "$OUT"
while IFS='|' read -r legacy new_file chapter part title slug parable nav_prev nav_next nav_prev_label nav_next_label; do
  echo "$new_file" >> "$OUT"
done < <(load_manifest)

echo "emit-order.sh: wrote $(wc -l < "$OUT" | tr -d ' ') lines to $OUT"
