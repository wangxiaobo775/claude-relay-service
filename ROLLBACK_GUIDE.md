# 🔙 升级失败回退指南

## 🛡️ 回退安全性保证

**好消息:回退是100%安全的!**

### ✅ 为什么可以安全回退?

1. **数据完全兼容**
   - 新版本只添加新的Redis键(request:*)
   - 不修改任何现有数据
   - 回退后新增的键会被忽略,不影响旧版本运行

2. **配置完全兼容**
   - .env 配置文件通用
   - 环境变量配置相同
   - 无需修改任何配置

3. **API完全兼容**
   - 所有旧的API端点保持不变
   - 只增加新端点,不删除旧端点
   - 客户端代码无需修改

### 🎯 回退策略

- **快速回退**: 2-5分钟内恢复服务
- **数据保留**: 所有原有数据完整保留
- **无副作用**: 回退不会损坏任何数据

---

## 🚨 什么情况需要回退?

### 场景1: 升级后服务无法启动

**症状:**
- 容器启动后立即退出
- 日志显示错误
- 健康检查失败

**原因可能:**
- 镜像拉取失败
- 配置错误
- 依赖问题

**立即回退!** ⬇️

### 场景2: 升级后功能异常

**症状:**
- API请求失败
- 数据显示不正常
- 性能严重下降

**立即回退!** ⬇️

### 场景3: 升级后资源不足

**症状:**
- 内存使用过高
- 磁盘空间不足
- CPU占用异常

**可以回退** ⬇️

---

## 🔄 快速回退方法

根据你的部署方式选择对应的回退方法:

---

## 方法1: Docker Compose 回退（最常见）

### 📊 适用场景
- 使用 docker-compose.yml 部署
- 已修改镜像名为 wangxiaobo775/claude-relay-service

### ⚡ 快速回退 (2分钟)

```bash
# 1. 立即停止服务
docker compose down

# 2. 修改 docker-compose.yml
# 将镜像名改回:
# image: weishaw/claude-relay-service:latest

# 3. 拉取官方镜像
docker compose pull

# 4. 启动服务
docker compose up -d

# 5. 验证
curl http://localhost:3000/health
```

### 📝 详细步骤

**步骤1: 停止当前服务**

```bash
cd /path/to/your/deployment

# 停止所有容器
docker compose down

# 确认已停止
docker compose ps
```

**步骤2: 恢复配置文件**

编辑 `docker-compose.yml`:

```yaml
services:
  claude-relay:
    # 改回官方镜像
    image: weishaw/claude-relay-service:latest  # 👈 改回这个

    # 其他配置保持不变
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - ./logs:/app/logs
      - ./data:/app/data
    environment:
      # 环境变量保持不变
      - JWT_SECRET=${JWT_SECRET}
      # ... 其他配置 ...
```

或者使用 git 恢复(如果有版本控制):

```bash
git checkout docker-compose.yml
```

**步骤3: 拉取官方镜像**

```bash
# 拉取官方镜像
docker compose pull

# 验证镜像
docker images | grep claude-relay-service
```

**步骤4: 启动服务**

```bash
# 启动服务
docker compose up -d

# 查看启动日志
docker compose logs -f claude-relay
```

**步骤5: 验证回退成功**

```bash
# 检查容器状态
docker compose ps

# 健康检查
curl http://localhost:3000/health

# 访问Web界面
curl http://localhost:3000/web

# 测试API
curl -H "Authorization: Bearer cr_your_key" \
  http://localhost:3000/api/v1/models
```

**步骤6: 恢复数据备份（如果需要）**

如果在升级过程中数据被破坏(极少发生):

```bash
# 停止服务
docker compose down

# 恢复备份
tar -xzf backup-20250115.tar.gz

# 重启服务
docker compose up -d
```

---

## 方法2: Docker 单容器回退

### 📊 适用场景
- 使用 docker run 部署
- 没有使用 docker-compose

### ⚡ 快速回退 (3分钟)

