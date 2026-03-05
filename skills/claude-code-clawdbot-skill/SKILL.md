---
name: claude-code-clawdbot
description: "Run Claude Code (Anthropic) from this host via the `claude` CLI (Agent SDK) in headless mode (`-p`) for codebase analysis, refactors, test fixing, and structured output. Use when the user asks to use Claude Code, run `claude -p`, use Plan Mode, auto-approve tools with --allowedTools, generate JSON output, or integrate Claude Code into Clawdbot workflows/cron." 
---

# Claude Code (Clawdbot)

Use the locally installed **Claude Code** CLI reliably.

This skill supports two execution styles:
- **Headless mode** (non-interactive): best for normal prompts and structured output.
- **Interactive mode (tmux)**: required for **Superpowers workflow** which involves multi-step planning and execution.

This skill is for **driving the Claude Code CLI**, not the Claude API directly.

## Quick checks

Verify installation:
```bash
claude --version
```

Run a minimal headless prompt (prints a single response):
```bash
~/.openclaw/skills/claude-code-clawdbot-skill/scripts/claude_code_run.py -p "Return only the single word OK."
```

## Core workflow

### 1) Run a headless prompt in a repo

```bash
cd /path/to/repo
~/.openclaw/skills/claude-code-clawdbot-skill/scripts/claude_code_run.py \
  -p "Summarize this project and point me to the key modules." \
  --permission-mode plan
```

### 2) Allow tools (auto-approve)

Claude Code supports tool allowlists via `--allowedTools`.
Example: allow read/edit + bash:
```bash
./scripts/claude_code_run.py \
  -p "Run the test suite and fix any failures." \
  --allowedTools "Bash,Read,Edit"
```

### 3) Get structured output

```bash
./scripts/claude_code_run.py \
  -p "Summarize this repo in 5 bullets." \
  --output-format json
```

### 4) Add extra system instructions

```bash
./scripts/claude_code_run.py \
  -p "Review the staged diff for security issues." \
  --append-system-prompt "You are a security engineer. Be strict." \
  --allowedTools "Bash(git diff *),Bash(git status *),Read"
```

## Notes (important)

- **After correcting Claude Code's mistakes**: Always instruct Claude Code to run:
  > "Update your CLAUDE.md so you don't make that mistake again."
  
  This ensures Claude Code records lessons learned and avoids repeating the same errors.

- Claude Code sometimes expects a TTY.
- **Headless**: this wrapper uses `script(1)` to force a pseudo-terminal.
- **Superpowers workflow** is best run in **interactive** mode; this wrapper can start an interactive Claude Code session in **tmux**.
- Use `--permission-mode plan` when you want read-only planning.
- Keep `--allowedTools` narrow (principle of least privilege), especially in automation.

## High‑leverage Claude Code tips (from the official docs)

### 1) Always give Claude a way to verify (tests/build/screenshots)

Claude performs dramatically better when it can verify its work.
Make verification explicit in the prompt, e.g.:
- "Fix the bug **and run tests**. Done when `npm test` passes."
- "Implement UI change, **take a screenshot** and compare to this reference."

### 2) Explore → Plan → Implement (use Plan Mode)

For multi-step work, start in plan mode to do safe, read-only analysis:
```bash
./scripts/claude_code_run.py -p "Analyze and propose a plan" --permission-mode plan
```
Then switch to execution (`acceptEdits`) once the plan is approved.

### 3) Manage context aggressively: /clear and /compact

Long, mixed-topic sessions degrade quality.
- Use `/clear` between unrelated tasks.
- Use `/compact Focus on <X>` when nearing limits to preserve the right details.

### 4) Rewind aggressively: /rewind (checkpoints)

Claude checkpoints before changes.
If an approach is wrong, use `/rewind` (or Esc Esc) to restore:
- conversation only
- code only
- both

This enables "try something risky → rewind if wrong" loops.

### 5) Prefer CLAUDE.md for durable rules; keep it short

Best practice is a concise CLAUDE.md (global or per-project) for:
- build/test commands Claude should use
- repo etiquette / style rules that differ from defaults
- non-obvious environment quirks

Overlong CLAUDE.md files get ignored.

### 6) Permissions: deny > ask > allow (and scope matters)

In `.claude/settings.json` / `~/.claude/settings.json`, rules match in order:
**deny first**, then ask, then allow.
Use deny rules to block secrets (e.g. `.env`, `secrets/**`).

### 7) Bash env vars don't persist; use CLAUDE_ENV_FILE for persistence

