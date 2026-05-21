.PHONY: pdf epub all clean verify cover preprocess

pdf: preprocess cover
	./build/build.sh pdf

epub: preprocess cover
	./build/build.sh epub

all: preprocess cover
	./build/build.sh all

preprocess:
	./build/preprocess.sh

cover:
	./build/make_cover.sh

clean:
	rm -rf dist build/combined.md build/cover.png

verify: all
	@echo "=== epubcheck ==="
	epubcheck dist/Facing-the-Dragon.epub
	@echo "=== pdfinfo ==="
	pdfinfo dist/Facing-the-Dragon.pdf
	@echo "=== sanity grep (preface) ==="
	pdftotext dist/Facing-the-Dragon.pdf - | grep -q "The dragon is waiting" && echo "[PASS] preface phrase found"
	@echo "=== PDF embedded images ==="
	pdfimages -list dist/Facing-the-Dragon.pdf | tail -n +3 | head -10
	@echo "=== EPUB images ==="
	unzip -l dist/Facing-the-Dragon.epub | grep -E '\.(png|jpg|jpeg)' || true
	@echo "=== file sizes ==="
	ls -lh dist/Facing-the-Dragon.pdf dist/Facing-the-Dragon.epub