```bash
# 1. 停止新版本容器
docker stop claude-relay
docker rm claude-relay

# 2. 拉取官方镜像
docker pull weishaw/claude-relay-service:latest

# 3. 启动官方版本（使用相同参数）
docker run -d \
  --name claude-relay \
  -p 3000:3000 \
  -v ./data:/app/data \
  -v ./logs:/app/logs \
  -e JWT_SECRET=your_jwt_secret \
  -e ENCRYPTION_KEY=your_encryption_key \
  -e REDIS_HOST=redis \
  weishaw/claude-relay-service:latest  # 👈 官方镜像

# 4. 验证
curl http://localhost:3000/health
```

### 📝 详细步骤

**步骤1: 停止并删除新版本容器**

```bash
# 查看容器状态
docker ps -a | grep claude-relay

# 停止容器
docker stop claude-relay

# 删除容器（数据卷会保留）
docker rm claude-relay
```

**步骤2: 拉取官方镜像**

```bash
# 拉取官方最新版本
docker pull weishaw/claude-relay-service:latest

# 或拉取特定版本
docker pull weishaw/claude-relay-service:v1.1.174
```

**步骤3: 记录原始启动参数**

如果忘记了原始参数,可以从新版本容器查看:

```bash
# 查看容器配置（在删除前执行）
docker inspect claude-relay | grep -A 50 "Env\|Mounts\|Cmd"
```

**步骤4: 启动官方版本**

使用与升级前完全相同的参数:

```bash
docker run -d \
  --name claude-relay \
  --restart unless-stopped \
  -p 3000:3000 \
  -v /path/to/data:/app/data \
  -v /path/to/logs:/app/logs \
  -e JWT_SECRET=your_secret \
  -e ENCRYPTION_KEY=your_key \
  -e ADMIN_USERNAME=admin \
  -e ADMIN_PASSWORD=your_password \
  -e REDIS_HOST=redis \
  -e REDIS_PORT=6379 \
  --link redis:redis \
  weishaw/claude-relay-service:latest
```

**步骤5: 验证回退**

```bash
# 查看日志
docker logs -f claude-relay

# 健康检查
curl http://localhost:3000/health

# 进入容器检查
docker exec -it claude-relay sh
```

---

## 方法3: 源码部署回退

### 📊 适用场景
- 直接使用源码部署
- 使用 npm start 运行

### ⚡ 快速回退 (5分钟)

```bash
# 1. 停止服务
npm run service:stop

# 2. 切换回官方分支
git remote add official https://github.com/Wei-Shaw/claude-relay-service.git
git fetch official
git checkout official/main

# 3. 安装依赖
npm install

# 4. 重启服务
npm run service:start:daemon

# 5. 验证
curl http://localhost:3000/health
```

### 📝 详细步骤

**步骤1: 停止服务**

```bash
cd /path/to/claude-relay-service

# 停止服务
npm run service:stop

# 或直接杀进程
pkill -f "node.*claude-relay"
```

**步骤2: 备份当前代码（可选）**

```bash
# 备份当前目录
cp -r /path/to/claude-relay-service /path/to/claude-relay-service.new

# 或创建分支
git branch backup-new-version
```

**步骤3: 恢复官方代码**

**方法A: 使用备份恢复**

```bash
# 如果之前有备份
rm -rf /path/to/claude-relay-service
cp -r /path/to/claude-relay-service.backup /path/to/claude-relay-service
```

**方法B: 使用 Git 切换分支**

```bash
# 添加官方仓库（如果还没有）
git remote add official https://github.com/Wei-Shaw/claude-relay-service.git

# 拉取官方代码
git fetch official

# 查看官方分支
git branch -r | grep official

# 切换到官方 main 分支
git checkout official/main

# 或创建本地追踪分支
git checkout -b official-main official/main
```

**方法C: 重新克隆**