Each Bash tool call runs in a fresh shell; `export FOO=bar` won't persist.
If you need persistent env setup, set (before starting Claude Code):
```bash
export CLAUDE_ENV_FILE=/path/to/env-setup.sh
```
Claude will source it before each Bash command.

### 8) Hooks beat "please remember" instructions

Use hooks to enforce deterministic actions (format-on-edit, block writes to sensitive dirs, etc.)
when you need guarantees.

### 9) Use subagents for heavy investigation / independent review

Subagents can read many files without polluting the main context.
Use them for broad codebase research or post-implementation review.

### 10) Treat Claude as a Unix utility (headless, pipes, structured output)

Examples:
```bash
cat build-error.txt | claude -p "Explain root cause" 
claude -p "List endpoints" --output-format json
```
This is ideal for CI and automation.

## Multi-task Development with tmux (多任务开发最佳实践)

当使用 Claude Code 同时开发多个任务时，**强烈推荐使用 tmux** 来管理会话：

### 为什么使用 tmux

1. **状态保持**: 每个 Claude Code 会话独立运行，断开后不丢失上下文
2. **快速切换**: `tmux switch` 快速在任务间切换
3. **进度监控**: `tmux capture-pane` 随时查看任务执行状态
4. **并行开发**: 多个任务可同时进行，互不干扰

### 推荐的 Session 命名规范

```bash
# 按项目/功能命名
--tmux-session cc-auth      # 认证功能开发
--tmux-session cc-api       # API 开发
--tmux-session cc-fix-bug   # Bug 修复
--tmux-session cc-refactor  # 重构任务
```

### 常用 tmux 管理命令

```bash
# 列出所有 Claude Code 会话
tmux -S /tmp/clawdbot-tmux-sockets/claude-code.sock list-sessions

# 附加到特定会话
tmux -S /tmp/clawdbot-tmux-sockets/claude-code.sock attach -t cc-auth

# 查看会话输出（不附加）
tmux -S /tmp/clawdbot-tmux-sockets/claude-code.sock capture-pane -p -t cc-auth -S -100

# 杀死完成的会话
tmux -S /tmp/clawdbot-tmux-sockets/claude-code.sock kill-session -t cc-auth
```

### 多任务工作流示例

```bash
# 任务1: 开发认证模块
./scripts/claude_code_run.py \
  --mode interactive \
  --tmux-session cc-auth \
  -p "Implement OAuth2 authentication"

# 任务2: 开发 API 端点（并行）
./scripts/claude_code_run.py \
  --mode interactive \
  --tmux-session cc-api \
  -p "Create REST API endpoints for user management"

# 随时检查任务1的进度
tmux -S /tmp/clawdbot-tmux-sockets/claude-code.sock capture-pane -p -t cc-auth -S -50

# 切换到任务2继续工作
tmux -S /tmp/clawdbot-tmux-sockets/claude-code.sock attach -t cc-api
```

## Interactive mode (tmux)

For multi-step workflows like Superpowers, use interactive mode:

```bash
./scripts/claude_code_run.py \
  --mode interactive \
  --tmux-session cc-work \
  --permission-mode acceptEdits \
  --allowedTools "Bash,Read,Edit,Write" \
  -p "Your multi-step task here"
```

It will print tmux attach/capture commands so you can monitor progress.

## Superpowers Workflow (推荐)

**Superpowers** 是一套完整的软件开发工作流，包含 TDD、调试、协作模式等技能。

GitHub: https://github.com/obra/superpowers

### 安装 (Claude Code)

```bash
# 注册 marketplace
/plugin marketplace add obra/superpowers-marketplace

# 安装插件
/plugin install superpowers@superpowers-marketplace
```

### 核心工作流

Superpowers 的核心流程是：**头脑风暴 → 规划 → 执行**

```
1. brainstorming     → 理解需求，产出设计文档
2. writing-plans     → 将设计拆分为小任务（每个 2-5 分钟）
3. executing-plans   → 批量执行任务，定期检查点
```

### 1. Brainstorming (头脑风暴)

**触发时机**: 在任何创造性工作之前

**做什么**:
- 探索项目上下文（文件、文档、commits）
- 逐个提问澄清需求
- 提出 2-3 个方案及权衡
- 分段展示设计，获取批准
- 保存设计文档到 `docs/plans/YYYY-MM-DD-<topic>-design.md`

