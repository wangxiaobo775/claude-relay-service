# 🏗️ 构建和发布 Docker 镜像指南

本指南说明如何构建 Docker 镜像并发布到 Docker Hub，让用户可以直接拉取使用。

## 📋 准备工作

### 1. Docker Hub 账户

确保你有 Docker Hub 账户并已登录:

```bash
# 登录 Docker Hub
docker login

# 输入用户名: wangxiaobo775
# 输入密码: [你的Docker Hub密码]
```

### 2. 确认构建环境

```bash
# 检查 Docker 版本
docker --version

# 检查 Docker Compose 版本
docker compose version

# 确保 Docker 正在运行
docker info
```

## 🔨 构建镜像

### 方式1: 使用自动化脚本（推荐）

Windows 用户:

```bash
# 运行构建脚本（会自动构建和推送）
build-and-push.bat

# 或指定版本号
build-and-push.bat v1.1.173
```

脚本会自动执行:
1. ✅ 检查 Docker 环境
2. ✅ 确认登录状态
3. ✅ 构建镜像
4. ✅ 打标签 (latest + 版本号)
5. ✅ 推送到 Docker Hub

### 方式2: 手动构建

```bash
# 1. 构建镜像
docker compose build

# 2. 查看镜像
docker images | grep claude-relay-service

# 3. 推送到 Docker Hub
docker compose push

# 或者手动推送
docker push wangxiaobo775/claude-relay-service:latest
```

## 🏷️ 版本管理

### 创建带版本号的发布

```bash
# 1. 设置版本号
VERSION="v1.1.173"

# 2. 构建并打标签
docker build -t wangxiaobo775/claude-relay-service:${VERSION} .
docker build -t wangxiaobo775/claude-relay-service:latest .

# 3. 推送两个标签
docker push wangxiaobo775/claude-relay-service:${VERSION}
docker push wangxiaobo775/claude-relay-service:latest
```

### 标签策略

- `latest` - 最新稳定版本
- `v1.1.173` - 特定版本号（基于上游版本）
- `v1.1.173-history` - 带请求历史功能的版本（可选）

## 📤 发布流程

### 完整发布检查清单

- [ ] 代码已提交到 GitHub
- [ ] 测试通过（本地运行无误）
- [ ] 版本号已更新
- [ ] Docker 镜像已构建
- [ ] 镜像已推送到 Docker Hub
- [ ] README 和文档已更新
- [ ] 发布说明已准备

### 发布步骤

```bash
# 1. 提交代码到 GitHub
git add .
git commit -m "release: v1.1.173 with request history"
git push origin main

# 2. 创建 Git 标签
git tag -a v1.1.173 -m "Release v1.1.173 - 集成请求历史功能"
git push origin v1.1.173

# 3. 构建并推送 Docker 镜像
build-and-push.bat v1.1.173

# 4. 验证镜像可用性
docker pull wangxiaobo775/claude-relay-service:latest
docker pull wangxiaobo775/claude-relay-service:v1.1.173

# 5. 在 GitHub 上创建 Release
# 访问: https://github.com/wangxiaobo775/claude-relay-service/releases/new
```

## 🧪 测试发布

在发布前测试镜像:

```bash
# 1. 清理本地镜像（模拟用户首次拉取）
docker rmi wangxiaobo775/claude-relay-service:latest

# 2. 拉取镜像
docker pull wangxiaobo775/claude-relay-service:latest

# 3. 测试启动
docker compose -f docker-compose-user.yml up -d

# 4. 检查健康状态
curl http://localhost:3000/health

# 5. 检查 Web 界面
open http://localhost:3000/web

# 6. 测试请求历史功能
# (发送测试请求并查看历史记录)

# 7. 清理测试环境
docker compose -f docker-compose-user.yml down
```

## 📊 镜像信息

### 查看镜像详情

```bash
# 查看本地镜像
docker images wangxiaobo775/claude-relay-service

# 查看镜像大小
docker image inspect wangxiaobo775/claude-relay-service:latest --format='{{.Size}}'

# 查看镜像层
docker history wangxiaobo775/claude-relay-service:latest

# 查看镜像元数据
docker image inspect wangxiaobo775/claude-relay-service:latest
```

