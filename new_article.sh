#!/usr/bin/env bash
set -euo pipefail

# 获取项目根目录路径
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 参数校验：需要指定专栏
if [ $# -lt 1 ]; then
  echo "用法: $0 <专栏编号/目录名> [文章标题]"
  echo "示例: $0 1 我的专栏文章"
  exit 1
fi

COLUMN="$1"
shift

# 标题处理：如果未传第二个参数则默认为 "新标题"
RAW_TITLE="${*:-新标题}"
# 去除可能自带的 .md 后缀用于标题文本
TITLE="${RAW_TITLE%.md}"

TARGET_DIR="${PROJECT_ROOT}/source/columns/${COLUMN}"

# 确保专栏目录存在
mkdir -p "${TARGET_DIR}"

FILENAME="${TITLE}.md"
TARGET_FILE="${TARGET_DIR}/${FILENAME}"

if [ -f "${TARGET_FILE}" ]; then
  echo "错误: 目标文件已存在: ${TARGET_FILE}" >&2
  exit 1
fi

# 当前时间
CURRENT_DATE="$(date "+%Y-%m-%d %H:%M:%S")"

# 写入文件内容与 Frontmatter
cat <<EOF > "${TARGET_FILE}"
---
title: ${TITLE}
date: ${CURRENT_DATE}
layout: doc-item
---

# ${TITLE}

EOF

echo "成功创建专栏文章: ${TARGET_FILE}"

# 同步更新专栏 README.md 中的 catalog 列表
python3 - <<EOF
import os
import sys
import re

readme_path = os.path.join("${TARGET_DIR}", "README.md")
filename = "${FILENAME}"

if not os.path.exists(readme_path):
    content = f"""---
title: "专栏 ${COLUMN}"
layout: columns
catalog:
  - "{filename}"
date: "${CURRENT_DATE}"
---

# 专栏 ${COLUMN}
"""
    with open(readme_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"已创建并初始化专栏 README: {readme_path}")
    sys.exit(0)

with open(readme_path, "r", encoding="utf-8") as f:
    content = f.read()

# 匹配 frontmatter
fm_match = re.match(r"^---\r?\n(.*?)\r?\n---\r?\n?(.*)$", content, re.DOTALL)
if not fm_match:
    print(f"警告: {readme_path} 没有有效的 frontmatter，跳过更新 catalog。")
    sys.exit(0)

fm_text = fm_match.group(1)
body = fm_match.group(2) or ""

lines = fm_text.splitlines(keepends=True)
key_line_idx = -1
for idx, line in enumerate(lines):
    if re.match(r"^\s*catalog\s*:", line):
        key_line_idx = idx
        break

if key_line_idx != -1:
    cat_line = lines[key_line_idx]
    after_colon = cat_line.split(":", 1)[1].strip()

    items = []
    end_line_idx = key_line_idx + 1
    if after_colon.startswith("[") and after_colon.endswith("]"):
        raw_items = re.findall(r'["\']([^"\']+)["\']|([^,\[\]\s]+)', after_colon)
        items = [m[0] or m[1] for m in raw_items if m[0] or m[1]]
    else:
        while end_line_idx < len(lines):
            line = lines[end_line_idx]
            if line.strip() == "":
                end_line_idx += 1
                continue
            if re.match(r"^[ \t]+-", line):
                val_m = re.search(r'^[ \t]+-[ \t]*["\']?(.*?)["\']?\s*$', line)
                if val_m:
                    v = val_m.group(1).strip().strip('"').strip("'")
                    items.append(v)
                end_line_idx += 1
            elif re.match(r"^[ \t]+", line):
                end_line_idx += 1
            else:
                break

    if filename not in items:
        items.append(filename)

    cat_yaml_lines = ["catalog:"]
    for it in items:
        clean = it.replace('"', '\\"')
        cat_yaml_lines.append(f'  - "{clean}"')
    new_cat_block = "\n".join(cat_yaml_lines) + "\n"

    start_pos = sum(len(l) for l in lines[:key_line_idx])
    end_pos = sum(len(l) for l in lines[:end_line_idx])
    new_fm = fm_text[:start_pos] + new_cat_block + fm_text[end_pos:]
else:
    new_cat_block = f"catalog:\n  - \"{filename}\"\n"
    ctime_match = re.search(r"(^|\n)(createTime:|date:)", fm_text)
    if ctime_match:
        insert_idx = ctime_match.start(2)
        new_fm = fm_text[:insert_idx] + new_cat_block + fm_text[insert_idx:]
    else:
        new_fm = fm_text.rstrip() + "\n" + new_cat_block

new_content = f"---\n{new_fm.strip()}\n---\n{body}"
with open(readme_path, "w", encoding="utf-8") as f:
    f.write(new_content)

print(f"已将 '{filename}' 同步至 {readme_path} 的 catalog 列表中。")
EOF
