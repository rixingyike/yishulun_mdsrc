#!/usr/bin/env bash
# start_dev.sh - 启动本地热重载开发服务器
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="${SCRIPT_DIR}/.dev.pid"
PORT=1111

# 检查是否已有运行中的实例，若有则先优雅停止
if [ -f "${PID_FILE}" ]; then
  OLD_PID="$(cat "${PID_FILE}" 2>/dev/null || true)"
  if [ -n "${OLD_PID}" ] && kill -0 "${OLD_PID}" 2>/dev/null; then
    echo "⚠️ 检测到开发服务器已在运行 (PID: ${OLD_PID})，正在停止旧实例..."
    "${SCRIPT_DIR}/stop-dev.sh" >/dev/null 2>&1 || true
    sleep 1
  fi
fi

# 释放端口占用
lsof -ti:${PORT} | xargs kill -9 2>/dev/null || true

echo "🚀 正在启动本地热重载开发服务器..."
echo "🌐 本地预览地址: http://localhost:${PORT}"
echo "💡 提示: 新建/修改文章与模板将自动检测并热重载；可运行 ./stop-dev.sh 停止服务。"
echo "--------------------------------------------------------"

# 启动 mise 任务
mise run dev &
DEV_PID=$!
echo "${DEV_PID}" > "${PID_FILE}"

cleanup() {
  echo ""
  echo "正在停止本地开发服务器..."
  "${SCRIPT_DIR}/stop-dev.sh" >/dev/null 2>&1 || true
  exit 0
}

trap cleanup SIGINT SIGTERM

# 等待开发进程运行
wait "${DEV_PID}" 2>/dev/null || true
rm -f "${PID_FILE}"
