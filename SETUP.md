# OpenClaw 配置备份系统

本文档记录了 2026年3月5日 完成的 OpenClaw 配置自动备份系统搭建过程。

## 概述

将 OpenClaw 的配置、技能和记忆自动同步到 GitHub 仓库，实现：
- 每天下午 5:00 自动备份
- 敏感信息自动清理
- 双重定时任务保障

## 仓库结构

```
openclaw-config/
├── config/
│   └── openclaw.json          # 主配置文件（API keys 已清理）
├── skills/
│   ├── claude-code-clawdbot-skill/  # Claude Code 集成技能（多任务开发用 tmux）
│   ├── cma-weather-skill/           # 中国气象局天气技能
│   └── web-search-skill/            # 网页搜索技能
├── memory/
│   └── main.sqlite            # 对话记忆数据库
├── scripts/
│   └── sync-skills.sh         # 同步脚本
├── agents/                    # Agent 配置（预留）
├── .gitignore                 # 敏感文件排除
├── secrets.env.example        # 环境变量模板
├── README.md                  # 恢复说明
└── SETUP.md                   # 本文档
```

## 同步内容

| 目录 | 来源 | 说明 |
|------|------|------|
| `skills/` | `~/.clawdbot/skills/` | 自定义技能 |
| `config/` | `~/.openclaw/openclaw.json` | 配置（敏感信息已清理） |
| `memory/` | `~/.openclaw/memory/main.sqlite` | 对话记忆数据库 |

## 敏感信息处理

同步脚本会自动将以下敏感信息替换为占位符：

| 原始字段 | 替换为 |
|----------|--------|
| `"apiKey": "xxx"` | `"apiKey": "{{API_KEY}}"` |
| `"token": "xxx"` | `"token": "{{TOKEN}}"` |
| `"botToken": "xxx"` | `"botToken": "{{BOT_TOKEN}}"` |
| `"password": "xxx"` | `"password": "{{PASSWORD}}"` |
| `"secret": "xxx"` | `"secret": "{{SECRET}}"` |

## 定时任务配置

系统使用双重定时任务机制确保备份可靠性：

### 1. OpenClaw Cron（主任务）

```bash
# 查看任务列表
openclaw cron list

# 查看任务状态
openclaw cron status

# 查看执行历史
openclaw cron runs --id 27b6de74-0c90-4ca5-ba06-fa318619f363

# 手动触发
openclaw cron run 27b6de74-0c90-4ca5-ba06-fa318619f363
```

**配置详情：**
- 任务名称: `sync-backup`
- 调度表达式: `0 17 * * *`
- 时区: `Asia/Shanghai`
- 任务类型: Agent 执行脚本并生成报告

### 2. macOS Launchd（备用任务）

```bash
# 查看任务状态
launchctl list | grep openclaw

# 手动触发
~/Projects/openclaw-backup/scripts/sync-skills.sh

# 禁用任务
launchctl unload ~/Library/LaunchAgents/com.openclaw.sync-skills.plist

# 启用任务
launchctl load ~/Library/LaunchAgents/com.openclaw.sync-skills.plist
```

**配置文件位置：**
- Plist: `~/Library/LaunchAgents/com.openclaw.sync-skills.plist`
- 脚本: `~/Projects/openclaw-backup/scripts/sync-skills.sh`

## 日志位置

```
~/.openclaw/logs/sync-backup.log      # 同步脚本日志
~/.openclaw/logs/sync-skills-error.log # 错误日志
```

## 恢复指南

### 1. 克隆仓库

```bash
git clone https://github.com/voilet/openclaw-config.git
cd openclaw-config
```

### 2. 恢复配置

```bash
# 创建目录
mkdir -p ~/.openclaw ~/.clawdbot/skills

# 复制配置（需先替换占位符！）
cp config/openclaw.json ~/.openclaw/

# 替换占位符为实际值
sed -i '' 's/{{API_KEY}}/your_actual_api_key/g' ~/.openclaw/openclaw.json
sed -i '' 's/{{BOT_TOKEN}}/your_bot_token/g' ~/.openclaw/openclaw.json
# ... 其他占位符
```

### 3. 恢复技能

```bash
# 复制技能到 clawdbot
cp -r skills/* ~/.clawdbot/skills/

# 创建符号链接到 OpenClaw
for skill in ~/.clawdbot/skills/*/; do
    skill_name=$(basename "$skill")
    ln -sf "$skill" ~/.openclaw/skills/
done
```

### 4. 恢复记忆

```bash
cp memory/main.sqlite ~/.openclaw/memory/
```

## 同步脚本源码

脚本位于 `scripts/sync-skills.sh`，主要功能：

