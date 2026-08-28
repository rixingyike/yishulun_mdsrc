#!/usr/bin/env bash
# make_cover.sh - 自动为专栏生成封面图片 (cover.png)
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="${SCRIPT_DIR}/scripts/make_cover.py"

if [ ! -f "$PYTHON_SCRIPT" ]; then
    PYTHON_SCRIPT="${SCRIPT_DIR}/make_cover.py"
fi

python3 "$PYTHON_SCRIPT" "$@"
