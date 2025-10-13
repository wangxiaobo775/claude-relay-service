@echo off
setlocal enabledelayedexpansion

REM 🏗️ 构建并推送 Docker 镜像到 Docker Hub
REM 使用说明:
REM   1. 确保已登录 Docker Hub: docker login
REM   2. 运行此脚本: build-and-push.bat [版本号]
REM   示例: build-and-push.bat v1.1.173

echo 🏗️ Claude Relay Service - Build and Push
echo ==========================================
echo.

REM 设置镜像信息
set DOCKER_USERNAME=wangxiaobo775
set IMAGE_NAME=claude-relay-service
set VERSION=%1

REM 如果没有提供版本号,使用 latest
if "%VERSION%"=="" (
    set VERSION=latest
    echo ⚠️  未指定版本号，使用默认版本: latest
) else (
    echo ✅ 使用版本号: %VERSION%
)
echo.

set IMAGE_TAG=%DOCKER_USERNAME%/%IMAGE_NAME%:%VERSION%
set LATEST_TAG=%DOCKER_USERNAME%/%IMAGE_NAME%:latest

REM 检查 Docker
where docker >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 错误: 未找到 Docker
    pause
    exit /b 1
)

REM 检查 Docker 是否运行
docker info >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 错误: Docker 未运行，请启动 Docker Desktop
    pause
    exit /b 1
)

echo ✅ Docker 环境检查通过
echo.

REM 检查 Docker Hub 登录状态
echo 🔐 检查 Docker Hub 登录状态...
docker info | findstr "Username" >nul
if %ERRORLEVEL% NEQ 0 (
    echo ⚠️  未登录 Docker Hub
    echo 请运行: docker login
    echo.
    set /p LOGIN_NOW="是否现在登录? (y/n): "
    if /i "!LOGIN_NOW!"=="y" (
        docker login
        if %ERRORLEVEL% NEQ 0 (
            echo ❌ 登录失败
            pause
            exit /b 1
        )
    ) else (
        echo ❌ 取消构建
        pause
        exit /b 1
    )
)
echo ✅ 已登录 Docker Hub
echo.

REM 显示构建信息
echo 📋 构建信息:
echo   镜像名称: %IMAGE_TAG%
if not "%VERSION%"=="latest" (
    echo   Latest标签: %LATEST_TAG%
)
echo   构建时间: %date% %time%
echo.

set /p CONFIRM="是否继续构建? (y/n): "
if /i not "!CONFIRM!"=="y" (
    echo ❌ 取消构建
    pause
    exit /b 0
)
echo.

REM 构建镜像
echo 🔨 开始构建镜像...
echo   命令: docker build -t %IMAGE_TAG% .
echo.
docker build -t %IMAGE_TAG% .
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 镜像构建失败
    pause
    exit /b 1
)
echo ✅ 镜像构建完成
echo.

REM 如果不是 latest，同时打上 latest 标签
if not "%VERSION%"=="latest" (
    echo 🏷️  添加 latest 标签...
    docker tag %IMAGE_TAG% %LATEST_TAG%
    if %ERRORLEVEL% NEQ 0 (
        echo ⚠️  警告: latest 标签添加失败
    ) else (
        echo ✅ latest 标签添加成功
    )
    echo.
)

REM 推送镜像
echo 📤 推送镜像到 Docker Hub...
echo   命令: docker push %IMAGE_TAG%
echo.
docker push %IMAGE_TAG%
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 镜像推送失败
    pause
    exit /b 1
)
echo ✅ 镜像推送完成: %IMAGE_TAG%
echo.

REM 推送 latest 标签
if not "%VERSION%"=="latest" (
    echo 📤 推送 latest 标签...
    docker push %LATEST_TAG%
    if %ERRORLEVEL% NEQ 0 (
        echo ⚠️  警告: latest 标签推送失败
    ) else (
        echo ✅ latest 标签推送完成: %LATEST_TAG%
    )
    echo.
)

REM 显示镜像信息
echo 🎉 构建和推送完成！
echo ==========================================
echo.
echo 📊 镜像信息:
docker images | findstr "%IMAGE_NAME%"
echo.
echo 🔗 Docker Hub 地址:
echo   https://hub.docker.com/r/%DOCKER_USERNAME%/%IMAGE_NAME%
echo.
echo 📝 用户使用方式:
echo   docker pull %IMAGE_TAG%
echo   或
echo   docker pull %LATEST_TAG%
echo.
echo 💡 提示:
echo   - 用户可以使用提供的 docker-compose-user.yml 快速部署
echo   - 查看 DOCKER_DEPLOY_GUIDE.md 了解详细使用说明
echo.

pause
