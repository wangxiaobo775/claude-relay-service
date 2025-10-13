# 🔄 从官方版本升级到带请求历史功能版本指南

## 📋 升级概述

如果你已经部署了官方版本 `weishaw/claude-relay-service`,本指南将帮助你平滑升级到带有请求历史记录功能的版本 `wangxiaobo775/claude-relay-service`。

### ✨ 升级后你将获得

- ✅ **请求历史记录系统** - 完整的API请求历史跟踪
- ✅ **详细的Token使用统计** - 精确到每个请求的token使用
- ✅ **高级筛选和搜索** - 按日期、模型、API Key筛选
- ✅ **Web管理界面** - 可视化查看和管理历史记录
- ✅ **成本追踪** - 精确的费用计算

### ⚠️ 兼容性说明

- ✅ **数据兼容**: 所有现有数据(API Keys、账户、配置)完全兼容
- ✅ **配置兼容**: 现有的 `.env` 配置无需修改
- ✅ **API兼容**: 所有现有API端点保持不变
- ✅ **向后兼容**: 只增加新功能,不破坏现有功能

---

## 🚀 升级方法

根据你的部署方式选择对应的升级方法:

### 方法1: Docker Compose 部署（推荐）

#### 📊 适用场景
- 使用 `docker-compose.yml` 部署
- 使用官方镜像 `weishaw/claude-relay-service`

#### 🔧 升级步骤

**1. 备份现有数据（重要！）**

```bash
# 停止服务
docker compose down

# 备份数据目录
tar -czf backup-$(date +%Y%m%d).tar.gz data/ logs/ redis_data/

# 或者只备份 Redis 数据
docker compose exec redis redis-cli SAVE
cp redis_data/dump.rdb redis_data/dump.rdb.backup
```

**2. 更新 docker-compose.yml**

编辑你的 `docker-compose.yml`,将镜像名称从:
```yaml
services:
  claude-relay:
    image: weishaw/claude-relay-service:latest
```

改为:
```yaml
services:
  claude-relay:
    image: wangxiaobo775/claude-relay-service:latest
```

**完整示例:**
```yaml
version: '3.8'

services:
  claude-relay:
    image: wangxiaobo775/claude-relay-service:latest  # 👈 修改这里
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - ./logs:/app/logs
      - ./data:/app/data
    environment:
      # 保持原有的环境变量配置不变
      - JWT_SECRET=${JWT_SECRET}
      - ENCRYPTION_KEY=${ENCRYPTION_KEY}
      - ADMIN_USERNAME=${ADMIN_USERNAME}
      - ADMIN_PASSWORD=${ADMIN_PASSWORD}
      - REDIS_HOST=redis
      # ... 其他配置保持不变
    depends_on:
      - redis

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    volumes:
      - ./redis_data:/data
    command: redis-server --save 60 1 --appendonly yes
```

**3. 拉取新镜像**

```bash
# 拉取新版本镜像
docker compose pull

# 查看镜像信息
docker images | grep claude-relay-service
```

**4. 启动服务**

```bash
# 启动新版本
docker compose up -d

# 查看日志确认启动成功
docker compose logs -f claude-relay
```

**5. 验证升级**

```bash
# 检查健康状态
curl http://localhost:3000/health

# 检查新的请求历史API端点
curl -H "Authorization: Bearer cr_your_api_key" \
  http://localhost:3000/api/v1/request-history

# 访问Web界面,应该能看到新的"请求历史"菜单
open http://localhost:3000/web
```

**6. 清理旧镜像（可选）**

```bash
# 删除旧的官方镜像
docker rmi weishaw/claude-relay-service:latest
```

---

### 方法2: Docker 单容器部署

#### 📊 适用场景
- 使用 `docker run` 命令部署
- 没有使用 docker-compose

#### 🔧 升级步骤

**1. 备份数据**

```bash
# 停止容器
docker stop claude-relay

# 备份容器数据
docker cp claude-relay:/app/data ./data-backup
docker cp claude-relay:/app/logs ./logs-backup

# 备份 Redis 数据
docker exec redis redis-cli SAVE
docker cp redis:/data/dump.rdb ./redis-backup/
```

**2. 停止并删除旧容器**

```bash
# 停止容器
docker stop claude-relay

# 删除容器（数据卷会保留）
docker rm claude-relay
```

**3. 拉取新镜像**

```bash
docker pull wangxiaobo775/claude-relay-service:latest
```

**4. 启动新容器**

使用相同的参数启动新容器,只需将镜像名改为 `wangxiaobo775/claude-relay-service:latest`:

```bash
docker run -d \
  --name claude-relay \
  -p 3000:3000 \
  -v ./data:/app/data \
  -v ./logs:/app/logs \
  -e JWT_SECRET=your_jwt_secret \
  -e ENCRYPTION_KEY=your_encryption_key \
  -e ADMIN_USERNAME=admin \
  -e ADMIN_PASSWORD=your_password \
  -e REDIS_HOST=redis \
  --link redis:redis \
  wangxiaobo775/claude-relay-service:latest  # 👈 新镜像
```

