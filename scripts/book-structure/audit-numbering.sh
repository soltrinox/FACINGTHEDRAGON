#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BS="$(cd "$(dirname "$0")" && pwd)"
source "$BS/lib.sh"

TS="$(timestamp)"
LOG="$RESULTS/audit-${TS}.log.txt"
FAIL=0

log() { echo "$1" | tee -a "$LOG"; }
fail() { log "[FAIL] $1"; FAIL=1; }
pass() { log "[PASS] $1"; }

log "=== Book Structure Audit ${TS} ==="
log "ROOT: $ROOT"
log ""

# --- manifest load ---
if [[ ! -f "$MANIFEST" ]]; then
  fail "manifest.yaml missing"
  echo "$LOG"
  exit 1
fi

declare -A LEGACY_NEW
declare -A NEW_TITLE
declare -A NEW_CHAPTER
MANIFEST_FILES=()
while IFS='|' read -r legacy new_file chapter part title slug parable nav_prev nav_next nav_prev_label nav_next_label; do
  MANIFEST_FILES+=("$new_file")
  if [[ -n "$legacy" ]]; then
    LEGACY_NEW["$legacy"]="$new_file"
  fi
  NEW_TITLE["$new_file"]="$title"
  NEW_CHAPTER["$new_file"]="$chapter"
done < <(load_manifest)

log "Manifest entries: ${#MANIFEST_FILES[@]}"

# --- orphans / missing ---
for new_file in "${MANIFEST_FILES[@]}"; do
  if [[ ! -f "$ROOT/$new_file" ]]; then
    fail "Missing manifest file on disk: $new_file"
  fi
done

for md in $(manuscript_glob); do
  found=0
  for new_file in "${MANIFEST_FILES[@]}"; do
    [[ "$md" == "$new_file" ]] && found=1 && break
  done
  if [[ $found -eq 0 ]]; then
    # still legacy name?
    legacy_hit=0
    for legacy in "${!LEGACY_NEW[@]}"; do
      [[ "$md" == "$legacy" ]] && legacy_hit=1 && fail "Legacy file still present: $legacy (expected ${LEGACY_NEW[$legacy]})"
    done
    [[ $legacy_hit -eq 0 ]] && fail "Orphan manuscript not in manifest: $md"
  fi
done

# --- stale patterns ---
PATTERNS=(
  'Section 7\.'
  'Section 8\.[45]'
  'Why a Young Man Stops'
  'QUESTIONS\.001'
  'BASE\.001'
)
for pat in "${PATTERNS[@]}"; do
  hits=$(rg -l "$pat" "$ROOT" --glob '*.md' \
    --glob '!Parables.Shortened.md' \
    --glob '!EDITORIAL_REVIEW.md' \
    --glob '!PRODUCTION_READY_EXECUTION_REPORT.md' \
    --glob '!.cursor/**' \
    --glob '!scripts/**' \
    --glob '!test-results/**' \
    --glob '!build/**' 2>/dev/null || true)
  if [[ -n "$hits" ]]; then
    fail "Stale pattern /$pat/ in: $(echo "$hits" | tr '\n' ' ')"
  else
    pass "No stale pattern /$pat/"
  fi
done

# --- deleted link targets ---
for dead in 008.md 014.md 038.md 048.md; do
  hits=$(rg -l "\(${dead}\)" "$ROOT" --glob '*.md' \
    --glob '!Parables.Shortened.md' \
    --glob '!EDITORIAL_REVIEW.md' \
    --glob '!.cursor/**' 2>/dev/null || true)
  if [[ -n "$hits" ]]; then
    fail "Link to deleted file ${dead} in: $(echo "$hits" | tr '\n' ' ')"
  else
    pass "No links to deleted ${dead}"
  fi
done

# --- broken md links ---
python3 - "$ROOT" <<'PY' | while read -r line; do
import re, sys
from pathlib import Path
root = Path(sys.argv[1])
skip = {"README.md", "EDITORIAL_REVIEW.md", "Parables.Shortened.md", "PRODUCTION_READY_EXECUTION_REPORT.md"}
link_re = re.compile(r'\]\(([^)#]+\.md)(#[^)]+)?\)')
for p in sorted(root.glob("*.md")):
    if p.name in skip:
        continue
    text = p.read_text()
    for m in link_re.finditer(text):
        target = m.group(1)
        if not (root / target).exists():
            print(f"{p.name}: {target}")
