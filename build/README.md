# Facing the Dragon — Build Pipeline

Reproducible PDF (6×9 trade paperback) and EPUB 3 build for the manuscript in the repo root.

## Prerequisites (macOS)

```bash
brew install pandoc epubcheck poppler imagemagick
brew install --cask basictex   # or mactex-no-gui
eval "$(/usr/libexec/path_helper)"
sudo tlmgr install lettrine microtype fontspec geometry hyperref xcolor setspace titlesec
```

TeX Live ships **EB Garamond** and **TeX Gyre** fallbacks via `tlmgr`; the template uses `EBGaramond-*.otf` when present.

## Quick start

```bash
make all      # PDF + EPUB
make pdf      # PDF only
make epub     # EPUB only
make verify   # build + epubcheck + sanity checks
make clean    # remove dist/ and intermediates
```

Or: `./build/build.sh pdf|epub|all`

## Pipeline

1. `build/preprocess.sh` — reads `build/order.txt`, strips nav lines, promotes first `##` to `#` where needed, injects chapter IDs, rewrites `NNN.md` links to anchors, inserts `\newpage` between chapters.
2. `build/combined.md` — intermediate (gitignored).
3. **PDF:** Pandoc → XeLaTeX (`build/template.tex`, `--toc --toc-depth=2`).
4. **EPUB:** Pandoc → EPUB 3 (`build/epub.css`, `build/cover.png`, `--toc --split-level=1`).

## Latest build (2026-05-21 12:21)

| Artifact | Path | Size | Notes |
|----------|------|------|-------|
| PDF | `dist/Facing-the-Dragon.pdf` | 9.7 MB | 650 pages, 6×9 in, clickable TOC |
| EPUB | `dist/Facing-the-Dragon.epub` | 13.2 MB | EPUB 3, cover + 4 inline PNGs + nav TOC |

### Verification

- `epubcheck dist/Facing-the-Dragon.epub` — **PASS** (0 errors)
- `pdfinfo` — 650 pages, PDF 1.5, XeLaTeX/hyperref
- Preface grep — contains "The dragon is waiting"
- PDF images — 4 inline illustrations embedded (`RECURSIVE.box.png`, `Stand.001.png`, `Stand.002.png`, `CUBE.men.png`)
- EPUB images — 5 PNGs (cover + 4 inline)
- TOC — PDF `\tableofcontents` + EPUB `nav.xhtml` / `toc.ncx`

## Files

| File | Purpose |
|------|---------|
| `build/order.txt` | Chapter order (59 entries incl. `0.md`, `000.md`) |
| `build/preprocess.sh` | Concatenation + cleanup |
| `build/rewrite-links.pl` | Intra-book link rewriting |
| `build/template.tex` | 6×9 XeLaTeX book template |
| `build/epub.css` | EPUB stylesheet |
| `build/metadata.yaml` | Title, author, ISBN placeholder |
| `build/make_cover.sh` | Placeholder cover from `Dragon.Sword.png` |
| `Makefile` | `pdf`, `epub`, `all`, `clean`, `verify` |

Manuscript chapter files (`0.md`, `001.md`, …) are **not** modified by the build.
