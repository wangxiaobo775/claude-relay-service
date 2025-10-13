#!/bin/bash

# 🚀 Claude Relay Service 快速启动脚本（带请求历史记录功能）

set -e

echo "🎯 Claude Relay Service - Quick Start"
echo "======================================"
echo ""

# 检查 Docker 和 Docker Compose
if ! command -v docker &> /dev/null; then
    echo "❌ 错误: 未找到 Docker，请先安装 Docker"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo "❌ 错误: 未找到 Docker Compose，请先安装 Docker Compose"
    exit 1
fi

echo "✅ Docker 和 Docker Compose 已安装"
echo ""

# 检查 .env 文件
if [ ! -f ".env" ]; then
    echo "❌ 错误: 未找到 .env 文件"
    echo "请先复制 .env.example 并配置必要的环境变量"
    exit 1
fi

# 检查必要的环境变量
source .env
if [ -z "$JWT_SECRET" ] || [ "$JWT_SECRET" = "your_jwt_secret_here_at_least_32_characters_long" ]; then
    echo "❌ 错误: JWT_SECRET 未配置"
    echo "请在 .env 文件中设置 JWT_SECRET"
    exit 1
fi

if [ -z "$ENCRYPTION_KEY" ] || [ "$ENCRYPTION_KEY" = "your_32_character_encryption_key" ]; then
    echo "❌ 错误: ENCRYPTION_KEY 未配置"
    echo "请在 .env 文件中设置 ENCRYPTION_KEY"
    exit 1
fi

echo "✅ 环境变量配置正确"
echo ""

# 创建必要的目录
echo "📁 创建数据目录..."
mkdir -p logs data redis_data
echo "✅ 目录创建完成"
echo ""

# 构建 Docker 镜像
echo "🔨 构建 Docker 镜像..."
docker compose build
echo "✅ 镜像构建完成"
echo ""

# 启动服务
echo "🚀 启动服务..."
docker compose up -d
echo "✅ 服务启动完成"
echo ""

# 等待服务就绪
echo "⏳ 等待服务就绪..."
for i in {1..30}; do
    if curl -sf http://localhost:3000/health > /dev/null 2>&1; then
        echo "✅ 服务已就绪!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "⚠️  警告: 服务可能未正常启动，请检查日志"
        docker compose logs --tail=50
        exit 1
    fi
    sleep 2
    echo -n "."
done
echo ""

# 显示服务信息
echo ""
echo "🎉 部署完成！"
echo "======================================"
echo ""
echo "📊 服务信息:"
echo "  Web 管理界面: http://localhost:3000/web"
echo "  API 端点:     http://localhost:3000/api/v1/messages"
echo "  健康检查:     http://localhost:3000/health"
echo ""
echo "👤 默认管理员账户:"
echo "  用户名: ${ADMIN_USERNAME:-admin}"
echo "  密码:   ${ADMIN_PASSWORD:-admin123456}"
echo ""
echo "📝 常用命令:"
echo "  查看日志:   docker compose logs -f"
echo "  停止服务:   docker compose down"
echo "  重启服务:   docker compose restart"
echo ""
echo "📖 完整文档请查看: DOCKER_DEPLOY_GUIDE.md"
echo ""
