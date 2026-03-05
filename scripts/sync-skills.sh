#!/bin/bash
# Sync OpenClaw skills to GitHub backup repository
# Runs daily at 5:00 PM via launchd

set -e

BACKUP_DIR="$HOME/Projects/openclaw-backup"
SKILLS_SOURCE="$HOME/.clawdbot/skills"
SKILLS_DEST="$BACKUP_DIR/skills"
LOG_FILE="$HOME/.openclaw/logs/sync-skills.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "=== Starting skills sync ==="

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    log "ERROR: Backup directory not found: $BACKUP_DIR"
    exit 1
fi

# Check if source skills exist
if [ ! -d "$SKILLS_SOURCE" ]; then
    log "ERROR: Skills source directory not found: $SKILLS_SOURCE"
    exit 1
fi

# Ensure skills destination exists and is clean
rm -rf "$SKILLS_DEST"
mkdir -p "$SKILLS_DEST"

cd "$BACKUP_DIR"

# Sync each skill directory
for skill_dir in "$SKILLS_SOURCE"/*/; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        log "Syncing skill: $skill_name"

        # Copy the skill directory
        cp -r "$skill_dir" "$SKILLS_DEST/$skill_name"

        # Remove nested .git directories to avoid submodule issues
        if [ -d "$SKILLS_DEST/$skill_name/.git" ]; then
            rm -rf "$SKILLS_DEST/$skill_name/.git"
        fi
    fi
done

log "Skills synced: $(ls "$SKILLS_DEST" | tr '\n' ' ')"

# Check for changes
if [ -n "$(git status --porcelain)" ]; then
    log "Changes detected, committing..."

    git add -A
    git commit -m "$(cat <<'EOF'
Auto-sync skills backup

Automated daily sync of OpenClaw skills.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"

    # Push using gh credential helper
    git push origin main

    log "Successfully committed and pushed changes"
else
    log "No changes to sync"
fi

log "=== Sync completed ==="
