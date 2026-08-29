#!/usr/bin/env bash
# status_dev.sh - 探知本地开发服务器运行状态
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="${SCRIPT_DIR}/.dev.pid"
PORT=1111
URL="http://127.0.0.1:${PORT}"

# 1. 检查 PID 文件
RECORDED_PID=""
PID_RUNNING=false
if [ -f "${PID_FILE}" ]; then
  RECORDED_PID="$(cat "${PID_FILE}" 2>/dev/null || true)"
  if [ -n "${RECORDED_PID}" ] && kill -0 "${RECORDED_PID}" 2>/dev/null; then
    PID_RUNNING=true
  fi
fi

# 2. 检查端口占用
PORT_PIDS="$(lsof -ti:${PORT} 2>/dev/null || true)"

# 3. 尝试 HTTP 探针请求
HTTP_STATUS=""
if [ -n "${PORT_PIDS}" ] || [ "${PID_RUNNING}" = true ]; then
  HTTP_STATUS="$(curl -s -o /dev/null -w "%{http_code}" --max-time 1 "${URL}" 2>/dev/null || true)"
fi

# 4. 汇总判断与输出
if [ -n "${PORT_PIDS}" ] || [ "${PID_RUNNING}" = true ]; then
  echo "🟢 [运行中] 本地开发服务器已启动"
  echo "--------------------------------------------------"
  [ -n "${RECORDED_PID}" ] && echo "  - 记录 PID:   ${RECORDED_PID} $([ "${PID_RUNNING}" = true ] && echo '(进程存活)' || echo '(PID已过期)')"
  [ -n "${PORT_PIDS}" ]    && echo "  - 端口占用:   :${PORT} (实际监听 PID: $(echo ${PORT_PIDS} | tr '\n' ' '))"
  echo "  - 访问地址:   ${URL}"
  if [ -n "${HTTP_STATUS}" ] && [ "${HTTP_STATUS}" != "000" ]; then
    echo "  - HTTP 状态:  HTTP ${HTTP_STATUS} (服务响应正常)"
  else
    echo "  - HTTP 状态:  正在等待响应 (可能正在初次编译构建中)"
  fi
  echo "--------------------------------------------------"
  echo "💡 提示: 停止服务请执行 ./stop_dev.sh"
  exit 0
else
  echo "⚪ [未运行] 本地开发服务器当前未启动"
  echo "--------------------------------------------------"
  echo "  - 端口状态:   :${PORT} 当前空闲"
  echo "--------------------------------------------------"
  echo "💡 提示: 启动服务请执行 ./start_dev.sh"
  exit 1
fi
