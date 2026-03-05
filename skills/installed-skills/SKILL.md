---
name: installed-skills
description: "查询和管理已安装的 OpenClaw 技能列表。记录技能版本、用途和安装状态。使用 clawhub 管理技能的安装、更新和卸载。"
---

# Installed Skills (技能管理)

记录当前系统已安装的 OpenClaw 技能及其用途。

## 已安装技能列表（14 个）

### 基础技能

| 技能 | 版本 | 用途 | 状态 |
|------|------|------|------|
| **session-logs** | 1.0.0 | 会话日志记录 | ✅ 活跃 |
| **model-usage-linux** | 1.0.0 | 模型使用统计 | ✅ 活跃 |

### 开发者技能

| 技能 | 版本 | 用途 | 状态 |
|------|------|------|------|
| **github** | 1.0.0 | GitHub 仓库操作 | ✅ 活跃 |
| **tmux** | 1.0.0 | 终端复用器管理 | ✅ 活跃 |
| **developer** | 1.0.0 | 通用开发工具集 | ✅ 活跃 |
| **python-executor** | 0.1.5 | Python 代码执行 | ⚠️ 需 --force |
| **github-cli** | 1.0.0 | GitHub CLI 集成 | ⚠️ 需 --force |

### 量化交易技能

| 技能 | 版本 | 用途 | 状态 |
|------|------|------|------|
| **trading** | 1.0.1 | 通用交易工具 | ✅ 活跃 |
| **stock-analysis-lianghua** | 1.0.0 | 量化分析 | ⚠️ 需 --force |
| **stock-strategy-backtester** | 1.0.4 | 策略回测 | ⚠️ 需 --force |
| **crypto-market-data** | 1.0.2 | 加密市场数据 | ⚠️ 需 --force |
| **crypto-stock-market-data** | 1.0.3 | 加密+股票市场数据 | ⚠️ 需 --force |
| **deepseek-v3-lite-agent** | 0.1.0 | DeepSeek V3 轻量代理 | ⚠️ 需 --force |
| **deepseek-api** | 1.0.0 | DeepSeek API 集成 | ✅ 活跃 |

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

### 基础技能

#### session-logs
- **用途**: 记录会话日志，便于回溯和审计
- **来源**: ClawHub 官方
- **依赖**: 无

#### model-usage-linux
- **用途**: 统计模型使用情况（token 消耗等）
- **注意**: 主要为 Linux 环境设计
- **来源**: ClawHub 官方

### 开发者技能

#### github
- **用途**: GitHub 仓库操作（创建 PR、Issue 等）
- **依赖**: 需要 GitHub Token
- **配置**: 在 `~/.openclaw/openclaw.json` 中配置

#### tmux
- **用途**: 终端复用器管理，支持多会话
- **依赖**: 系统 tmux
- **使用场景**: 多任务并行开发

#### developer
- **用途**: 通用开发工具集
- **包含**: 代码格式化、lint、测试等
- **来源**: ClawHub 官方

#### python-executor
- **用途**: 执行 Python 代码片段
- **状态**: ⚠️ 标记为可疑（需 `--force` 安装）
- **安全**: 在沙箱环境中运行

#### github-cli
- **用途**: GitHub CLI (`gh`) 集成
- **状态**: ⚠️ 标记为可疑（需 `--force` 安装）
- **依赖**: 需要安装 `gh` CLI 并登录

### 量化交易技能

#### trading
- **用途**: 通用交易工具基础
- **版本**: 1.0.1
- **来源**: ClawHub

#### stock-analysis-lianghua
- **用途**: 量化分析，股票数据分析
- **状态**: ⚠️ 标记为可疑（需 `--force` 安装）
- **功能**: 技术指标计算、趋势分析

#### stock-strategy-backtester
- **用途**: 策略回测工具
- **状态**: ⚠️ 标记为可疑（需 `--force` 安装）
- **功能**: 历史数据回测、策略验证

#### crypto-market-data
- **用途**: 加密货币市场数据获取
- **状态**: ⚠️ 标记为可疑（需 `--force` 安装）
- **功能**: 实时行情、历史数据

#### crypto-stock-market-data
- **用途**: 加密货币 + 股票综合市场数据
- **状态**: ⚠️ 标记为可疑（需 `--force` 安装）
- **功能**: 多市场数据聚合

#### deepseek-v3-lite-agent
- **用途**: DeepSeek V3 轻量代理
- **状态**: ⚠️ 标记为可疑（需 `--force` 安装）
- **功能**: 调用 DeepSeek V3 模型

#### deepseek-api
- **用途**: DeepSeek API 直接集成
- **功能**: 调用 DeepSeek 模型进行推理

## 自定义技能

除了 ClawHub 安装的技能，还有以下自定义技能：

| 技能 | 路径 | 用途 |
|------|------|------|
| **claude-code-clawdbot-skill** | `~/.clawdbot/skills/` | Claude Code CLI 集成（多任务用 tmux） |
| **cma-weather-skill** | `~/.clawdbot/skills/` | 中国气象局天气查询 |
| **web-search-skill** | `~/.clawdbot/skills/` | 网页搜索 (DuckDuckGo) |
| **installed-skills** | `~/.clawdbot/skills/` | 技能管理（本文档） |

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

# 重新安装 ClawHub 基础技能
clawhub install session-logs model-usage-linux github tmux developer
clawhub install python-executor github-cli --force

# 重新安装量化交易技能
clawhub install trading deepseek-api
clawhub install stock-analysis-lianghua stock-strategy-backtester \
  crypto-market-data crypto-stock-market-data deepseek-v3-lite-agent --force
```

## 安装历史

### 2026-03-05
- 安装 `openai-whisper` (pipx)
- 安装 `Obsidian` (Homebrew)
- 安装 `mcporter` (npm)
- 安装 `clawhub` (npm)
- 通过 ClawHub 安装 7 个基础技能
- 通过 ClawHub 安装 7 个量化交易技能
- 创建 `installed-skills` 自定义技能

---

*最后更新: 2026-03-05*