```bash
# 重命名当前目录
mv claude-relay-service claude-relay-service-new

# 重新克隆官方仓库
git clone https://github.com/Wei-Shaw/claude-relay-service.git

# 复制配置和数据
cp claude-relay-service-new/.env claude-relay-service/
cp -r claude-relay-service-new/data claude-relay-service/
cp -r claude-relay-service-new/logs claude-relay-service/
cp -r claude-relay-service-new/redis_data claude-relay-service/

cd claude-relay-service
```

**步骤4: 安装依赖**

```bash
# 清理旧依赖
rm -rf node_modules package-lock.json

# 重新安装
npm install

# 构建前端（如果需要）
cd web/admin-spa
npm install
npm run build
cd ../..
```

**步骤5: 重启服务**

```bash
# 使用服务管理脚本
npm run service:start:daemon

# 或直接启动
npm start

# 或使用 PM2
pm2 start src/app.js --name claude-relay
```

**步骤6: 验证**

```bash
# 查看服务状态
npm run service:status

# 查看日志
npm run service:logs

# 健康检查
curl http://localhost:3000/health
```

---

## 🔍 回退后验证清单

回退完成后,请逐一验证:

### 基础验证
- [ ] 容器/进程正常运行
- [ ] 健康检查通过: `curl http://localhost:3000/health`
- [ ] Web界面可访问: `http://localhost:3000/web`
- [ ] 可以正常登录管理后台

### 功能验证
- [ ] API Keys 列表正常显示
- [ ] Claude 账户列表正常
- [ ] 可以创建/编辑/删除 API Key
- [ ] 可以发送测试请求
- [ ] Token 统计数据正常

### 性能验证
- [ ] 内存使用正常（约200MB）
- [ ] CPU 使用正常（<10%）
- [ ] 磁盘空间正常
- [ ] 响应时间正常（<100ms）

### 数据完整性验证
```bash
# 检查 Redis 数据
docker compose exec redis redis-cli

# 查看 API Keys
> KEYS api_key:*

# 查看账户
> KEYS claude_account:*

# 退出
> exit
```

---

## 🗑️ 清理新版本数据（可选）

回退成功后,可以选择清理新版本添加的数据:

### 清理 Redis 中的请求历史数据

```bash
# 进入 Redis
docker compose exec redis redis-cli

# 删除请求历史相关键
> KEYS request:*
> DEL request:history:*
> DEL request:list:*
> DEL request:stats:*

# 或批量删除（谨慎使用）
> SCAN 0 MATCH request:* COUNT 1000
> DEL <返回的键>

# 退出
> exit
```

**注意:** 这不会影响原有功能,只是清理磁盘空间

### 清理 Docker 镜像

```bash
# 查看所有镜像
docker images | grep claude-relay-service

# 删除新版本镜像
docker rmi wangxiaobo775/claude-relay-service:latest

# 清理未使用的镜像
docker image prune -a
```

---

## 💾 数据恢复

如果在升级过程中数据被损坏(极少发生):

### 恢复 Redis 数据

```bash
# 停止服务
docker compose down

# 恢复 Redis 备份
cp redis_data/dump.rdb.backup redis_data/dump.rdb

# 重启服务
docker compose up -d
```

### 恢复应用数据

```bash
# 停止服务
docker compose down

# 恢复完整备份
tar -xzf backup-20250115.tar.gz

# 重启服务
docker compose up -d
```

---

## 🐛 常见回退问题

### Q1: 回退后无法启动?

**可能原因:**
- 端口被占用
- 配置文件错误
- Redis 未启动

**排查步骤:**
```bash
# 检查端口
netstat -tlnp | grep 3000

# 检查 Redis
docker compose ps
docker compose logs redis

# 检查配置
cat .env
```

### Q2: 回退后数据丢失?

**原因:** 可能恢复了旧备份

**解决:**
```bash
# 不要恢复备份,直接使用当前数据
# 数据是兼容的,不需要恢复

# 如果已经恢复,重新升级然后正常回退
```

### Q3: 回退后性能异常?

**原因:** 可能 Redis 中有大量新版本数据

**解决:**
```bash
# 清理请求历史数据（见上方"清理新版本数据"）
# 或重启 Redis
docker compose restart redis
```

