@echo off
setlocal enabledelayedexpansion

REM 🔄 同步上游主线更新脚本

echo 🔄 同步上游主线更新
echo ==========================================
echo.

REM 检查是否在 git 仓库中
git rev-parse --git-dir >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 错误: 当前目录不是 git 仓库
    pause
    exit /b 1
)

REM 检查当前分支
for /f "tokens=*" %%i in ('git branch --show-current') do set CURRENT_BRANCH=%%i
if not "%CURRENT_BRANCH%"=="main" (
    echo ⚠️  警告: 当前不在 main 分支（当前分支: %CURRENT_BRANCH%）
    set /p SWITCH="是否切换到 main 分支? (y/n): "
    if /i "!SWITCH!"=="y" (
        git checkout main
        if %ERRORLEVEL% NEQ 0 (
            echo ❌ 切换分支失败
            pause
            exit /b 1
        )
    ) else (
        echo ❌ 取消同步
        pause
        exit /b 0
    )
)

REM 检查工作目录是否干净
git diff --quiet
if %ERRORLEVEL% NEQ 0 (
    echo ⚠️  警告: 工作目录有未提交的更改
    echo.
    git status --short
    echo.
    set /p STASH="是否暂存这些更改? (y/n): "
    if /i "!STASH!"=="y" (
        git stash
        echo ✅ 更改已暂存
    ) else (
        echo ❌ 请先提交或放弃更改
        pause
        exit /b 1
    )
)

REM 拉取上游最新变更
echo 📥 拉取上游最新变更...
git fetch upstream
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 拉取上游失败
    pause
    exit /b 1
)
echo ✅ 拉取完成
echo.

REM 检查是否有新的提交
git log --oneline main..upstream/main >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    for /f %%i in ('git rev-list --count main..upstream/main') do set COMMIT_COUNT=%%i
    if !COMMIT_COUNT! EQU 0 (
        echo ✅ 已经是最新版本,无需同步!
        echo.
        echo 📊 当前版本信息:
        git log --oneline -3
        echo.
        pause
        exit /b 0
    )

    echo 📋 发现 !COMMIT_COUNT! 个新提交:
    echo.
    git log --oneline main..upstream/main
    echo.
)

REM 确认是否继续
set /p CONFIRM="是否继续合并? (y/n): "
if /i not "!CONFIRM!"=="y" (
    echo ❌ 取消同步
    pause
    exit /b 0
)

REM 合并上游变更
echo.
echo 🔀 合并上游变更...
git merge upstream/main --no-edit
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ⚠️  合并遇到冲突!
    echo.
    echo 📋 冲突文件列表:
    git status --short | findstr "^UU\|^AA\|^DD"
    echo.
    echo 请按照以下步骤解决冲突:
    echo 1. 编辑冲突文件,解决冲突标记
    echo 2. 运行: git add ^<冲突文件^>
    echo 3. 运行: git commit -m "merge: 解决合并冲突"
    echo 4. 运行: git push origin main
    echo.
    echo 或者运行 git merge --abort 取消合并
    echo.
    pause
    exit /b 1
)

echo ✅ 合并完成
echo.

REM 推送到远程仓库
echo 📤 推送到你的 fork...
git push origin main
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 推送失败
    pause
    exit /b 1
)

echo ✅ 推送完成
echo.

REM 恢复之前暂存的更改（如果有）
git stash list | findstr "stash@{0}" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set /p RESTORE="是否恢复之前暂存的更改? (y/n): "
    if /i "!RESTORE!"=="y" (
        git stash pop
        echo ✅ 更改已恢复
    )
)

echo.
echo 🎉 同步完成!
echo ==========================================
echo.
echo 📊 最新提交历史:
git log --oneline -5
echo.
echo 💡 提示:
echo - 如果推送触发了 GitHub Actions,可以访问 Actions 页面查看构建状态
echo - 如果有冲突,请查看 SYNC_UPSTREAM.md 了解详细解决步骤
echo.

pause
