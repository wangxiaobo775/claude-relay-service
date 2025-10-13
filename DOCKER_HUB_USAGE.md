# 🐳 Docker Hub 快速部署指南

本版本包含完整的**请求历史记录功能**,可以直接从 Docker Hub 拉取镜像使用。

## 🚀 快速开始（3步部署）

### 1️⃣ 创建配置文件

创建 `.env` 文件并配置必要的环境变量:

```bash
# 生成安全密钥
node -e "console.log('JWT_SECRET=' + require('crypto').randomBytes(32).toString('hex'))"
node -e "console.log('ENCRYPTION_KEY=' + require('crypto').randomBytes(16).toString('hex'))"
```

将生成的密钥填入 `.env` 文件:

```env
# 🔐 安全配置（必填）
JWT_SECRET=你生成的JWT密钥
ENCRYPTION_KEY=你生成的加密密钥

# 👤 管理员凭据
ADMIN_USERNAME=admin
ADMIN_PASSWORD=你的安全密码

# 其他配置（可选）
PORT=3000
LOG_LEVEL=info
```

### 2️⃣ 下载部署配置

```bash
# 下载用户版 docker-compose 配置
curl -O https://raw.githubusercontent.com/wangxiaobo775/claude-relay-service/main/docker-compose-user.yml

# 或者手动创建（内容见下方）
```

### 3️⃣ 启动服务

```bash
# 启动服务
docker compose -f docker-compose-user.yml up -d

# 查看日志
docker compose -f docker-compose-user.yml logs -f

# 检查状态
docker compose -f docker-compose-user.yml ps
```

就这么简单! 🎉

## 📦 可用镜像

```bash
# 最新版本（推荐）
docker pull wangxiaobo775/claude-relay-service:latest

# 特定版本
docker pull wangxiaobo775/claude-relay-service:v1.1.173
```

**Docker Hub 地址**: https://hub.docker.com/r/wangxiaobo775/claude-relay-service

## 🌐 访问服务

启动成功后:

- **Web 管理界面**: http://localhost:3000/web
- **API 端点**: http://localhost:3000/api/v1/messages
- **健康检查**: http://localhost:3000/health
- **默认账户**: admin / admin123456 (请及时修改)

## 🆕 请求历史记录功能

本版本新增了完整的请求历史记录系统:

### API 端点

1. **查询请求历史**
   ```bash
   GET /api/v1/request-history?date=2025-01-15&limit=50&offset=0
   Headers: Authorization: Bearer <your-api-key>
   ```

2. **查看单个请求详情**
   ```bash
   GET /api/v1/request-history/:requestId
   Headers: Authorization: Bearer <your-api-key>
   ```

3. **获取请求统计**
   ```bash
   GET /api/v1/request-stats?date=2025-01-15
   Headers: Authorization: Bearer <your-api-key>
   ```

### Web 界面

在管理后台中可以:
- 📊 查看所有 API Key 的请求历史
- 🔍 按日期、模型、API Key 筛选
- 📈 查看统计图表和趋势
- 🗑️ 清理旧的历史记录

## 📋 完整的 docker-compose-user.yml

如果无法下载，可以手动创建此文件:

```yaml
version: '3.8'

services:
  claude-relay:
    image: wangxiaobo775/claude-relay-service:latest
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - ./logs:/app/logs
      - ./data:/app/data
    environment:
      - JWT_SECRET=${JWT_SECRET}
      - ENCRYPTION_KEY=${ENCRYPTION_KEY}
      - ADMIN_USERNAME=${ADMIN_USERNAME:-admin}
      - ADMIN_PASSWORD=${ADMIN_PASSWORD:-admin123456}
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    depends_on:
      - redis
    networks:
      - claude-relay-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    volumes:
      - ./redis_data:/data
    command: redis-server --save 60 1 --appendonly yes
    networks:
      - claude-relay-network

networks:
  claude-relay-network:
    driver: bridge
```

## 🔧 常用命令

```bash
# 拉取最新镜像
docker pull wangxiaobo775/claude-relay-service:latest

# 启动服务
docker compose -f docker-compose-user.yml up -d

# 查看日志
docker compose -f docker-compose-user.yml logs -f

# 停止服务
docker compose -f docker-compose-user.yml down

# 重启服务
docker compose -f docker-compose-user.yml restart

# 更新到最新版本
docker compose -f docker-compose-user.yml pull
docker compose -f docker-compose-user.yml up -d
```

