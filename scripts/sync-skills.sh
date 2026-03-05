#!/bin/bash
# Sync OpenClaw configuration, skills, and memory to GitHub backup repository
# Runs daily at 5:00 PM via launchd

set -e

BACKUP_DIR="$HOME/Projects/openclaw-backup"
OPENCLAW_DIR="$HOME/.openclaw"
CLAWDBOT_DIR="$HOME/.clawdbot"
LOG_FILE="$OPENCLAW_DIR/logs/sync-backup.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

sanitize_config() {
    local input_file="$1"
    local output_file="$2"

    # Read config and replace sensitive values with placeholders
    sed -E '
        # Replace API keys
        s/"apiKey": "[^"]*"/"apiKey": "{{API_KEY}}"/g
        # Replace tokens
        s/"token": "[^"]*"/"token": "{{TOKEN}}"/g
        s/"botToken": "[^"]*"/"botToken": "{{BOT_TOKEN}}"/g
        # Replace passwords
        s/"password": "[^"]*"/"password": "{{PASSWORD}}"/g
        # Replace secrets
        s/"secret": "[^"]*"/"secret": "{{SECRET}}"/g
    ' "$input_file" > "$output_file"
}

log "=== Starting OpenClaw backup sync ==="

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    log "ERROR: Backup directory not found: $BACKUP_DIR"
    exit 1
fi

cd "$BACKUP_DIR"

# Pull latest changes to avoid conflicts
log "Syncing with remote..."
git fetch origin
git reset --hard origin/main 2>/dev/null || true

# ============================================
# Sync Skills
# ============================================
log "--- Syncing skills ---"
SKILLS_DEST="$BACKUP_DIR/skills"
rm -rf "$SKILLS_DEST"
mkdir -p "$SKILLS_DEST"

if [ -d "$CLAWDBOT_DIR/skills" ]; then
    for skill_dir in "$CLAWDBOT_DIR/skills"/*/; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            log "Syncing skill: $skill_name"

            cp -r "$skill_dir" "$SKILLS_DEST/$skill_name"

            # Remove nested .git directories
            rm -rf "$SKILLS_DEST/$skill_name/.git"
        fi
    done
    log "Skills synced: $(ls "$SKILLS_DEST" | tr '\n' ' ')"
else
    log "WARNING: No skills directory found"
fi

# ============================================
# Sync Config
# ============================================
log "--- Syncing config ---"
CONFIG_DEST="$BACKUP_DIR/config"
mkdir -p "$CONFIG_DEST"

if [ -f "$OPENCLAW_DIR/openclaw.json" ]; then
    sanitize_config "$OPENCLAW_DIR/openclaw.json" "$CONFIG_DEST/openclaw.json"
    log "Config synced (sanitized)"
else
    log "WARNING: No openclaw.json found"
fi

# ============================================
# Sync Memory
# ============================================
log "--- Syncing memory ---"
MEMORY_DEST="$BACKUP_DIR/memory"
mkdir -p "$MEMORY_DEST"

if [ -f "$OPENCLAW_DIR/memory/main.sqlite" ]; then
    cp "$OPENCLAW_DIR/memory/main.sqlite" "$MEMORY_DEST/main.sqlite"
    log "Memory synced"
else
    log "WARNING: No memory database found"
fi

# ============================================
# Commit and Push (skip if only script changed)
# ============================================
# Temporarily restore the script to avoid committing it every time
git checkout origin/main -- scripts/sync-skills.sh 2>/dev/null || true

if [ -n "$(git status --porcelain -- ':!scripts/sync-skills.sh')" ]; then
    log "Changes detected, committing..."

    git add -A
    git commit -m "$(cat <<'EOF'
Auto-sync OpenClaw backup

- Skills: synced from ~/.clawdbot/skills
- Config: synced and sanitized (API keys removed)
- Memory: synced from ~/.openclaw/memory

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"

    git push origin main
    log "Successfully committed and pushed changes"
else
    log "No changes to sync"
fi

log "=== Backup sync completed ==="
