#!/usr/bin/env bash
# make_catalog.sh - 自动更新专栏 README.md 中的 catalog
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="${SCRIPT_DIR}/scripts/make_catalog.py"

if [ ! -f "$PYTHON_SCRIPT" ]; then
    PYTHON_SCRIPT="${SCRIPT_DIR}/make_catalog.py"
fi

python3 "$PYTHON_SCRIPT" "$@"