**5. 验证升级**

```bash
# 查看容器日志
docker logs -f claude-relay

# 检查健康状态
curl http://localhost:3000/health
```

---

### 方法3: 源码部署升级

#### 📊 适用场景
- 直接使用源码部署
- 使用 `npm start` 运行

#### 🔧 升级步骤

**1. 备份现有代码和数据**

```bash
# 备份整个项目目录
cp -r /path/to/claude-relay-service /path/to/claude-relay-service.backup

# 或者只备份数据
tar -czf data-backup-$(date +%Y%m%d).tar.gz data/ logs/ redis_data/
```

**2. 拉取新版本代码**

如果你是从官方仓库克隆的:

```bash
cd /path/to/claude-relay-service

# 添加新的远程仓库
git remote add wangxiaobo775 https://github.com/wangxiaobo775/claude-relay-service.git

# 拉取新版本
git fetch wangxiaobo775

# 切换到新版本
git checkout wangxiaobo775/main
```

或者直接克隆新仓库:

```bash
# 克隆新仓库
git clone https://github.com/wangxiaobo775/claude-relay-service.git claude-relay-service-new

# 复制配置和数据
cp claude-relay-service/.env claude-relay-service-new/
cp -r claude-relay-service/data claude-relay-service-new/
cp -r claude-relay-service/logs claude-relay-service-new/
cp -r claude-relay-service/redis_data claude-relay-service-new/

# 切换到新目录
cd claude-relay-service-new
```

**3. 安装依赖**

```bash
# 安装后端依赖
npm install

# 安装前端依赖
cd web/admin-spa
npm install
npm run build
cd ../..
```

**4. 重启服务**

```bash
# 停止旧服务
npm run service:stop

# 启动新服务
npm run service:start:daemon

# 查看状态
npm run service:status

# 查看日志
npm run service:logs
```

**5. 验证升级**

```bash
curl http://localhost:3000/health
```

---

## 🔍 升级后验证清单

升级完成后,请逐一检查以下项目:

### 1. 基础功能验证

- [ ] 服务正常启动: `docker compose ps` 或 `npm run service:status`
- [ ] 健康检查通过: `curl http://localhost:3000/health`
- [ ] Web界面可访问: `http://localhost:3000/web`
- [ ] 可以正常登录管理后台

### 2. 现有功能验证

- [ ] API Keys 列表正常显示
- [ ] Claude 账户配置正常
- [ ] 可以正常发送 API 请求
- [ ] Token 使用统计正常
- [ ] 日志记录正常

### 3. 新功能验证

- [ ] Web界面左侧菜单有"请求历史"选项
- [ ] 可以查看请求历史列表
- [ ] 可以筛选和搜索历史记录
- [ ] 可以查看单个请求详情
- [ ] 请求统计图表正常显示

### 4. API端点验证

```bash
# 测试请求历史API
curl -H "Authorization: Bearer cr_your_api_key" \
  "http://localhost:3000/api/v1/request-history?limit=10"

# 测试请求统计API
curl -H "Authorization: Bearer cr_your_api_key" \
  "http://localhost:3000/api/v1/request-stats"
```

---

## 📊 数据迁移说明

### ✅ 无需数据迁移!

好消息:升级到新版本**无需任何数据迁移**!

- ✅ 所有现有数据(API Keys、账户、配置)自动兼容
- ✅ Redis 数据结构完全兼容
- ✅ 新功能只会添加新的 Redis 键,不影响现有数据

### 📝 新增的 Redis 键

升级后,Redis 会自动创建以下新键用于请求历史:

```
request:history:{requestId}          # 单个请求的详细信息
request:list:date:{date}             # 按日期索引的请求列表
request:list:apikey:{keyId}          # 按API Key索引的请求列表
request:list:model:{model}           # 按模型索引的请求列表
request:stats:daily:{date}           # 每日统计数据
```

这些键与现有的键完全独立,互不影响。

---

## 🔄 回滚方案

如果升级后遇到问题,可以快速回滚:

### Docker Compose 回滚

```bash
# 1. 停止服务
docker compose down

# 2. 恢复 docker-compose.yml
git checkout docker-compose.yml
# 或手动改回: image: weishaw/claude-relay-service:latest

# 3. 恢复数据（如果有备份）
tar -xzf backup-20250115.tar.gz

# 4. 拉取旧镜像
docker compose pull

# 5. 启动服务
docker compose up -d
```

### 源码部署回滚

```bash
# 1. 停止服务
npm run service:stop

# 2. 恢复旧代码
cd /path/to/claude-relay-service.backup
npm run service:start:daemon

# 3. 或者切换回官方分支
git remote add official https://github.com/Wei-Shaw/claude-relay-service.git
git fetch official
git checkout official/main
```

---

## ⚙️ 配置说明

### 环境变量

升级后可以使用的新环境变量（可选）:

```bash
# 请求历史保留时间（默认30天,单位毫秒）
REQUEST_HISTORY_RETENTION=2592000000

# 是否启用请求历史（默认true）
ENABLE_REQUEST_HISTORY=true

# 历史记录自动清理间隔（默认24小时）
HISTORY_CLEANUP_INTERVAL=86400000
```

