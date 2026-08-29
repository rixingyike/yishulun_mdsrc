#!/usr/bin/env bash
# stop_dev.sh - 停止本地热重载开发服务器
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="${SCRIPT_DIR}/.dev.pid"
PORT=1111

echo "🛑 正在停止本地热重载开发服务器..."

STOPPED=false

# 1. 如果存在 PID 文件，终止该进程树
if [ -f "${PID_FILE}" ]; then
  DEV_PID="$(cat "${PID_FILE}" 2>/dev/null || true)"
  if [ -n "${DEV_PID}" ] && kill -0 "${DEV_PID}" 2>/dev/null; then
    kill "${DEV_PID}" 2>/dev/null || true
    # 递归查找子进程一并终止
    pkill -P "${DEV_PID}" 2>/dev/null || true
    STOPPED=true
  fi
  rm -f "${PID_FILE}"
fi

# 2. 终止占用 1111 端口的进程
PORT_PIDS="$(lsof -ti:${PORT} 2>/dev/null || true)"
if [ -n "${PORT_PIDS}" ]; then
  echo "${PORT_PIDS}" | xargs kill -9 2>/dev/null || true
  STOPPED=true
fi

# 3. 终止可能残留的 rustpress serve 相关进程
pkill -f "rustpress.*serve" 2>/dev/null || true

# 4. 清理触发文件
rm -f "${SCRIPT_DIR}/.rebuild-trigger"

if [ "${STOPPED}" = true ]; then
  echo "✅ 本地开发服务器已成功停止，端口 :${PORT} 已释放。"
else
  echo "ℹ️ 未发现正在运行的开发服务器进程，端口 :${PORT} 当前空闲。"
fi
