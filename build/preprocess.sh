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

  if grep -qE '^# ' "$tmp"; then
    awk -v id="$id" '
      /^# / && !done {
        $0 = $0 " {#" id "}"
        done = 1
      }
      { print }
    ' "$tmp" > "${tmp}.2"
    mv "${tmp}.2" "$tmp"
  elif [[ "$file" == "000.md" ]]; then
    {
      echo "# Table of Contents {#000}"
      echo
      cat "$tmp"
    } > "${tmp}.2"
    mv "${tmp}.2" "$tmp"
  fi

  sed -E \
    -e 's/\]\(([0-9]+)\.md#([^)]+)\)/](#\2)/g' \
    -e 's/\]\(([0-9]+)\.md\)/](#\L\1)/g' \
    -e 's/\]\(0\.md\)/](#0)/g' \
    "$tmp" >> "$OUT"

  rm -f "$tmp"
done < "$ORDER"

echo "preprocess.sh: wrote $OUT ($(wc -l < "$OUT" | tr -d ' ') lines)"