PY
  fail "Broken link: $line"
done
pass "All md links resolve"

# --- nav chain ---
while IFS='|' read -r legacy new_file chapter part title slug parable nav_prev nav_next nav_prev_label nav_next_label; do
  [[ ! -f "$ROOT/$new_file" ]] && continue
  first=$(head -1 "$ROOT/$new_file")
  last_nav=$(grep -E '^\[← Previous|^\[Table of Contents' "$ROOT/$new_file" | tail -1 || true)
  [[ -z "$last_nav" ]] && last_nav="$first"

  if [[ "$new_file" == "00-title.md" ]]; then
    echo "$first" | grep -q '00-toc.md' || fail "00-title nav missing link to 00-toc.md"
    echo "$first" | grep -q '01-warriors-facing-dragons.md' || fail "00-title nav missing next chapter"
  elif [[ "$new_file" == "00-toc.md" ]]; then
    echo "$first" | grep -q '00-title.md' || fail "00-toc nav missing link to 00-title.md"
    echo "$first" | grep -q '01-warriors-facing-dragons.md' || fail "00-toc nav missing next chapter"
  elif [[ "$new_file" == "58-final-conclusion.md" ]]; then
    echo "$last_nav" | grep -q '57-actualization.md' || fail "58-final-conclusion nav missing prev 57-actualization"
    echo "$last_nav" | grep -q '00-toc.md' || fail "58-final-conclusion nav missing TOC"
  else
    [[ -n "$nav_prev" ]] && { echo "$first" | grep -q "$nav_prev" || fail "$new_file nav missing prev $nav_prev"; }
    [[ -n "$nav_next" ]] && { echo "$last_nav" | grep -q "$nav_next" || fail "$new_file nav missing next $nav_next (line: $last_nav)"; }
    echo "$first" | grep -q '00-toc.md' || fail "$new_file nav missing TOC link"
  fi
done < <(load_manifest)
pass "Nav chain verified"

# --- parable H1 ---
while IFS='|' read -r legacy new_file chapter part title slug parable nav_prev nav_next nav_prev_label nav_next_label; do
  [[ "$parable" != "1" ]] && continue
  h1_count=$(grep -c '^# ' "$ROOT/$new_file" 2>/dev/null || echo 0)
  if [[ "$h1_count" -ne 1 ]]; then
    fail "$new_file parable should have exactly one H1 (found $h1_count)"
  else
    pass "$new_file has one H1"
  fi
done < <(load_manifest)

# --- order.txt ---
ORDER="$ROOT/build/order.txt"
if [[ ! -f "$ORDER" ]]; then
  fail "build/order.txt missing"
else
  order_lines=$(grep -vc '^#' "$ORDER" || echo 0)
  if [[ "$order_lines" -ne ${#MANIFEST_FILES[@]} ]]; then
    fail "build/order.txt lines ($order_lines) != manifest files (${#MANIFEST_FILES[@]})"
  else
    pass "build/order.txt matches manifest count (${order_lines})"
  fi
  idx=0
  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    expected="${MANIFEST_FILES[$idx]}"
    [[ "$line" == "$expected" ]] || fail "order.txt[$idx] expected $expected got $line"
    idx=$((idx+1))
  done < "$ORDER"
  pass "build/order.txt order matches manifest"
fi

# --- chapter numbering ---
python3 - "$MANIFEST" <<'PY' | while read -r msg; do
import sys, yaml
from pathlib import Path
data = yaml.safe_load(Path(sys.argv[1]).read_text())
chapters = sorted(f["chapter"] for f in data["files"] if f.get("chapter"))
expected = list(range(1, 59))
missing = [c for c in expected if c not in chapters]
extra = [c for c in chapters if c not in expected]
if missing:
    print(f"FAIL: missing chapter numbers: {missing}")
if extra:
    print(f"FAIL: unexpected chapter numbers: {extra}")
if not missing and not extra:
    print("PASS: chapters 1-58 present")
PY
  if [[ "$msg" == PASS* ]]; then pass "${msg#PASS: }"; else fail "${msg#FAIL: }"; fi
done

log ""
if [[ $FAIL -eq 0 ]]; then
  log "[PASS] Audit complete — all checks passed"
  exit 0
else
  log "[FAIL] Audit complete — failures detected"
  exit 1
fi
