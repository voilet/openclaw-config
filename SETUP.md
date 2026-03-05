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
│   ├── claude-code-clawdbot-skill/  # Claude Code 集成技能
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

*本文档由 Claude Code 自动生成 - 2026年3月5日*
