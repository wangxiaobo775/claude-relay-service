# ⚡ 快速开始指南

## 🚀 用户 - 3步快速部署

如果你是最终用户,想要快速部署这个服务:

```bash
# 1. 拉取镜像（3秒）
docker pull wangxiaobo775/claude-relay-service:latest

# 2. 创建配置文件（复制下面内容到 .env）
cat > .env << 'EOF'
JWT_SECRET=请运行下方命令生成
ENCRYPTION_KEY=请运行下方命令生成
ADMIN_USERNAME=admin
ADMIN_PASSWORD=请修改为你的密码
EOF

# 生成密钥
node -e "console.log('JWT_SECRET=' + require('crypto').randomBytes(32).toString('hex'))"
node -e "console.log('ENCRYPTION_KEY=' + require('crypto').randomBytes(16).toString('hex'))"

# 3. 下载配置并启动
curl -O https://raw.githubusercontent.com/wangxiaobo775/claude-relay-service/main/docker-compose-user.yml
docker compose -f docker-compose-user.yml up -d
```

**访问服务**: http://localhost:3000/web

**详细文档**: [DOCKER_HUB_USAGE.md](./DOCKER_HUB_USAGE.md)

---

## 🛠️ 开发者 - GitHub Actions 配置检查清单

如果你是开发者,fork了这个项目:

### ✅ 必须完成的配置

- [ ] **1. 获取 Docker Hub Token**
  - 访问: https://hub.docker.com/settings/security
  - 创建 Access Token（权限: Read, Write, Delete）
  - 复制 Token

- [ ] **2. 配置 GitHub Secrets**
  - 访问: `https://github.com/你的用户名/claude-relay-service/settings/secrets/actions`
  - 添加 `DOCKERHUB_USERNAME` = 你的Docker Hub用户名
  - 添加 `DOCKERHUB_TOKEN` = 你的Token

- [ ] **3. 触发首次构建**
  - 推送任何代码变更
  - 或在 Actions 页面手动触发

- [ ] **4. 验证发布**
  - 检查 Actions 构建状态
  - 在 Docker Hub 查看镜像
  - 测试拉取镜像

### 📖 详细配置指南

- **GitHub Actions配置**: [.github/GITHUB_ACTIONS_SETUP.md](./.github/GITHUB_ACTIONS_SETUP.md)
- **手动构建方式**: [BUILD_AND_PUBLISH.md](./BUILD_AND_PUBLISH.md)
- **完整设置总结**: [SETUP_SUMMARY.md](./SETUP_SUMMARY.md)

---

## 🆕 新功能亮点

本版本在原项目基础上增加了**请求历史记录功能**:

### 用户端 API
```bash
# 查询请求历史
GET /api/v1/request-history?date=2025-01-15&limit=50
Authorization: Bearer <your-api-key>

# 查看请求详情
GET /api/v1/request-history/:requestId

# 获取统计数据
GET /api/v1/request-stats?date=2025-01-15
```

### 管理端界面
- 📊 实时查看所有 API 请求历史
- 🔍 按日期、模型、API Key 筛选
- 📈 详细的 Token 使用统计和图表
- 💰 精确的成本计算
- 🗑️ 自动清理旧数据

---

## 🔗 快速链接

### 用户文档
- [Docker Hub 使用指南](./DOCKER_HUB_USAGE.md)
- [Docker 快速开始](./README_DOCKER.md)
- [完整部署指南](./DOCKER_DEPLOY_GUIDE.md)

### 开发者文档
- [GitHub Actions 配置](./GITHUB_ACTIONS_SETUP.md)
- [构建发布指南](./BUILD_AND_PUBLISH.md)
- [设置总结](./SETUP_SUMMARY.md)

### 项目信息
- **Docker Hub**: https://hub.docker.com/r/wangxiaobo775/claude-relay-service
- **GitHub**: https://github.com/wangxiaobo775/claude-relay-service
- **原项目**: https://github.com/Wei-Shaw/claude-relay-service
- **请求历史功能PR**: https://github.com/Wei-Shaw/claude-relay-service/pull/21

---

## ❓ 常见问题

### Q: GitHub Actions 构建失败?
检查是否配置了 Docker Hub Secrets,详见 [GITHUB_ACTIONS_SETUP.md](./.github/GITHUB_ACTIONS_SETUP.md)

### Q: 如何手动构建镜像?
运行 `build-and-push.bat` (Windows) 或查看 [BUILD_AND_PUBLISH.md](./BUILD_AND_PUBLISH.md)

### Q: 如何更新到最新版本?
```bash
docker pull wangxiaobo775/claude-relay-service:latest
docker compose -f docker-compose-user.yml up -d
```

### Q: 请求历史记录功能如何使用?
登录 Web 管理界面 → 左侧菜单 → "请求历史"

---

**准备好了吗? 立即开始使用!** 🚀
