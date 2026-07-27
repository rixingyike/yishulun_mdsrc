#!/bin/bash

# 子模块目录名
SUBMODULE_DIR="skills-shared"

echo "🔄 正在同步 Skills 并保持在 main 分支..."

# --remote：去远端拉取最新 commit
# --merge：将拉取的内容安全合并到本地的 main 分支，防止退回到游离状态
git submodule update --remote --merge $SUBMODULE_DIR

# 检查子模块的 commit hash 是否在当前（父）项目中发生了变动
if git diff --quiet $SUBMODULE_DIR; then
    echo "✅ Skills 已经是最新版本，无需更新父项目指针。"
else
    echo "📦 发现新版本，正在更新父项目指针..."
    git add $SUBMODULE_DIR
    git commit -m "chore: auto-update skills submodule to latest"
    echo "🎉 更新完成！"
fi
