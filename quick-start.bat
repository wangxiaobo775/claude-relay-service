@echo off
setlocal enabledelayedexpansion

REM 🚀 Claude Relay Service 快速启动脚本（Windows版 - 带请求历史记录功能）

echo 🎯 Claude Relay Service - Quick Start
echo ======================================
echo.

REM 检查 Docker
where docker >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 错误: 未找到 Docker，请先安装 Docker Desktop
    pause
    exit /b 1
)

REM 检查 Docker Compose
docker compose version >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 错误: 未找到 Docker Compose，请先安装 Docker Compose
    pause
    exit /b 1
)

echo ✅ Docker 和 Docker Compose 已安装
echo.

REM 检查 .env 文件
if not exist ".env" (
    echo ❌ 错误: 未找到 .env 文件
    echo 请先复制 .env.example 并配置必要的环境变量
    pause
    exit /b 1
)

echo ✅ 环境配置文件存在
echo.

REM 创建必要的目录
echo 📁 创建数据目录...
if not exist "logs" mkdir logs
if not exist "data" mkdir data
if not exist "redis_data" mkdir redis_data
echo ✅ 目录创建完成
echo.

REM 构建 Docker 镜像
echo 🔨 构建 Docker 镜像...
docker compose build
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 镜像构建失败
    pause
    exit /b 1
)
echo ✅ 镜像构建完成
echo.

REM 启动服务
echo 🚀 启动服务...
docker compose up -d
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 服务启动失败
    pause
    exit /b 1
)
echo ✅ 服务启动完成
echo.

REM 等待服务就绪
echo ⏳ 等待服务就绪...
set /a count=0
:wait_loop
curl -sf http://localhost:3000/health >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ 服务已就绪!
    goto :service_ready
)
set /a count+=1
if %count% GEQ 30 (
    echo ⚠️  警告: 服务可能未正常启动，请检查日志
    docker compose logs --tail=50
    pause
    exit /b 1
)
timeout /t 2 /nobreak >nul
echo|set /p=.
goto :wait_loop

:service_ready
echo.
echo.
echo 🎉 部署完成！
echo ======================================
echo.
echo 📊 服务信息:
echo   Web 管理界面: http://localhost:3000/web
echo   API 端点:     http://localhost:3000/api/v1/messages
echo   健康检查:     http://localhost:3000/health
echo.
echo 👤 默认管理员账户:
echo   用户名: admin
echo   密码:   admin123456
echo.
echo 📝 常用命令:
echo   查看日志:   docker compose logs -f
echo   停止服务:   docker compose down
echo   重启服务:   docker compose restart
echo.
echo 📖 完整文档请查看: DOCKER_DEPLOY_GUIDE.md
echo.
pause
