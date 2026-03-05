---
name: cma-weather
description: "Get weather from China Meteorological Administration (中国气象局). Use when user asks about weather in China, or wants official CMA data. Supports IP-based location detection and city-specific queries. Data includes temperature, humidity, wind, 7-day forecast, and weather alerts."
homepage: https://weather.cma.cn/
metadata: { "openclaw": { "emoji": "🌤️", "requires": { "bins": ["curl"] } } }
---

# CMA Weather Skill (中国气象局天气)

Get weather data from China Meteorological Administration (中国气象局) - the official source for Chinese weather data.

## When to Use

✅ **USE this skill when:**
- User asks about weather in Chinese cities
- User wants official CMA/中国气象局 data
- User needs weather alerts/warnings for China
- Queries involving Chinese location names

❌ **DON'T use this skill when:**
- International locations outside China → use the default `weather` skill with wttr.in
- Historical weather data
- Aviation/marine weather

## API Endpoints

### 1. Auto-location (IP-based)

Returns weather for the requester's location based on IP address.

```bash
curl -s -A "Mozilla/5.0" "https://weather.cma.cn/api/weather/view"
```

### 2. City-specific Weather

Replace `{stationid}` with the CMA station ID.

```bash
curl -s -A "Mozilla/5.0" "https://weather.cma.cn/api/weather/view?stationid={stationid}"
```

### 3. Province/City List

Get weather data for all cities at a specific level:
- Level 1: Provinces
- Level 2: Cities within a province

```bash
curl -s -A "Mozilla/5.0" "https://weather.cma.cn/api/map/weather/1?t=$(date +%s)000"
```

## Common Station IDs

| City | Station ID |
|------|------------|
| 北京 | 54511 |
| 上海 | 58362 |
| 广州 | 59287 |
| 深圳 | 59493 |
| 成都 | 56294 |
| 杭州 | 58457 |
| 南京 | 58238 |
| 武汉 | 57494 |
| 西安 | 57132 |
| 重庆 | 57516 |

## Response Format

The API returns JSON with the following structure:

```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "location": {
      "id": "54511",
      "name": "北京",
      "path": "中国, 北京, 北京"
    },
    "now": {
      "temperature": -0.6,
      "humidity": 79.0,
      "windDirection": "东南风",
      "windScale": "微风",
      "pressure": 1022.0,
      "precipitation": 0.0
    },
    "daily": [
      {
        "date": "2026/03/05",
        "high": 1.0,
        "low": -5.0,
        "dayText": "小雪",
        "nightText": "多云",
        "dayWindDirection": "东北风",
        "dayWindScale": "微风"
      }
    ],
    "alarm": [...],
    "jieQi": "惊蛰"
  }
}
```

## Quick Commands

### Current Weather (Auto-location)

```bash
curl -s -A "Mozilla/5.0" "https://weather.cma.cn/api/weather/view" | python3 -c "
import json, sys
d = json.load(sys.stdin)['data']
loc = d['location']['name']
now = d['now']
print(f'{loc}: {now[\"temperature\"]}C, {now[\"windDirection\"]} {now[\"windScale\"]}, 湿度 {now[\"humidity\"]}%')
"
```

### Specific City Weather

```bash
# Beijing
curl -s -A "Mozilla/5.0" "https://weather.cma.cn/api/weather/view?stationid=54511" | python3 -c "
import json, sys
d = json.load(sys.stdin)['data']
loc = d['location']
now = d['now']
daily = d['daily'][0]
print(f\"📍 {loc['name']} ({loc['path']})\")
print(f\"🌡️ 当前: {now['temperature']}C (体感 {now.get('feelst', 'N/A')}C)\")
print(f\"💨 {now['windDirection']} {now['windScale']}\")
print(f\"💧 湿度: {now['humidity']}%\")
print(f\"📅 今日: {daily['low']}C ~ {daily['high']}C, {daily['dayText']}\")
if d.get('alarm'):
    for a in d['alarm']:
        print(f\"⚠️ 预警: {a['title']}\")
"
```

### 7-Day Forecast

```bash
curl -s -A "Mozilla/5.0" "https://weather.cma.cn/api/weather/view" | python3 -c "
import json, sys
d = json.load(sys.stdin)['data']
loc = d['location']['name']
print(f'📍 {loc} 7日天气预报')
print('-' * 40)
for day in d['daily']:
    date = day['date'].split('/')[-1] + '/' + day['date'].split('/')[-2]
    print(f\"{date} | {day['low']:>3}C ~ {day['high']:>3}C | {day['dayText']}转{day['nightText']}\")
"
```

## Notes

- Uses official CMA data (中国气象局官方数据)
- Includes weather alerts (气象预警)
- Shows solar terms (节气)
- No API key required
- Works best for Chinese locations
- Use browser User-Agent to avoid WAF blocking
