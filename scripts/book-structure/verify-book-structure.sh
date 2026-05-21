#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BS="$(cd "$(dirname "$0")" && pwd)"

echo "=== verify-book-structure ==="
"$BS/audit-numbering.sh"
echo ""
echo "=== make all ==="
make -C "$ROOT" all
echo ""
echo "=== make verify ==="
make -C "$ROOT" verify
echo ""
echo "[PASS] verify-book-structure complete"
