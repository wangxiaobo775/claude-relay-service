# 🐳 Claude Relay Service - Docker 版

[![Docker Hub](https://img.shields.io/docker/pulls/wangxiaobo775/claude-relay-service.svg)](https://hub.docker.com/r/wangxiaobo775/claude-relay-service)
[![Docker Image Size](https://img.shields.io/docker/image-size/wangxiaobo775/claude-relay-service/latest)](https://hub.docker.com/r/wangxiaobo775/claude-relay-service)

**基于 [Wei-Shaw/claude-relay-service](https://github.com/Wei-Shaw/claude-relay-service) 并集成了请求历史记录功能 ([PR #21](https://github.com/Wei-Shaw/claude-relay-service/pull/21))**

## ✨ 新增功能

- ✅ **完整的请求历史记录系统**
- ✅ **详细的 Token 使用统计**
- ✅ **高级筛选和搜索**
- ✅ **Web 管理界面支持**
- ✅ **数据安全隔离**

## 🚀 快速开始

### 方式1: 一键启动（推荐）

```bash
# 1. 创建 .env 配置文件（必须！）
cat > .env << 'EOF'
JWT_SECRET=你的JWT密钥_至少32字符
ENCRYPTION_KEY=你的加密密钥_必须32字符
ADMIN_USERNAME=admin
ADMIN_PASSWORD=你的安全密码
EOF

# 2. 下载用户版 docker-compose 配置
curl -O https://raw.githubusercontent.com/wangxiaobo775/claude-relay-service/main/docker-compose-user.yml

# 3. 启动服务
docker compose -f docker-compose-user.yml up -d

# 4. 访问 Web 界面
open http://localhost:3000/web
```

### 方式2: 手动配置

```bash
# 1. 生成安全密钥
node -e "console.log('JWT_SECRET=' + require('crypto').randomBytes(32).toString('hex'))"
node -e "console.log('ENCRYPTION_KEY=' + require('crypto').randomBytes(16).toString('hex'))"

# 2. 创建 docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  claude-relay:
    image: wangxiaobo775/claude-relay-service:latest
    ports:
      - "3000:3000"
    environment:
      - JWT_SECRET=${JWT_SECRET}
      - ENCRYPTION_KEY=${ENCRYPTION_KEY}
      - ADMIN_USERNAME=${ADMIN_USERNAME:-admin}
      - ADMIN_PASSWORD=${ADMIN_PASSWORD:-admin123456}
      - REDIS_HOST=redis
    volumes:
      - ./logs:/app/logs
      - ./data:/app/data
    depends_on:
      - redis
  redis:
    image: redis:7-alpine
    volumes:
      - ./redis_data:/data
    command: redis-server --save 60 1 --appendonly yes
EOF

# 3. 启动服务
docker compose up -d
```

## 📦 Docker 镜像

```bash
# 拉取最新版本
docker pull wangxiaobo775/claude-relay-service:latest

# 拉取特定版本
docker pull wangxiaobo775/claude-relay-service:v1.1.173
```

**Docker Hub**: https://hub.docker.com/r/wangxiaobo775/claude-relay-service

## 🌐 服务访问

- **Web 管理界面**: http://localhost:3000/web
- **API 端点**: http://localhost:3000/api/v1/messages
- **健康检查**: http://localhost:3000/health

默认管理员账户:
- 用户名: `admin`
- 密码: `admin123456` (请及时修改)

## 🆕 请求历史记录功能

### API 端点

```bash
# 查询请求历史
GET /api/v1/request-history?date=2025-01-15&limit=50
Authorization: Bearer <your-api-key>

# 查看单个请求详情
GET /api/v1/request-history/:requestId
Authorization: Bearer <your-api-key>

# 获取请求统计
GET /api/v1/request-stats?date=2025-01-15
Authorization: Bearer <your-api-key>
```

### 管理员端点

- `GET /admin/request-history` - 查看所有请求历史
- `DELETE /admin/request-history/:id` - 删除请求记录
- `POST /admin/request-history/cleanup` - 批量清理

## 🔧 常用命令

```bash
# 启动服务
docker compose up -d

# 查看日志
docker compose logs -f

# 停止服务
docker compose down

# 更新镜像
docker compose pull && docker compose up -d

# 重启服务
docker compose restart

# 查看状态
docker compose ps
```

## 📊 数据备份

```bash
# 备份所有数据
tar -czf backup-$(date +%Y%m%d).tar.gz logs/ data/ redis_data/

# 恢复数据
tar -xzf backup-20250115.tar.gz
```

## 🔐 安全建议

1. **修改默认密码**: 在 `.env` 中设置强密码
2. **限制访问**: 使用 `127.0.0.1:3000:3000` 只监听本地
3. **启用 HTTPS**: 使用 Nginx/Caddy 反向代理
4. **定期备份**: 备份 `data/` 和 `redis_data/` 目录

## 📚 完整文档

- **Docker Hub 使用指南**: [DOCKER_HUB_USAGE.md](./DOCKER_HUB_USAGE.md)
- **完整部署指南**: [DOCKER_DEPLOY_GUIDE.md](./DOCKER_DEPLOY_GUIDE.md)
- **项目说明**: [CLAUDE.md](./CLAUDE.md)

## 🔗 相关链接

- **GitHub 仓库**: https://github.com/wangxiaobo775/claude-relay-service
- **Docker Hub**: https://hub.docker.com/r/wangxiaobo775/claude-relay-service
- **原始项目**: https://github.com/Wei-Shaw/claude-relay-service
- **请求历史功能 PR**: https://github.com/Wei-Shaw/claude-relay-service/pull/21

## 🆘 获取帮助

遇到问题?
- 查看 [Issues](https://github.com/wangxiaobo775/claude-relay-service/issues)
- 查看日志: `docker compose logs -f`

## 📄 许可证

MIT License

---

**基于 Wei-Shaw/claude-relay-service 构建，集成请求历史记录功能**