## 📊 数据持久化

服务会自动创建以下目录保存数据:

```
.
├── logs/         # 应用日志
├── data/         # 应用数据
└── redis_data/   # Redis 数据（包含请求历史）
```

**重要**: 这些目录包含所有重要数据,请定期备份!

## 🔐 安全建议

1. **修改默认密码**
   ```bash
   # 在 .env 中设置强密码
   ADMIN_PASSWORD=你的强密码
   ```

2. **限制访问范围**
   ```yaml
   # 只监听本地,通过反向代理暴露
   ports:
     - "127.0.0.1:3000:3000"
   ```

3. **使用 HTTPS**
   - 推荐使用 Nginx/Caddy 作为反向代理
   - 配置 SSL 证书

## 🌐 反向代理示例

### Nginx

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # SSE 支持（流式响应）
        proxy_buffering off;
        proxy_cache off;
        proxy_http_version 1.1;
        proxy_set_header Connection '';
    }
}
```

### Caddy

```caddy
your-domain.com {
    reverse_proxy localhost:3000
}
```

## 🔄 版本更新

### 更新到最新版本

```bash
# 1. 拉取最新镜像
docker compose -f docker-compose-user.yml pull

# 2. 重启服务
docker compose -f docker-compose-user.yml down
docker compose -f docker-compose-user.yml up -d

# 3. 查看版本
curl http://localhost:3000/health
```

### 回滚到特定版本

```bash
# 修改 docker-compose-user.yml 中的镜像版本
image: wangxiaobo775/claude-relay-service:v1.1.173

# 重启服务
docker compose -f docker-compose-user.yml up -d
```

## 📈 性能优化

### 调整 Redis 配置

```yaml
redis:
  command: >
    redis-server
    --save 60 1
    --appendonly yes
    --maxmemory 2gb
    --maxmemory-policy allkeys-lru
```

### 调整应用配置

在 `.env` 中:

```env
# 减少日志大小
LOG_LEVEL=warn
LOG_MAX_SIZE=5m
LOG_MAX_FILES=3

# 调整清理间隔
CLEANUP_INTERVAL=1800000  # 30分钟
TOKEN_USAGE_RETENTION=604800000  # 7天
```

## 🐛 故障排查

### 查看日志

```bash
# 实时查看所有日志
docker compose -f docker-compose-user.yml logs -f

# 只看应用日志
docker compose -f docker-compose-user.yml logs -f claude-relay

# 只看 Redis 日志
docker compose -f docker-compose-user.yml logs -f redis
```

### 检查健康状态

```bash
# 健康检查
curl http://localhost:3000/health

# Redis 连接测试
docker compose -f docker-compose-user.yml exec redis redis-cli ping

# 查看容器状态
docker compose -f docker-compose-user.yml ps
```

### 常见问题

1. **无法连接到 Redis**
   - 检查 Redis 容器是否运行: `docker ps`
   - 查看 Redis 日志: `docker compose logs redis`

2. **管理员登录失败**
   - 确认 `.env` 中的账户密码配置
   - 检查应用日志中的错误信息

3. **请求历史记录不显示**
   - 确认已发送至少一个请求
   - 检查 Redis 中的数据: `docker compose exec redis redis-cli KEYS request:*`

## 📚 完整文档

- **GitHub 仓库**: https://github.com/wangxiaobo775/claude-relay-service
- **原始项目**: https://github.com/Wei-Shaw/claude-relay-service
- **PR #21 详情**: https://github.com/Wei-Shaw/claude-relay-service/pull/21

## 🆘 获取帮助

如果遇到问题:

1. 查看 [Issues](https://github.com/wangxiaobo775/claude-relay-service/issues)
2. 查看应用日志: `docker compose logs -f`
3. 提交新的 Issue

## 📄 许可证

MIT License - 详见 LICENSE 文件

---

**享受你的 Claude Relay Service! 🎉**

带请求历史记录功能,让你的 API 使用更加透明和可控。