### Q4: 回退后 Web 界面异常?

**原因:** 浏览器缓存

**解决:**
```bash
# 清除浏览器缓存
# Chrome: Ctrl+Shift+Delete
# Firefox: Ctrl+Shift+Delete

# 或使用隐私模式访问
```

---

## 📊 回退时间预估

| 部署方式 | 回退时间 | 停机时间 |
|---------|---------|---------|
| Docker Compose | 2-3分钟 | 1-2分钟 |
| Docker 单容器 | 3-5分钟 | 2-3分钟 |
| 源码部署 | 5-10分钟 | 3-5分钟 |

---

## ⚡ 紧急回退脚本

将以下脚本保存为 `emergency-rollback.sh`,紧急时一键回退:

```bash
#!/bin/bash
# 紧急回退脚本

echo "🚨 开始紧急回退..."

# 停止服务
echo "停止服务..."
docker compose down

# 备份当前状态（防止误操作）
echo "备份当前状态..."
tar -czf emergency-backup-$(date +%Y%m%d-%H%M%S).tar.gz \
  docker-compose.yml data/ logs/ 2>/dev/null || true

# 恢复官方镜像配置
echo "恢复官方镜像..."
sed -i 's|wangxiaobo775/claude-relay-service|weishaw/claude-relay-service|g' docker-compose.yml

# 拉取官方镜像
echo "拉取官方镜像..."
docker compose pull

# 启动服务
echo "启动服务..."
docker compose up -d

# 等待服务就绪
echo "等待服务就绪..."
sleep 10

# 验证
echo "验证服务..."
curl -f http://localhost:3000/health && echo "✅ 回退成功!" || echo "❌ 回退失败,请检查日志"

# 显示日志
docker compose logs --tail=50
```

使用方法:
```bash
chmod +x emergency-rollback.sh
./emergency-rollback.sh
```

---

## 📞 获取支持

如果回退遇到问题:

1. **查看日志**
   ```bash
   docker compose logs -f
   # 或
   npm run service:logs
   ```

2. **检查状态**
   ```bash
   docker compose ps
   curl http://localhost:3000/health
   ```

3. **联系支持**
   - GitHub Issues: https://github.com/wangxiaobo775/claude-relay-service/issues
   - 官方文档: https://github.com/Wei-Shaw/claude-relay-service

---

## ✅ 回退成功确认

回退成功的标志:

- ✅ 服务正常运行
- ✅ 健康检查通过
- ✅ Web界面可访问
- ✅ API请求正常
- ✅ 所有原有数据完整
- ✅ 性能恢复正常

回退后,你可以:
- 分析升级失败的原因
- 在测试环境重试
- 等待后续版本
- 或继续使用官方版本

---

## 🎯 回退后的建议

### 1. 分析失败原因
- 查看升级时的错误日志
- 检查系统资源是否充足
- 确认配置是否正确

### 2. 报告问题
如果是新版本的bug,请报告:
- GitHub Issue: https://github.com/wangxiaobo775/claude-relay-service/issues
- 包含错误日志和环境信息

### 3. 在测试环境重试
- 搭建测试环境
- 重新尝试升级
- 验证通过后再在生产环境升级

### 4. 等待修复版本
- 关注项目更新
- 等待bug修复
- 下次升级前查看 Release Notes

---

## 🛡️ 总结

**回退是100%安全的:**
- ✅ 数据完全兼容,不会损坏
- ✅ 配置通用,无需修改
- ✅ 2-5分钟内完成回退
- ✅ 可以随时重新尝试升级

**回退核心步骤:**
1. 停止服务
2. 改回官方镜像名
3. 重启服务
4. 验证正常

**记住:** 新版本只是在原有基础上增加功能,不修改任何现有数据和配置,所以回退是无风险的!

---

需要帮助? 查看:
- [升级指南](./UPGRADE_GUIDE.md)
- [快速开始](./QUICK_START.md)
- [Docker Hub 使用指南](./DOCKER_HUB_USAGE.md)
