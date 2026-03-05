# OpenClaw Configuration Backup

This repository contains a backup of OpenClaw configuration, custom skills, and memory.

## Structure

```
openclaw-backup/
├── config/
│   └── openclaw.json      # Main configuration (sanitized)
├── skills/
│   ├── cma-weather-skill/ # China Meteorological Administration weather skill
│   └── web-search-skill/  # Web search skill using DuckDuckGo
├── memory/
│   └── main.sqlite        # Memory database
└── README.md
```

## Setup Instructions

### 1. Clone this repository

```bash
git clone https://github.com/YOUR_USERNAME/openclaw-backup.git
cd openclaw-backup
```

### 2. Restore Configuration

```bash
# Create OpenClaw directory if not exists
mkdir -p ~/.openclaw

# Copy configuration (IMPORTANT: Replace placeholders first!)
cp config/openclaw.json ~/.openclaw/openclaw.json
```

### 3. Replace Placeholders

Before using the configuration, replace these placeholders with your actual values:

| Placeholder | Description |
|-------------|-------------|
| `{{BIGMODEL_API_KEY}}` | Your BigModel API key from open.bigmodel.cn |
| `{{TELEGRAM_BOT_TOKEN_1}}` | Your first Telegram bot token |
| `{{TELEGRAM_BOT_TOKEN_2}}` | Your second Telegram bot token |
| `{{GATEWAY_AUTH_TOKEN}}` | A secure token for gateway authentication |
| `{{HOME}}` | Your home directory path |

```bash
# Example: Replace placeholders with sed
sed -i '' 's/{{BIGMODEL_API_KEY}}/your_actual_key/g' ~/.openclaw/openclaw.json
sed -i '' 's/{{TELEGRAM_BOT_TOKEN_1}}/your_bot_token/g' ~/.openclaw/openclaw.json
sed -i '' 's/{{GATEWAY_AUTH_TOKEN}}/your_secure_token/g' ~/.openclaw/openclaw.json
sed -i '' 's|{{HOME}}|'$HOME'|g' ~/.openclaw/openclaw.json
```

### 4. Install Custom Skills

```bash
# Create skills directory
mkdir -p ~/.clawdbot/skills
mkdir -p ~/.openclaw/skills

# Copy skills
cp -r skills/cma-weather-skill ~/.clawdbot/skills/
cp -r skills/web-search-skill ~/.clawdbot/skills/

# Create symlinks to OpenClaw
ln -sf ~/.clawdbot/skills/cma-weather-skill ~/.openclaw/skills/
ln -sf ~/.clawdbot/skills/web-search-skill ~/.openclaw/skills/
```

### 5. Restore Memory (Optional)

```bash
cp memory/main.sqlite ~/.openclaw/memory/
```

## Custom Skills Included

### CMA Weather (中国气象局天气)

Get weather data from China Meteorological Administration.

```bash
# Usage
curl -s -A "Mozilla/5.0" "https://weather.cma.cn/api/weather/view"
```

### Web Search

Search the web using DuckDuckGo and Wikipedia APIs.

```bash
# DuckDuckGo search
curl -s "https://api.duckduckgo.com/?q=your_query&format=json"
```

## Security Notes

- **NEVER** commit actual API keys or tokens to this repository
- The `openclaw.json` in this repo has placeholders for all sensitive values
- Keep your actual credentials in a secure location (e.g., 1Password, environment variables)

## License

MIT
