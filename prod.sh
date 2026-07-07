#!/usr/bin/env bash
set -euo pipefail

# 用法: ./prod.sh [port] [full]
#   port  - 服务器端口（默认 1111）
#   full  - 传此参数则删除 public/ 目录触发全量编译
PORT="${1:-1111}"
FULL="${2:-}"
RUSTPRESS_DIR="/Users/jsmn/workspace/rustpress"
RUSTPRESS_BIN="$RUSTPRESS_DIR/target/release/rustpress"
CURRENT_DIR="/Users/jsmn/workspace/yishulun_mdsrc"

# 1. 链接本地的 themes 文件夹到当前博客根目录下，以便 rustpress 能够找到 "light" 主题
echo "=== [Production] 检查 themes 目录 ==="
if [ ! -d "$CURRENT_DIR/themes" ] && [ ! -L "$CURRENT_DIR/themes" ]; then
  if [ -d "$RUSTPRESS_DIR/themes" ]; then
    echo "=== [Production] 正在链接 themes 目录 ==="
    ln -sfn "$RUSTPRESS_DIR/themes" "$CURRENT_DIR/themes"
  fi
fi

# 2. 编译本地的 rustpress 项目
echo "=== [Production] 正在 Release 模式下编译 RustPress ==="
(cd "$RUSTPRESS_DIR" && cargo build --release)

# 3. 生产环境构建，以 source 为源码目录
if [ "$FULL" = "full" ]; then
  echo "=== [Production] 全量编译模式：删除 public/ 目录 ==="
  rm -rf "$CURRENT_DIR/public"
fi
echo "=== [Production] 正在生成静态博客网站 HTML/CSS/JS ==="
"$RUSTPRESS_BIN" --md-dir source build --output-dir public

# 4. 启动博客程序服务
echo "=== [Production] 正在启动生产静态文件服务器，端口：$PORT ==="
# 关闭 hotreload (--no-hotreload)
dev=pushpen env=pushpen "$RUSTPRESS_BIN" --md-dir source serve --port "$PORT" --no-hotreload --output-dir public