1. **Git 同步**: 拉取最新代码避免冲突
2. **Skills 同步**: 复制技能目录，移除嵌套 `.git`
3. **Config 同步**: 复制配置并清理敏感信息
4. **Memory 同步**: 复制 SQLite 数据库
5. **提交推送**: 自动提交变更到 GitHub

## 相关链接

- **GitHub 仓库**: https://github.com/voilet/openclaw-config
- **OpenClaw 文档**: https://docs.openclaw.ai

## 操作历史

### 2026-03-05

1. **创建 GitHub 仓库**
   ```bash
   gh repo create openclaw-config --public --source=. --push
   ```

2. **补充缺失的 skill**
   - `claude-code-clawdbot-skill` 原为符号链接，被排除
   - 手动复制并移除嵌套 `.git` 目录

3. **创建同步脚本**
   - 位置: `scripts/sync-skills.sh`
   - 功能: 同步 skills、config、memory

4. **配置 macOS Launchd 定时任务**
   - Plist: `~/Library/LaunchAgents/com.openclaw.sync-skills.plist`
   - 时间: 每天 17:00

5. **配置 OpenClaw Cron 定时任务**
   ```bash
   openclaw cron add \
     --name "sync-backup" \
     --cron "0 17 * * *" \
     --tz "Asia/Shanghai" \
     --message "Execute the backup sync script..."
   ```

6. **添加 config 和 memory 同步**
   - 更新脚本支持配置文件敏感信息清理
   - 添加 SQLite 数据库同步

---

## 2026-03-05 技能安装记录

### 环境工具安装

通过 Homebrew 和 pipx 安装了以下工具：

| 工具 | 版本 | 安装方式 | 用途 |
|------|------|----------|------|
| **openai-whisper** | 20250625 | pipx | OpenAI 语音识别模型 |
| **Obsidian** | 1.12.4 | Homebrew Cask | 笔记应用 |
| **mcporter** | 0.7.3 | npm | MCP 服务器管理工具 |
| **clawhub** | 0.7.0 | npm | OpenClaw 技能市场 CLI |

### 安装过程中遇到的问题及解决方案

#### 1. PEP 668 保护错误
**问题**：使用 `pip3 install` 安装 Python 包时报错：
```
error: externally-managed-environment
× This environment is externally managed
```

**原因**：macOS Homebrew Python 受 PEP 668 保护，禁止直接安装全局包。

**解决方案**：使用 `pipx` 安装 CLI 工具：
```bash
brew install pipx
pipx ensurepath
pipx install openai-whisper
```

#### 2. Obsidian 安装冲突
**问题**：Homebrew 安装 Obsidian 时报错：
```
Error: It seems there is already a Binary at '/opt/homebrew/bin/obsidian'
```

**原因**：之前通过 npm 安装了 `obsidian-cli`，与 Obsidian 桌面应用冲突。

**解决方案**：卸载 npm 版本后重新安装：
```bash
npm uninstall -g obsidian-cli
brew install --cask obsidian
```

### ClawHub 技能安装

通过 `clawhub install` 安装了以下技能：

| 技能 | 版本 | 用途 | 备注 |
|------|------|------|------|
| **session-logs** | 1.0.0 | 会话日志记录 | 基础技能 |
| **model-usage-linux** | 1.0.0 | 模型使用统计 | Linux 环境适用 |
| **github** | 1.0.0 | GitHub 仓库操作 | 开发者必备 |
| **tmux** | 1.0.0 | 终端复用器管理 | 多终端会话 |
| **developer** | 1.0.0 | 通用开发工具集 | 开发辅助 |
| **python-executor** | 0.1.5 | Python 代码执行 | ⚠️ 标记为可疑，需 --force |
| **github-cli** | 1.0.0 | GitHub CLI 集成 | ⚠️ 标记为可疑，需 --force |

### ClawHub 常用命令

```bash
# 搜索技能
clawhub search <关键词>

# 安装技能
clawhub install <skill-name>

# 强制安装被标记的技能
clawhub install <skill-name> --force

# 列出已安装技能
clawhub list

# 更新技能
clawhub update

# 查看技能详情
clawhub inspect <skill-name>
```

### MCPorter 常用命令

```bash
# 添加 MCP 服务器
mcporter config add <name> <url>

# 列出已配置的 MCP
mcporter list
```

### 当前已安装技能总览

```bash
$ clawhub list
session-logs       1.0.0
model-usage-linux  1.0.0
github             1.0.0
tmux               1.0.0
developer          1.0.0
python-executor    0.1.5
github-cli         1.0.0
```

### Whisper 使用示例

```bash
# 转录音频文件（中文）
whisper audio.mp3 --language Chinese --model medium

# 模型选择参考
# tiny    - 最快，准确度最低
# base    - 平衡
# small   - 较好
# medium  - 推荐（需要足够显存/内存）
# large   - 最准确，资源消耗最大
```

---

*本文档由 Claude Code 自动生成 - 2026年3月5日*
