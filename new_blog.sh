#!/usr/bin/env bash
set -euo pipefail

# 获取项目根目录路径
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 获取当前年份
YEAR="$(date +%Y)"
TARGET_DIR="${PROJECT_ROOT}/source/${YEAR}"

# 确保年份目录存在
mkdir -p "${TARGET_DIR}"

# 标题处理：如果未传参数则默认为 "新标题"
TITLE="${*:-新标题}"

# 遍历目录查找最大数字序号
max_num=0
for file in "${TARGET_DIR}"/*.md; do
  [ -e "${file}" ] || continue
  filename="$(basename "${file}" .md)"
  if [[ "${filename}" =~ ^[0-9]+$ ]]; then
    if (( filename > max_num )); then
      max_num="${filename}"
    fi
  fi
done

# 下一个序号
next_num=$((max_num + 1))
target_file="${TARGET_DIR}/${next_num}.md"

if [ -f "${target_file}" ]; then
  echo "错误: 目标文件已存在: ${target_file}" >&2
  exit 1
fi

# 当前时间
CURRENT_DATE="$(date "+%Y-%m-%d %H:%M:%S")"

# 写入文件内容与 Frontmatter
cat <<EOF > "${target_file}"
---
title: ${TITLE}
date: ${CURRENT_DATE}
layout: blog
---

# ${TITLE}

EOF

echo "成功创建博客文件: ${target_file}"