### Docker Hub 统计

访问 https://hub.docker.com/r/wangxiaobo775/claude-relay-service 查看:
- 拉取次数
- 镜像大小
- 所有标签
- 构建历史

## 🔄 更新镜像

### 从上游同步更新

```bash
# 1. 拉取上游最新代码
git fetch upstream
git merge upstream/main

# 2. 解决冲突（如有）
# ...

# 3. 重新构建镜像
build-and-push.bat

# 4. 测试新镜像
docker compose -f docker-compose-user.yml pull
docker compose -f docker-compose-user.yml up -d
```

### 回滚到旧版本

```bash
# 如果新版本有问题，可以推送旧版本为 latest
docker pull wangxiaobo775/claude-relay-service:v1.1.172
docker tag wangxiaobo775/claude-relay-service:v1.1.172 wangxiaobo775/claude-relay-service:latest
docker push wangxiaobo775/claude-relay-service:latest
```

## 📝 发布说明模板

在 GitHub Release 中使用:

```markdown
## 🎉 版本 v1.1.173 - 集成请求历史记录功能

### ✨ 新增功能

- ✅ 完整的请求历史记录系统
- ✅ 详细的 Token 使用统计
- ✅ 高级筛选和搜索功能
- ✅ Web 管理界面支持
- ✅ 数据安全隔离

### 📦 Docker 镜像

```bash
docker pull wangxiaobo775/claude-relay-service:latest
docker pull wangxiaobo775/claude-relay-service:v1.1.173
```

### 🚀 快速开始

```bash
curl -O https://raw.githubusercontent.com/wangxiaobo775/claude-relay-service/main/docker-compose-user.yml
docker compose -f docker-compose-user.yml up -d
```

### 📖 文档

- [Docker Hub 使用指南](./DOCKER_HUB_USAGE.md)
- [完整部署指南](./DOCKER_DEPLOY_GUIDE.md)

### 🔗 相关链接

- Docker Hub: https://hub.docker.com/r/wangxiaobo775/claude-relay-service
- 原始 PR: https://github.com/Wei-Shaw/claude-relay-service/pull/21

### ⚠️ 重要提示

首次部署需要配置 `.env` 文件，详见文档。
```

## 🛠️ 故障排查

### 构建失败

```bash
# 清理 Docker 缓存
docker system prune -a

# 重新构建（不使用缓存）
docker build --no-cache -t wangxiaobo775/claude-relay-service:latest .
```

### 推送失败

```bash
# 检查登录状态
docker login

# 检查镜像名称
docker images | grep claude-relay-service

# 重新打标签
docker tag local-image-id wangxiaobo775/claude-relay-service:latest

# 重新推送
docker push wangxiaobo775/claude-relay-service:latest
```

### 镜像过大

```bash
# 查看镜像大小
docker images wangxiaobo775/claude-relay-service

# 优化 Dockerfile（如需要）
# - 使用 .dockerignore 排除不必要文件
# - 合并 RUN 命令
# - 使用多阶段构建
```

## 📚 相关文件

本次发布涉及的关键文件:

- `Dockerfile` - 镜像构建配置
- `docker-compose.yml` - 开发环境配置
- `docker-compose-user.yml` - 用户部署配置
- `build-and-push.bat` - 自动化构建脚本
- `DOCKER_HUB_USAGE.md` - 用户使用文档
- `README_DOCKER.md` - Docker 快速开始

## ✅ 完成检查

发布完成后确认:

- [ ] Docker Hub 上可以看到新镜像
- [ ] 拉取镜像可以正常启动
- [ ] Web 界面可以访问
- [ ] API 端点正常工作
- [ ] 请求历史功能正常
- [ ] 文档已更新
- [ ] GitHub Release 已创建

---

**恭喜! 你的镜像已成功发布到 Docker Hub! 🎉**

用户现在可以通过 `docker pull wangxiaobo775/claude-relay-service:latest` 使用你的服务了。
