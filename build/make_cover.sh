#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/build/cover.png"
MOTIF="$ROOT/Dragon.Sword.png"

MAGICK=""
if command -v magick >/dev/null 2>&1; then
  MAGICK=magick
elif command -v convert >/dev/null 2>&1; then
  MAGICK=convert
else
  echo "make_cover.sh: ImageMagick required (brew install imagemagick)" >&2
  exit 1
fi

[[ -f "$MOTIF" ]] || { echo "make_cover.sh: missing $MOTIF" >&2; exit 1; }

# Placeholder cover: gradient background + centered Dragon.Sword motif (no font dependency)
"$MAGICK" -size 1600x2400 gradient:'#1a1a2e-#16213e' \
  \( "$MOTIF" -resize 1000x1000 \) -gravity center -composite \
  "$OUT"

echo "make_cover.sh: wrote $OUT"
