#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BS="$(cd "$(dirname "$0")" && pwd)"
source "$BS/lib.sh"

# Create chapter 56 bridge file if missing
BRIDGE="$ROOT/56-bridge-to-actualization.md"
if [[ ! -f "$BRIDGE" ]]; then
  cat > "$BRIDGE" <<'EOF'
[← Previous: Chapter 55 — Glossary and Index](55-glossary.md) | [Table of Contents](00-toc.md) | [Next: Chapter 57 — Actualization →](57-actualization.md)

# Chapter 56 — Bridge to Actualization

The tools, references, and glossary of Chapters 51–55 prepare you for the closing work of actualization and conclusion. Continue to Chapter 57 when you are ready to bring your healing into daily life.

[← Previous: Chapter 55 — Glossary and Index](55-glossary.md) | [Table of Contents](00-toc.md) | [Next: Chapter 57 — Actualization →](57-actualization.md)
EOF
  echo "normalize-headings: created $BRIDGE"
fi

python3 - "$MANIFEST" "$ROOT" <<'PY'
import re, sys, yaml
from pathlib import Path

manifest = yaml.safe_load(Path(sys.argv[1]).read_text())
root = Path(sys.argv[2])

def set_h1(path, h1):
    text = path.read_text()
    lines = text.splitlines()
    # remove leading nav
    while lines and re.match(r'^\[(← Previous|Table of Contents)', lines[0]):
        lines.pop(0)
    while lines and lines[0].strip() == '':
        lines.pop(0)
    # remove trailing nav
    while lines and re.match(r'^\[(← Previous|Table of Contents)', lines[-1]):
        lines.pop()
    while lines and lines[-1].strip() == '':
        lines.pop()
    # replace or insert H1
    if lines and lines[0].startswith('# '):
        lines[0] = h1
    else:
        # parable with ## opening
        if lines and lines[0].startswith('## '):
            title = re.sub(r'^## \*\*|\*\*$|^## ', '', lines[0]).strip()
            lines[0] = h1
        else:
            lines.insert(0, h1)
            lines.insert(1, '')
    path.write_text('\n'.join(lines) + '\n')

for f in manifest['files']:
    nf = f['new_file']
    path = root / nf
    if not path.exists():
        continue
    ch = f.get('chapter')
    title = f['title']
    if f.get('parable'):
        set_h1(path, f"# Chapter {ch} — {title}")
    elif nf == '07-unheard-boy.md':
        set_h1(path, f"# Chapter {ch} — {title}")
    elif nf == '49-self-destruction-to-compassion.md':
        set_h1(path, f"# Chapter {ch} — From Self-Destruction to Self-Compassion")
    elif nf == '50-writing-your-life.md':
        text = path.read_text()
        text = re.sub(r'### K\.(\d+): CHAPTER (\d+):', r'### K.\1: Module \2:', text)
        text = re.sub(r'### M\.2\.(\d+): MODULE (\d+): Chapter (\d+):', r'### M.2.\1: Module \2:', text)
        text = re.sub(r'MODULE (\d+): Chapter (\d+):', r'Module \1:', text)
        text = re.sub(r'CHAPTER (\d+):', r'Module \1:', text)
        text = re.sub(r'CHAPTER-BY-CHAPTER', 'MODULE-BY-MODULE', text)
        path.write_text(text)
        print(f"normalize-headings: module labels in {nf}")
    elif ch and nf not in ('00-title.md', '00-toc.md', '56-bridge-to-actualization.md'):
        if not re.match(r'^# Chapter ', path.read_text().splitlines()[0] if path.read_text().strip() else ''):
            pass  # keep existing H1 for special files

print("normalize-headings: parable H1 pass done")
PY

# Fix 003 phase numbering 1-45 continuous
python3 - "$ROOT/03-chapter-sequencing-guide.md" <<'PY'
import re, sys
from pathlib import Path
path = Path(sys.argv[1])
text = path.read_text()
# remove (046) style refs
text = re.sub(r' \((0\d\d)\)', '', text)
# renumber phase lists: find numbered parable lines and renumber within phases
counter = 0
out = []
in_phase = False
for line in text.splitlines():
    if re.match(r'^### \*\*Phase ', line):
        in_phase = True
        counter = 0
        out.append(line)
        continue
    if in_phase and re.match(r'^### ', line) and not line.startswith('### **'):
        in_phase = False
    m = re.match(r'^(\d+)\. \*\*', line)
    if in_phase and m:
        counter += 1
        line = re.sub(r'^\d+\.', f'{counter}.', line)
    out.append(line)
path.write_text('\n'.join(out) + '\n')
print("normalize-headings: renumbered 003 phases 1-45")
PY

# Fix 061 summary: remove merged parable #7 and renumber
python3 - "$ROOT/47-parable-summary.md" <<'PY'
import re, sys
from pathlib import Path
path = Path(sys.argv[1])
text = path.read_text()
# remove section 7 Why a Young Man...
text = re.sub(
    r'## \*\*7\. Why a Young Man Stops Caring About Others\*\*.*?(?=## \*\*8\.)',
    '',
    text,
    flags=re.S
)
# renumber ## **N.
sections = re.findall(r'^## \*\*(\d+)\.', text, re.M)
# simple renumber pass
num = 0
def renum(m):
    global num
    num += 1
    return f'## **{num}.'
text = re.sub(r'^## \*\*\d+\.', renum, text, flags=re.M)
path.write_text(text)
print("normalize-headings: fixed 47-parable-summary numbering")
PY

echo "normalize-headings.sh: done"
