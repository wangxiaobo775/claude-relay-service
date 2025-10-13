# 🔄 同步上游主线更新指南

## 📊 当前状态

### ✅ 你的版本已经是最新的!

**当前情况:**
- ✅ 你的 fork 已经包含了官方主线 `Wei-Shaw/claude-relay-service` 的所有最新代码
- ✅ 基于官方版本 v1.1.174
- ✅ 已合并 PR #21 的请求历史记录功能
- ✅ 已添加 GitHub Actions 自动构建配置

**提交历史:**
```
你的版本 (wangxiaobo775/claude-relay-service):
  c87220dd - chore: 更新docker-compose镜像名称
  bab11d7d - docs: 添加快速开始指南
  96172588 - chore: sync VERSION file with release v1.1.174
  9efaac51 - ci: 添加GitHub Actions自动构建工作流
  529bf511 - feat: 合并PR #21 - 实现请求历史记录
  268f0415 - chore: sync VERSION file with release v1.1.173
  ↓
官方版本 (Wei-Shaw/claude-relay-service):
  268f0415 - chore: sync VERSION file with release v1.1.173
  222b2862 - Merge pull request #560
  8ddb9052 - Merge pull request #557
```

## 🚀 未来如何同步上游更新

当官方主线有新功能时,按照以下步骤同步:

### 方法1: 使用命令行（推荐）

```bash
# 1. 确保在 main 分支
git checkout main

# 2. 拉取上游最新变更
git fetch upstream

# 3. 查看有哪些新提交（可选）
git log --oneline main..upstream/main

# 4. 合并上游变更
git merge upstream/main

# 5. 如果有冲突,解决后提交
# (如果没有冲突,会自动合并)

# 6. 推送到你的 fork
git push origin main
```

### 方法2: 一键脚本

我为你创建了一个自动化脚本:

```bash
# Windows
sync-upstream.bat

# Linux/Mac
./sync-upstream.sh
```

### 方法3: 使用 GitHub Web 界面

1. 访问你的 fork: https://github.com/wangxiaobo775/claude-relay-service
2. 如果有新的上游更新,会显示 "This branch is X commits behind Wei-Shaw:main"
3. 点击 **Sync fork** 按钮
4. 点击 **Update branch**

## 🔧 处理合并冲突

如果合并时遇到冲突:

### 1. 查看冲突文件
```bash
git status
# 显示有冲突的文件
```

### 2. 手动解决冲突

编辑冲突文件,查找并解决冲突标记:
```
<<<<<<< HEAD
你的更改
=======
上游的更改
>>>>>>> upstream/main
```

**保留策略:**
- 如果是你的新功能(如请求历史记录),保留你的代码
- 如果是上游的 bug 修复,保留上游代码
- 如果两者都重要,合并两者

### 3. 标记冲突已解决
```bash
git add <冲突文件>
```

### 4. 完成合并
```bash
git commit -m "merge: 合并上游最新变更并解决冲突"
git push origin main
```

## 📝 常见冲突场景

### 场景1: docker-compose.yml 冲突

**原因:** 你改了镜像名称为 `wangxiaobo775/claude-relay-service`

**解决:** 保留你的镜像名称
```yaml
image: wangxiaobo775/claude-relay-service:latest  # 保留你的
```

### 场景2: .github/workflows 冲突

**原因:** 你添加了自己的 GitHub Actions 工作流

**解决:** 保留你的工作流文件,或者合并两者的特性

### 场景3: README.md 冲突

**原因:** 双方都修改了 README

**解决:** 合并双方的更新,添加你的特色功能说明

### 场景4: 请求历史功能相关文件冲突

**原因:** 你独有的功能,上游没有

**解决:** 保留你的所有请求历史相关代码

## 🎯 同步时的最佳实践

### 1. 定期同步（推荐每周一次）

```bash
# 设置定时提醒
# 每周一早上检查上游更新
git fetch upstream && git log --oneline main..upstream/main
```

### 2. 同步前备份

```bash
# 创建备份分支
git checkout -b backup-before-sync
git checkout main
```

### 3. 先测试后推送

```bash
# 合并后先在本地测试
git merge upstream/main
npm install
npm test
npm start

# 测试通过后再推送
git push origin main
```

