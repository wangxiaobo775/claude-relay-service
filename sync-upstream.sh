#!/bin/bash

# 🔄 同步上游主线更新脚本

set -e

echo "🔄 同步上游主线更新"
echo "=========================================="
echo ""

# 检查是否在 git 仓库中
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ 错误: 当前目录不是 git 仓库"
    exit 1
fi

# 检查当前分支
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "⚠️  警告: 当前不在 main 分支（当前分支: $CURRENT_BRANCH）"
    read -p "是否切换到 main 分支? (y/n): " SWITCH
    if [ "$SWITCH" = "y" ] || [ "$SWITCH" = "Y" ]; then
        git checkout main
    else
        echo "❌ 取消同步"
        exit 0
    fi
fi

# 检查工作目录是否干净
if ! git diff --quiet; then
    echo "⚠️  警告: 工作目录有未提交的更改"
    echo ""
    git status --short
    echo ""
    read -p "是否暂存这些更改? (y/n): " STASH
    if [ "$STASH" = "y" ] || [ "$STASH" = "Y" ]; then
        git stash
        echo "✅ 更改已暂存"
    else
        echo "❌ 请先提交或放弃更改"
        exit 1
    fi
fi

# 拉取上游最新变更
echo "📥 拉取上游最新变更..."
git fetch upstream
echo "✅ 拉取完成"
echo ""

# 检查是否有新的提交
COMMIT_COUNT=$(git rev-list --count main..upstream/main)
if [ "$COMMIT_COUNT" -eq 0 ]; then
    echo "✅ 已经是最新版本,无需同步!"
    echo ""
    echo "📊 当前版本信息:"
    git log --oneline -3
    echo ""
    exit 0
fi

echo "📋 发现 $COMMIT_COUNT 个新提交:"
echo ""
git log --oneline main..upstream/main
echo ""

# 确认是否继续
read -p "是否继续合并? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "❌ 取消同步"
    exit 0
fi

# 合并上游变更
echo ""
echo "🔀 合并上游变更..."
if ! git merge upstream/main --no-edit; then
    echo ""
    echo "⚠️  合并遇到冲突!"
    echo ""
    echo "📋 冲突文件列表:"
    git status --short | grep "^UU\|^AA\|^DD"
    echo ""
    echo "请按照以下步骤解决冲突:"
    echo "1. 编辑冲突文件,解决冲突标记"
    echo "2. 运行: git add <冲突文件>"
    echo "3. 运行: git commit -m 'merge: 解决合并冲突'"
    echo "4. 运行: git push origin main"
    echo ""
    echo "或者运行 git merge --abort 取消合并"
    echo ""
    exit 1
fi

echo "✅ 合并完成"
echo ""

# 推送到远程仓库
echo "📤 推送到你的 fork..."
git push origin main
echo "✅ 推送完成"
echo ""

# 恢复之前暂存的更改（如果有）
if git stash list | grep -q "stash@{0}"; then
    read -p "是否恢复之前暂存的更改? (y/n): " RESTORE
    if [ "$RESTORE" = "y" ] || [ "$RESTORE" = "Y" ]; then
        git stash pop
        echo "✅ 更改已恢复"
    fi
fi

echo ""
echo "🎉 同步完成!"
echo "=========================================="
echo ""
echo "📊 最新提交历史:"
git log --oneline -5
echo ""
echo "💡 提示:"
echo "- 如果推送触发了 GitHub Actions,可以访问 Actions 页面查看构建状态"
echo "- 如果有冲突,请查看 SYNC_UPSTREAM.md 了解详细解决步骤"
echo ""
