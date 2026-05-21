#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build"
DIST="$ROOT/dist"
COMBINED="$BUILD/combined.md"
PDF="$DIST/Facing-the-Dragon.pdf"
EPUB="$DIST/Facing-the-Dragon.epub"
COVER="$BUILD/cover.png"

need() {
  local cmd="$1" hint="$2"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "build.sh: missing $cmd — $hint" >&2
    exit 1
  fi
}

check_prereqs() {
  need pandoc "brew install pandoc"
  need xelatex "brew install --cask basictex && eval \"\$(/usr/libexec/path_helper)\""
}

check_epub_prereqs() {
  need epubcheck "brew install epubcheck"
}

ensure_combined() {
  "$BUILD/preprocess.sh"
}

ensure_cover() {
  if [[ ! -f "$COVER" ]]; then
    "$BUILD/make_cover.sh"
  fi
}

build_pdf() {
  check_prereqs
  mkdir -p "$DIST"
  ensure_combined
  pandoc "$COMBINED" \
    --from=markdown+smart+raw_tex \
    --to=pdf \
    --pdf-engine=xelatex \
    --template="$BUILD/template.tex" \
    --metadata-file="$BUILD/metadata.yaml" \
    --toc --toc-depth=2 \
    --top-level-division=chapter \
    --resource-path=.:build \
    --output="$PDF"
  echo "build.sh: PDF -> $PDF"
}

build_epub() {
  check_prereqs
  check_epub_prereqs
  mkdir -p "$DIST"
  ensure_combined
  ensure_cover
  local epub_src
  epub_src="$(mktemp)"
  grep -v '^\\newpage$' "$COMBINED" > "$epub_src"
  pandoc "$epub_src" \
    --from=markdown+smart \
    --to=epub3 \
    --metadata-file="$BUILD/metadata.yaml" \
    --css="$BUILD/epub.css" \
    --epub-cover-image="$COVER" \
    --toc --toc-depth=2 \
    --split-level=1 \
    --resource-path=.:build \
    --output="$EPUB"
  rm -f "$epub_src"
  echo "build.sh: EPUB -> $EPUB"
}

case "${1:-all}" in
  pdf) build_pdf ;;
  epub) build_epub ;;
  all) build_pdf; build_epub ;;
  *)
    echo "Usage: $0 {pdf|epub|all}" >&2
    exit 1
    ;;
esac