这些是可选配置,不配置也能正常使用默认值。

---

## 🐛 常见问题

### Q1: 升级后看不到历史记录?

**原因**: 历史记录只会记录升级后的新请求

**解决**: 正常现象,发送几个测试请求后就能看到历史了

### Q2: 升级后无法启动?

**可能原因**:
1. Docker 镜像未成功拉取
2. 环境变量配置有误
3. Redis 连接问题

**排查步骤**:
```bash
# 查看日志
docker compose logs -f

# 检查镜像
docker images | grep claude-relay

# 检查 Redis
docker compose exec redis redis-cli ping
```

### Q3: 升级后原有功能异常?

**解决**: 立即回滚并报告问题
```bash
docker compose down
# 恢复 docker-compose.yml
docker compose up -d
```

### Q4: 磁盘空间不足?

**原因**: 请求历史会占用一定 Redis 空间

**解决**:
1. 调整历史保留时间(环境变量)
2. 定期清理旧数据
3. 增加磁盘空间

```bash
# 在 Web 界面管理后台 → 请求历史 → 清理旧数据
# 或使用 API
curl -X POST http://localhost:3000/admin/request-history/cleanup \
  -H "Authorization: Bearer admin_token" \
  -d '{"beforeDate": "2025-01-01"}'
```

---

## 📈 性能影响

### 资源使用

升级后的资源使用变化:

| 资源 | 官方版本 | 带历史版本 | 增加 |
|------|---------|-----------|------|
| 内存 | ~200MB | ~250MB | +25% |
| 磁盘 | ~100MB | ~200MB* | +100%* |
| CPU | 低 | 低 | 无明显变化 |

*磁盘使用取决于请求量,30天历史约占用 100-500MB

### 性能优化建议

1. **调整历史保留时间**
   ```bash
   REQUEST_HISTORY_RETENTION=604800000  # 7天
   ```

2. **增加 Redis 内存限制**
   ```yaml
   redis:
     command: redis-server --maxmemory 2gb --maxmemory-policy allkeys-lru
   ```

3. **定期清理旧数据**
   - 在 Web 界面设置自动清理
   - 或使用定时任务调用清理 API

---

## 🎯 升级建议

### 推荐的升级时机

- ✅ **非高峰时段**: 晚上或周末
- ✅ **有测试环境**: 先在测试环境验证
- ✅ **有备份**: 确保数据已备份

### 升级流程

1. **准备阶段** (5分钟)
   - 通知用户将要升级
   - 备份数据
   - 准备回滚方案

2. **执行升级** (3-5分钟)
   - 更新镜像/代码
   - 重启服务
   - 初步验证

3. **验证阶段** (10分钟)
   - 完整功能测试
   - 性能监控
   - 用户反馈

4. **完成** (2分钟)
   - 通知用户升级完成
   - 更新文档
   - 监控运行状态

### 零停机升级（高级）

如果需要零停机升级:

```bash
# 1. 启动新版本（不同端口）
docker run -d --name claude-relay-new \
  -p 3001:3000 \
  -v ./data:/app/data \
  wangxiaobo775/claude-relay-service:latest

# 2. 验证新版本正常
curl http://localhost:3001/health

# 3. 使用负载均衡器切换流量（Nginx/Caddy）
# 或直接切换端口映射

# 4. 停止旧版本
docker stop claude-relay
docker rm claude-relay

# 5. 重命名新版本容器
docker rename claude-relay-new claude-relay
```

---

## 📞 获取支持

如果升级遇到问题:

1. **查看日志**: `docker compose logs -f` 或 `npm run service:logs`
2. **查看 GitHub Issues**: https://github.com/wangxiaobo775/claude-relay-service/issues
3. **对比官方文档**: 查看 QUICK_START.md 和 DOCKER_HUB_USAGE.md

---

## ✅ 快速升级检查清单

打印此清单,逐项检查:

### 升级前
- [ ] 已备份所有数据目录
- [ ] 已记录当前版本号
- [ ] 已准备回滚方案
- [ ] 已通知相关用户
- [ ] 选择合适的升级时机

### 升级中
- [ ] 已更新镜像/代码
- [ ] 服务成功重启
- [ ] 日志无明显错误

### 升级后
- [ ] 健康检查通过
- [ ] Web界面可访问
- [ ] 现有功能正常
- [ ] 新功能可用
- [ ] 性能正常
- [ ] 已清理旧镜像/代码

---

## 🎉 升级完成!

恭喜!你现在拥有了带请求历史记录功能的 Claude Relay Service!

**新功能使用指南:**
- 访问 Web 界面 → 左侧菜单 → "请求历史"
- 查看所有 API 请求记录
- 按条件筛选和搜索
- 查看详细的 token 使用统计

**相关文档:**
- [快速开始指南](./QUICK_START.md)
- [Docker Hub 使用指南](./DOCKER_HUB_USAGE.md)
- [同步上游指南](./SYNC_UPSTREAM.md)

享受你的新功能! 🚀