### 4. 使用专门的合并分支

```bash
# 创建合并分支
git checkout -b merge-upstream
git merge upstream/main

# 解决冲突并测试
# ...

# 测试通过后合并到 main
git checkout main
git merge merge-upstream
git push origin main
```

## 📚 Git 远程仓库配置

### 查看当前配置
```bash
git remote -v
```

应该看到:
```
origin    https://github.com/wangxiaobo775/claude-relay-service.git (fetch)
origin    https://github.com/wangxiaobo775/claude-relay-service.git (push)
upstream  https://github.com/Wei-Shaw/claude-relay-service.git (fetch)
upstream  https://github.com/Wei-Shaw/claude-relay-service.git (push)
```

### 如果缺少 upstream 配置

```bash
git remote add upstream https://github.com/Wei-Shaw/claude-relay-service.git
```

## 🔍 检查是否需要同步

### 快速检查命令
```bash
# 检查上游是否有新提交
git fetch upstream
git log --oneline main..upstream/main
```

**输出为空** = 无需同步,已是最新

**有输出** = 有新提交,可以同步

### 查看具体变更
```bash
# 查看文件变更列表
git diff main..upstream/main --name-only

# 查看具体代码变更
git diff main..upstream/main
```

## ⚠️ 注意事项

### 1. 保护你的特色功能

以下文件/功能是你独有的,合并时注意保留:

- ✅ `.github/workflows/docker-build-push.yml` - 你的 GitHub Actions
- ✅ `docker-compose-user.yml` - 用户部署配置
- ✅ `src/services/requestHistoryService.js` - 请求历史服务
- ✅ 所有 `DOCKER_*.md` 文档
- ✅ `build-and-push.bat` 构建脚本
- ✅ 请求历史相关的 API 端点和 Web 界面

### 2. Docker 镜像名称

保持你的镜像名称:
```yaml
image: wangxiaobo775/claude-relay-service:latest
```

不要改回官方的:
```yaml
image: weishaw/claude-relay-service:latest  # ❌ 不要用这个
```

### 3. GitHub Actions 配置

你的 Secrets 配置是独立的:
- `DOCKERHUB_USERNAME` = `wangxiaobo775`
- `DOCKERHUB_TOKEN` = 你的 Token

不会与上游冲突。

## 📊 版本跟踪

### 当前版本信息
```bash
# 查看当前版本
cat VERSION

# 查看最新 tag
git describe --tags --abbrev=0
```

### 版本命名建议

为了区分你的版本和官方版本,可以添加后缀:

```bash
# 官方版本
v1.1.174

# 你的版本（可选）
v1.1.174-history    # 标注带有历史功能
v1.1.174-fork       # 标注为fork版本
```

## 🎉 自动化同步（高级）

### 使用 GitHub Actions 自动同步

创建 `.github/workflows/sync-upstream.yml`:

```yaml
name: Sync Upstream

on:
  schedule:
    - cron: '0 0 * * 0'  # 每周日午夜运行
  workflow_dispatch:      # 允许手动触发

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Sync with upstream
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"

          git remote add upstream https://github.com/Wei-Shaw/claude-relay-service.git
          git fetch upstream

          git merge upstream/main --no-edit || echo "Merge conflicts detected"

          git push origin main
```

## 📞 获取帮助

如果同步遇到问题:

1. **查看冲突文件**: `git status`
2. **查看冲突内容**: `git diff`
3. **取消合并**: `git merge --abort`
4. **查看提交历史**: `git log --oneline --graph -20`

---

## ✅ 快速检查清单

每次同步前检查:

- [ ] 本地代码已提交: `git status` 应该是 clean
- [ ] 在 main 分支: `git branch` 显示 `* main`
- [ ] 远程配置正确: `git remote -v` 显示 origin 和 upstream
- [ ] 已备份重要更改（可选）

每次同步后验证:

- [ ] 代码可以正常构建: `npm install`
- [ ] 测试通过: `npm test`
- [ ] 服务可以启动: `npm start`
- [ ] Docker 镜像可以构建: `docker compose build`
- [ ] GitHub Actions 构建成功

---

**祝同步顺利! 🚀**

如有问题,查看官方仓库的 Issues 或提交新的 Issue。
