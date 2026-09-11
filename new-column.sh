#!/usr/bin/env bash
# 一键创建专栏目录、README 及封面图片 (代理调用 rustpress 原生指令)
set -euo pipefail

exec rustpress new-column "$@"
