# GitHub Actions 自动构建 Docker 镜像配置指南

本指南说明如何配置 GitHub Actions 自动构建并推送 Docker 镜像到 Docker Hub 和 GitHub Container Registry。

## 🎯 工作原理

**与原项目类似**,我们使用 GitHub Actions 在每次推送代码到 `main` 分支时自动:

1. ✅ 构建 Docker 镜像（支持 amd64 和 arm64 架构）
2. ✅ 推送到 Docker Hub 和 GHCR
3. ✅ 自动打标签（latest, 版本号等）
4. ✅ 更新 Docker Hub 描述
5. ✅ 生成构建报告

## 🔐 第一步：配置 Docker Hub Secrets

### 1. 获取 Docker Hub Access Token

1. 登录 [Docker Hub](https://hub.docker.com/)
2. 点击右上角头像 → **Account Settings**
3. 选择 **Security** → **Access Tokens**
4. 点击 **New Access Token**
   - Token描述: `GitHub Actions - claude-relay-service`
   - 权限: 选择 **Read, Write, Delete**
5. 点击 **Generate**
6. **立即复制 token**（只会显示一次！）

### 2. 在 GitHub 仓库添加 Secrets

1. 进入你的 GitHub 仓库: https://github.com/wangxiaobo775/claude-relay-service
2. 点击 **Settings** 标签
3. 左侧菜单选择 **Secrets and variables** → **Actions**
4. 点击 **New repository secret**
5. 添加以下两个 secrets:

**Secret 1:**
- Name: `DOCKERHUB_USERNAME`
- Value: `wangxiaobo775`

**Secret 2:**
- Name: `DOCKERHUB_TOKEN`
- Value: `你刚才复制的 Docker Hub Access Token`

## 🚀 第二步：推送代码触发构建

配置完成后,只需推送代码即可自动构建:

```bash
# 提交并推送代码
git add .github/workflows/docker-build-push.yml
git commit -m "ci: 添加Docker自动构建工作流"
git push origin main
```

## 📊 第三步：查看构建状态

1. 进入 GitHub 仓库的 **Actions** 标签
2. 查看 **Build and Push Docker Image** 工作流
3. 等待构建完成（通常需要 5-10 分钟）
4. 成功后访问 Docker Hub 查看镜像

## 🐳 发布的镜像地址

构建成功后,镜像会发布到两个地方:

### Docker Hub（推荐）
```bash
docker pull wangxiaobo775/claude-relay-service:latest
```

### GitHub Container Registry
```bash
docker pull ghcr.io/wangxiaobo775/claude-relay-service:latest
```

## 🏷️ 标签策略

GitHub Actions 会自动创建以下标签:

| 标签 | 说明 | 示例 |
|------|------|------|
| `latest` | 最新的 main 分支构建 | `wangxiaobo775/claude-relay-service:latest` |
| `main` | main 分支构建 | `wangxiaobo775/claude-relay-service:main` |
| `v1.1.173` | 版本标签（创建 tag 时） | `wangxiaobo775/claude-relay-service:v1.1.173` |
| `1.1` | 主次版本 | `wangxiaobo775/claude-relay-service:1.1` |
| `main-sha-abc123` | 带 commit SHA | `wangxiaobo775/claude-relay-service:main-sha-abc123` |

## 🔄 触发构建的方式

### 1. 自动触发（推送到 main）
```bash
git push origin main
```

### 2. 创建版本标签
```bash
# 创建版本标签
git tag -a v1.1.173 -m "Release v1.1.173 - 集成请求历史功能"
git push origin v1.1.173

# 这会构建并推送:
# - wangxiaobo775/claude-relay-service:v1.1.173
# - wangxiaobo775/claude-relay-service:1.1
# - wangxiaobo775/claude-relay-service:1
# - wangxiaobo775/claude-relay-service:latest
```

### 3. 手动触发
1. 进入 GitHub Actions 页面
2. 选择 **Build and Push Docker Image** 工作流
3. 点击 **Run workflow**
4. 选择分支并运行

### 4. 跳过构建
在 commit 消息中添加 `[skip ci]`:
```bash
git commit -m "docs: 更新文档 [skip ci]"
```

## 🎨 多平台支持

工作流支持两种架构:
- **linux/amd64** - Intel/AMD x86_64（大多数服务器和PC）
- **linux/arm64** - ARM64（Apple Silicon、树莓派等）

用户拉取镜像时会自动选择匹配的架构。

## 📝 工作流文件说明

工作流文件: `.github/workflows/docker-build-push.yml`

主要步骤:
1. **Checkout code** - 检出代码
2. **Set up QEMU** - 配置多架构模拟
3. **Set up Docker Buildx** - 配置 Docker 构建工具
4. **Log in to Docker Hub** - 登录 Docker Hub
5. **Log in to GHCR** - 登录 GitHub Container Registry
6. **Prepare metadata** - 准备镜像元数据和标签
7. **Build and push** - 构建并推送多架构镜像
8. **Update Docker Hub description** - 更新 Docker Hub 描述（仅 main 分支）

## 🔍 验证发布

### 检查 Docker Hub
访问: https://hub.docker.com/r/wangxiaobo775/claude-relay-service

应该能看到:
- ✅ 镜像标签列表
- ✅ 镜像大小
- ✅ 最后更新时间
- ✅ README 描述

### 检查 GHCR
访问: https://github.com/wangxiaobo775/claude-relay-service/pkgs/container/claude-relay-service

### 测试拉取镜像
```bash
# 清理本地镜像（可选）
docker rmi wangxiaobo775/claude-relay-service:latest

# 拉取镜像
docker pull wangxiaobo775/claude-relay-service:latest

# 查看镜像信息
docker images wangxiaobo775/claude-relay-service

# 运行测试
docker run --rm wangxiaobo775/claude-relay-service:latest node --version
```

## 🛠️ 高级配置

### 自定义镜像仓库

如果要修改镜像名称,编辑 `.github/workflows/docker-build-push.yml`:

```yaml
- name: Prepare Docker metadata
  id: meta
  uses: docker/metadata-action@v5
  with:
    images: |
      your-username/your-image-name
      ghcr.io/${{ github.repository }}
```

### 添加构建参数

```yaml
- name: Build and push Docker image
  uses: docker/build-push-action@v6
  with:
    build-args: |
      MY_ARG=my_value
      ANOTHER_ARG=another_value
```

### 禁用某个平台

如果只需要 amd64 平台（构建更快）:

```yaml
platforms: linux/amd64
```

## 🐛 故障排查

### 构建失败: "unauthorized"
- 检查 DOCKERHUB_TOKEN 是否正确
- 确认 Token 有 Write 权限
- Token 可能过期,重新生成

### 推送失败: "denied"
- 确认 DOCKERHUB_USERNAME 正确（`wangxiaobo775`）
- 检查 Docker Hub 仓库权限

### 多平台构建超时
- 正常情况,多平台构建需要较长时间
- 可以先只构建 amd64 测试

### Docker Hub 描述未更新
- 需要额外的 `password` secret（不是 token）
- 或者手动在 Docker Hub 上编辑 README

## 📚 与原项目的对比

| 功能 | 原项目 | 你的 Fork |
|------|--------|-----------|
| 自动版本管理 | ✅ 自动递增版本号 | 🔧 可选启用 |
| Docker Hub 发布 | ✅ | ✅ |
| GHCR 发布 | ✅ | ✅ |
| 多架构支持 | ✅ amd64/arm64 | ✅ amd64/arm64 |
| 自动 Changelog | ✅ git-cliff | 🔧 可选启用 |
| Telegram 通知 | ✅ | 🔧 可选启用 |
| **请求历史功能** | ❌ | ✅ **集成** |

## 🎯 推荐工作流

### 日常开发
```bash
# 1. 开发功能
git checkout -b feature/my-feature
# ... 开发 ...
git commit -m "feat: 添加新功能"

# 2. 合并到 main（触发自动构建）
git checkout main
git merge feature/my-feature
git push origin main

# 3. 等待 GitHub Actions 完成构建

# 4. 验证镜像
docker pull wangxiaobo775/claude-relay-service:latest
```

### 发布版本
```bash
# 1. 更新版本号（可选）
echo "1.1.173" > VERSION

# 2. 提交并创建标签
git add VERSION
git commit -m "chore: bump version to 1.1.173"
git tag -a v1.1.173 -m "Release v1.1.173"

# 3. 推送
git push origin main v1.1.173

# 4. GitHub Actions 会自动构建所有标签
```

## ✅ 完成检查清单

配置完成后,确认:

- [ ] Docker Hub Secrets 已添加（DOCKERHUB_USERNAME, DOCKERHUB_TOKEN）
- [ ] 工作流文件已提交到仓库
- [ ] 推送代码触发了构建
- [ ] GitHub Actions 显示构建成功
- [ ] Docker Hub 上可以看到镜像
- [ ] 可以成功拉取镜像: `docker pull wangxiaobo775/claude-relay-service:latest`
- [ ] 镜像可以正常运行

## 🎉 完成！

配置完成后,每次推送到 main 分支,GitHub Actions 就会自动:
1. 构建 Docker 镜像
2. 推送到 Docker Hub 和 GHCR
3. 支持 amd64 和 arm64 架构
4. 自动打上各种标签

用户可以像使用原版一样,直接 `docker pull` 你的镜像! 🚀

---

**参考文档:**
- [原项目自动发布指南](./AUTO_RELEASE_GUIDE.md)
- [Docker Hub 设置指南](./DOCKER_HUB_SETUP.md)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
