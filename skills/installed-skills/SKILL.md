---
name: installed-skills
description: "查询和管理已安装的 OpenClaw 技能列表。记录技能版本、用途和安装状态。使用 clawhub 管理技能的安装、更新和卸载。"
---

# Installed Skills (技能管理)

记录当前系统已安装的 OpenClaw 技能及其用途。

## 已安装技能列表

| 技能 | 版本 | 用途 | 状态 |
|------|------|------|------|
| **session-logs** | 1.0.0 | 会话日志记录 | ✅ 活跃 |
| **model-usage-linux** | 1.0.0 | 模型使用统计 (Linux) | ✅ 活跃 |
| **github** | 1.0.0 | GitHub 仓库操作 | ✅ 活跃 |
| **tmux** | 1.0.0 | 终端复用器管理 | ✅ 活跃 |
| **developer** | 1.0.0 | 通用开发工具集 | ✅ 活跃 |
| **python-executor** | 0.1.5 | Python 代码执行 | ⚠️ 需 --force |
| **github-cli** | 1.0.0 | GitHub CLI 集成 | ⚠️ 需 --force |

## ClawHub 常用命令

```bash
# 查看已安装技能
clawhub list

# 搜索技能
clawhub search <关键词>

# 安装技能
clawhub install <skill-name>

# 强制安装（用于标记为可疑的技能）
clawhub install <skill-name> --force

# 更新所有技能
clawhub update

# 查看技能详情
clawhub inspect <skill-name>

# 卸载技能
clawhub uninstall <skill-name>
```

## 技能详情

### session-logs
- **用途**: 记录会话日志，便于回溯和审计
- **来源**: ClawHub 官方
- **依赖**: 无

### model-usage-linux
- **用途**: 统计模型使用情况（token 消耗等）
- **注意**: 主要为 Linux 环境设计
- **来源**: ClawHub 官方

### github
- **用途**: GitHub 仓库操作（创建 PR、Issue 等）
- **依赖**: 需要 GitHub Token
- **配置**: 在 `~/.openclaw/openclaw.json` 中配置

### tmux
- **用途**: 终端复用器管理，支持多会话
- **依赖**: 系统 tmux
- **使用场景**: 多任务并行开发

### developer
- **用途**: 通用开发工具集
- **包含**: 代码格式化、lint、测试等
- **来源**: ClawHub 官方

### python-executor
- **用途**: 执行 Python 代码片段
- **状态**: ⚠️ 标记为可疑（需 `--force` 安装）
- **安全**: 在沙箱环境中运行

### github-cli
- **用途**: GitHub CLI (`gh`) 集成
- **状态**: ⚠️ 标记为可疑（需 `--force` 安装）
- **依赖**: 需要安装 `gh` CLI 并登录

## 自定义技能

除了 ClawHub 安装的技能，还有以下自定义技能：

| 技能 | 路径 | 用途 |
|------|------|------|
| **claude-code-clawdbot-skill** | `~/.clawdbot/skills/` | Claude Code CLI 集成 |
| **cma-weather-skill** | `~/.clawdbot/skills/` | 中国气象局天气查询 |
| **web-search-skill** | `~/.clawdbot/skills/` | 网页搜索 (DuckDuckGo) |

## 技能备份

所有技能配置已备份到 GitHub 仓库：
- **仓库**: https://github.com/voilet/openclaw-config
- **同步时间**: 每天 17:00
- **同步脚本**: `~/Projects/openclaw-backup/scripts/sync-skills.sh`

## 恢复技能

从备份恢复所有技能：

```bash
# 克隆备份仓库
git clone https://github.com/voilet/openclaw-config.git
cd openclaw-config

# 复制自定义技能
cp -r skills/* ~/.clawdbot/skills/

# 创建符号链接
for skill in ~/.clawdbot/skills/*/; do
    skill_name=$(basename "$skill")
    ln -sf "$skill" ~/.openclaw/skills/
done

# 重新安装 ClawHub 技能
clawhub install session-logs github tmux developer
clawhub install python-executor github-cli --force
```

## 安装历史

### 2026-03-05
- 安装 `openai-whisper` (pipx)
- 安装 `Obsidian` (Homebrew)
- 安装 `mcporter` (npm)
- 安装 `clawhub` (npm)
- 通过 ClawHub 安装 7 个技能

---

*最后更新: 2026-03-05*