**示例命令** (interactive mode):
```bash
./scripts/claude_code_run.py \
  --mode interactive \
  --tmux-session cc-brainstorm \
  --permission-mode acceptEdits \
  --allowedTools "Bash,Read,Edit,Write" \
  -p "I want to build a user authentication system with OAuth support."
```

### 2. Writing Plans (编写计划)

**触发时机**: 设计文档批准后

**做什么**:
- 将设计拆分为 bite-sized 任务（每个 2-5 分钟）
- 每个任务包含：精确文件路径、完整代码、验证步骤
- 遵循 TDD、DRY、YAGNI 原则
- 保存计划到 `docs/plans/YYYY-MM-DD-<feature-name>.md`

**任务结构示例**:
```markdown
### Task 1: Create User Model

**Files:**
- Create: `src/models/user.py`
- Test: `tests/models/test_user.py`

**Step 1: Write the failing test**
**Step 2: Run test to verify it fails**
**Step 3: Write minimal implementation**
**Step 4: Run test to verify it passes**
**Step 5: Commit**
```

### 3. Executing Plans (执行计划)

**触发时机**: 计划编写完成后

**做什么**:
- 加载并审查计划
- 批量执行任务（默认前 3 个）
- 每批次后报告进度，等待反馈
- 所有任务完成后调用 `finishing-a-development-branch`

**执行模式**:
1. **Subagent-Driven** (同会话): 每个任务派发新 subagent，任务间 review
2. **Parallel Session** (新会话): 批量执行，检查点暂停

### 可用技能列表

| 技能 | 用途 |
|------|------|
| `brainstorming` | 需求澄清，设计文档 |
| `writing-plans` | 编写实现计划 |
| `executing-plans` | 执行计划（批量+检查点） |
| `subagent-driven-development` | Subagent 驱动开发 |
| `test-driven-development` | RED-GREEN-REFACTOR 循环 |
| `systematic-debugging` | 系统化调试 |
| `verification-before-completion` | 完成前验证 |
| `requesting-code-review` | 请求代码审查 |
| `receiving-code-review` | 处理审查反馈 |
| `using-git-worktrees` | 并行开发分支 |
| `finishing-a-development-branch` | 完成/合并分支 |

### 完整示例

```bash
# 启动 interactive session
./scripts/claude_code_run.py \
  --mode interactive \
  --tmux-session cc-feature \
  --permission-mode acceptEdits \
  --allowedTools "Bash,Read,Edit,Write" \
  -p "I want to add rate limiting to my Flask API. Use the superpowers workflow: brainstorm first, then write a plan, then execute."

# 监控进度
tmux -S /tmp/clawdbot-tmux-sockets/claude-code.sock attach -t cc-feature

# 查看输出快照
tmux -S /tmp/clawdbot-tmux-sockets/claude-code.sock capture-pane -p -J -t cc-feature:0.0 -S -200
```

### 关键原则

- **TDD 优先**: 先写测试，再写代码
- **小步前进**: 每个任务 2-5 分钟
- **频繁提交**: 每个任务完成后 commit
- **验证驱动**: 每步都有验证，不只是"应该可以"
- **设计先行**: 任何代码之前必须有设计文档

## Operational gotchas (learned in practice)

### 1) Vite + ngrok: "Blocked request. This host (...) is not allowed"

If you expose a Vite dev server through ngrok, Vite will block unknown Host headers unless configured.

- **Vite 7** expects `server.allowedHosts` to be `true` or `string[]`.
  - ✅ Allow all hosts (quick):
    ```ts
    server: { host: true, allowedHosts: true }
    ```
  - ✅ Allow just your ngrok host (safer):
    ```ts
    server: { host: true, allowedHosts: ['xxxx.ngrok-free.app'] }
    ```
  - ❌ Do **not** set `allowedHosts: 'all'` (won't work in Vite 7).

After changing `vite.config.*`, restart the dev server.

### 2) Don't accidentally let your *shell* eat your prompt

When you drive tmux via a shell command (e.g. `tmux send-keys ...`), avoid unescaped **backticks** and shell substitutions in the text you pass.
They can be interpreted by your shell before the text even reaches Claude Code.

Practical rule:
- Prefer sending prompts from a file, or ensure the wrapper/script quotes prompt text safely.

### 3) Long-running dev servers should run in a persistent session

In automation environments, backgrounded `vite` / `ngrok` processes can get SIGKILL.
Prefer running them in a managed background session (Clawdbot exec background) or tmux, and explicitly stop them when done.

## Bundled script

- `scripts/claude_code_run.py`: wrapper that runs the local `claude` binary with a pseudo-terminal and forwards flags.
