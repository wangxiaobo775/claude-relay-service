# 🐳 Docker 部署指南 - 带请求历史记录功能

本指南将帮助你使用 Docker 部署包含请求历史记录功能的 Claude Relay Service。

## 📋 前置要求

- Docker 20.10+
- Docker Compose 2.0+
- 至少 2GB 可用内存
- 至少 5GB 可用磁盘空间

## 🚀 快速开始

### 1️⃣ 生成安全密钥

首先需要生成 JWT 密钥和加密密钥：

```bash
# 生成 JWT_SECRET (至少32字符)
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# 生成 ENCRYPTION_KEY (必须32字符)
node -e "console.log(require('crypto').randomBytes(16).toString('hex'))"
```

### 2️⃣ 配置环境变量

编辑 `.env` 文件，将生成的密钥填入：

```bash
# 必须修改这两个值！
JWT_SECRET=你生成的JWT密钥
ENCRYPTION_KEY=你生成的加密密钥

# 可选：修改管理员凭据
ADMIN_USERNAME=admin
ADMIN_PASSWORD=你的安全密码
```

### 3️⃣ 构建并启动服务

```bash
# 构建 Docker 镜像
docker-compose build

# 启动服务（后台运行）
docker-compose up -d

# 查看日志
docker-compose logs -f claude-relay

# 查看服务状态
docker-compose ps
```

### 4️⃣ 访问服务

- **Web 管理界面**: http://localhost:3000/web
- **API 端点**: http://localhost:3000/api/v1/messages
- **健康检查**: http://localhost:3000/health

默认管理员账户：
- 用户名: `admin` (在 .env 中配置)
- 密码: `admin123456` (在 .env 中配置)

## 📊 请求历史记录功能

### 新增 API 端点

1. **查询请求历史**
   ```bash
   GET /api/v1/request-history?date=2025-01-15&limit=50&offset=0
   Headers: Authorization: Bearer <your-api-key>
   ```

2. **获取单个请求详情**
   ```bash
   GET /api/v1/request-history/:requestId
   Headers: Authorization: Bearer <your-api-key>
   ```

3. **获取请求统计**
   ```bash
   GET /api/v1/request-stats?date=2025-01-15
   Headers: Authorization: Bearer <your-api-key>
   ```

### 管理员端点

1. **查看所有请求历史**
   ```bash
   GET /admin/request-history?apiKeyId=xxx&date=2025-01-15
   ```

2. **删除请求记录**
   ```bash
   DELETE /admin/request-history/:requestId
   ```

3. **批量清理历史记录**
   ```bash
   POST /admin/request-history/cleanup
   Body: { "beforeDate": "2025-01-01", "apiKeyId": "xxx" }
   ```

## 🔧 高级配置

### 启用监控服务（可选）

```bash
# 启动带监控的完整服务
docker-compose --profile monitoring up -d

# 访问监控服务
# Redis Commander: http://localhost:8081
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3001 (admin/admin123)
```

### 自定义端口绑定

编辑 `.env` 文件：

```bash
PORT=3000           # 服务端口
BIND_HOST=0.0.0.0   # 绑定地址（生产环境建议 127.0.0.1）
```

或者修改 `docker-compose.yml` 中的端口映射：

```yaml
ports:
  - "127.0.0.1:8080:3000"  # 只监听本地8080端口
```

### 数据持久化

Docker Compose 会自动创建以下目录：

```
claude-relay-service/
├── logs/           # 应用日志
├── data/           # 应用数据
└── redis_data/     # Redis 数据持久化
```

## 🛠️ 常用命令

### 服务管理

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f claude-relay
docker-compose logs -f redis

# 进入容器
docker-compose exec claude-relay sh
docker-compose exec redis redis-cli
```

### 数据备份

```bash
# 备份 Redis 数据
docker-compose exec redis redis-cli SAVE
docker cp $(docker-compose ps -q redis):/data/dump.rdb ./backup/

# 备份应用日志和数据
tar -czf backup-$(date +%Y%m%d).tar.gz logs/ data/ redis_data/
```

### 更新服务

```bash
# 拉取最新代码
git fetch upstream
git merge upstream/main

# 重新构建镜像
docker-compose build --no-cache

# 重启服务
docker-compose down
docker-compose up -d
```

## 🔍 故障排查

### 查看容器状态

```bash
# 查看所有容器
docker-compose ps

# 查看容器详细信息
docker inspect $(docker-compose ps -q claude-relay)
```

### 检查日志

```bash
# 实时查看日志
docker-compose logs -f

# 查看最近100行日志
docker-compose logs --tail=100

# 查看错误日志
docker-compose logs | grep ERROR
```

### 连接问题

```bash
# 测试 Redis 连接
docker-compose exec redis redis-cli ping

# 测试健康检查
curl http://localhost:3000/health

# 检查网络
docker network ls
docker network inspect claude-relay-service_claude-relay-network
```

### Redis 数据检查

```bash
# 进入 Redis CLI
docker-compose exec redis redis-cli

# 查看所有键
> KEYS *

# 查看请求历史记录
> KEYS request:*

# 查看特定请求
> GET request:history:xxx
```

## 🔐 安全建议

1. **修改默认密码**
   - 更改 `.env` 中的 `ADMIN_PASSWORD`
   - 使用强密码（至少12字符，包含大小写字母、数字、特殊字符）

2. **限制访问**
   - 生产环境设置 `BIND_HOST=127.0.0.1`
   - 使用 Nginx/Caddy 作为反向代理
   - 启用 HTTPS

3. **定期备份**
   - 每天备份 Redis 数据
   - 保留至少7天的备份

4. **监控日志**
   - 定期检查 `logs/` 目录
   - 设置日志轮转 (`LOG_MAX_SIZE`, `LOG_MAX_FILES`)

## 📈 性能优化

### Redis 配置优化

编辑 `docker-compose.yml` 中的 Redis 命令：

```yaml
command: redis-server
  --save 60 1
  --appendonly yes
  --appendfsync everysec
  --maxmemory 2gb
  --maxmemory-policy allkeys-lru
```

### 应用配置优化

在 `.env` 中调整：

```bash
# 减少清理间隔（更频繁清理）
CLEANUP_INTERVAL=1800000  # 30分钟

# 减少数据保留时间（节省空间）
TOKEN_USAGE_RETENTION=604800000  # 7天

# 调整日志级别（生产环境）
LOG_LEVEL=warn
```

## 🌐 反向代理配置

### Nginx 示例

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # SSE 支持
        proxy_buffering off;
        proxy_cache off;
        proxy_set_header Connection '';
        proxy_http_version 1.1;
        chunked_transfer_encoding off;
    }
}
```

### Caddy 示例

```caddy
your-domain.com {
    reverse_proxy localhost:3000
}
```

## 🆘 获取帮助

如果遇到问题：

1. 查看日志: `docker-compose logs -f`
2. 检查健康状态: `curl http://localhost:3000/health`
3. 查看 GitHub Issues: https://github.com/wangxiaobo775/claude-relay-service/issues

## 🎉 完成！

你的 Claude Relay Service（带请求历史记录功能）现在应该已经运行了！

访问 http://localhost:3000/web 开始使用管理界面。
