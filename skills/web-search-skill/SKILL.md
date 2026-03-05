---
name: web-search
description: "Search the web using DuckDuckGo, Google, or Bing. Use when user asks to search for information online, look up something, find answers, or research a topic. No API key required for DuckDuckGo. Returns search results with titles, URLs, and snippets."
homepage: https://duckduckgo.com/
metadata: { "openclaw": { "emoji": "🔍", "requires": { "bins": ["curl"] } } }
---

# Web Search Skill

Search the web for information using multiple search engines.

## When to Use

✅ **USE this skill when:**
- "Search for..." / "帮我搜索..."
- "Look up..." / "查一下..."
- "Find information about..." / "找一下关于...的信息"
- "What is..." / "什么是..."
- Research topics, products, or concepts
- Find documentation or tutorials

❌ **DON'T use this skill when:**
- You need to read/fetch a specific URL → use web-reader tool
- You need to interact with a website → use browser tools
- You need code documentation → use Context7

## Search Engines

### 1. DuckDuckGo (Default - No API Key)

DuckDuckGo Instant Answer API - no API key required.

```bash
# DuckDuckGo Instant Answer
curl -s "https://api.duckduckgo.com/?q=Python+programming&format=json&no_html=1" | python3 -m json.tool
```

### 2. DuckDuckGo HTML (Full Results)

```bash
# Get HTML search results
curl -s -A "Mozilla/5.0" "https://html.duckduckgo.com/html/?q=Python+programming" | \
  grep -oP '<a[^>]*class="result__a"[^>]*>.*?</a>' | head -10
```

### 3. SearXNG (Privacy-focused metasearch)

If you have a SearXNG instance:

```bash
curl -s "https://searx.be/search?q=Python+programming&format=json" | python3 -m json.tool
```

### 4. Wikipedia API

```bash
# Search Wikipedia
curl -s "https://en.wikipedia.org/w/api.php?action=opensearch&search=Python&limit=5&format=json" | python3 -m json.tool

# Get Wikipedia article summary
curl -s "https://en.wikipedia.org/api/rest_v1/page/summary/Python_(programming_language)" | python3 -m json.tool
```

## Quick Commands

### Simple DuckDuckGo Search

```bash
search_web() {
  local query="$1"
  local encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$query'))")
  curl -s "https://api.duckduckgo.com/?q=$encoded&format=json&no_html=1&skip_disambig=1" | \
  python3 -c "
import json, sys
d = json.load(sys.stdin)
if d.get('AbstractText'):
    print('📝 Summary:', d['AbstractText'])
    if d.get('AbstractURL'):
        print('🔗 Source:', d['AbstractURL'])
elif d.get('RelatedTopics'):
    for t in d['RelatedTopics'][:5]:
        if isinstance(t, dict) and t.get('Text'):
            print('•', t['Text'])
            if t.get('FirstURL'):
                print('  🔗', t['FirstURL'])
else:
    print('No direct answer found. Try a more specific query.')
"
}

# Usage: search_web "What is Python programming"
```

### Full Web Search (HTML Scraping)

```bash
web_search() {
  local query="$1"
  local encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$query'))")

  echo "🔍 Searching for: $query"
  echo "---"

  curl -s -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
    "https://html.duckduckgo.com/html/?q=$encoded" | \
  python3 -c "
import sys, re
html = sys.stdin.read()
results = re.findall(r'<a[^>]*class=\"result__a\"[^>]*href=\"([^\"]+)\"[^>]*>([^<]+)</a>', html)
snippets = re.findall(r'<a[^>]*class=\"result__snippet\"[^>]*>([^<]+)</a>', html)

for i, (url, title) in enumerate(results[:5], 1):
    print(f'{i}. {title.strip()}')
    print(f'   🔗 {url}')
    if i-1 < len(snippets):
        print(f'   📄 {snippets[i-1].strip()[:100]}...')
    print()
"
}

# Usage: web_search "best Python IDE 2024"
```

### Wikipedia Quick Lookup

```bash
wiki_lookup() {
  local topic="$1"
  local encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$topic'))")

  curl -s "https://en.wikipedia.org/api/rest_v1/page/summary/$encoded" | \
  python3 -c "
import json, sys
d = json.load(sys.stdin)
if d.get('title') and not d.get('type') == 'https://mediawiki.org/wiki/HyperAPI/errors':
    print(f\"📚 {d['title']}\")
    print(f\"📄 {d.get('extract', 'No summary available')[:500]}\")
    print(f\"🔗 {d.get('content_urls', {}).get('desktop', {}).get('page', 'N/A')}\")
else:
    print('Topic not found on Wikipedia.')
"
}

# Usage: wiki_lookup "Machine_learning"
```

## Chinese Search (Baidu)

For Chinese language queries:

```bash
baidu_search() {
  local query="$1"
  local encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$query'))")

  curl -s -A "Mozilla/5.0" "https://www.baidu.com/s?wd=$encoded" | \
  grep -oP '<h3[^>]*>.*?</h3>' | head -5
}

# Note: Baidu heavily uses JavaScript, consider using their API or alternative
```

## Response Format

Results typically include:
- **Title** - Page title
- **URL** - Link to the source
- **Snippet** - Brief description/excerpt

## Notes

- DuckDuckGo Instant Answer works best for factual queries
- For complex searches, HTML scraping provides more results
- Wikipedia API is great for encyclopedic information
- No API keys required for DuckDuckGo or Wikipedia
- Rate limits apply; don't spam requests
- Use URL encoding for queries with special characters

## Example Queries

```bash
# Quick fact lookup
search_web "capital of France"

# Research topic
web_search "machine learning tutorial for beginners 2024"

# Wikipedia lookup
wiki_lookup "Artificial_intelligence"

# Technical documentation
web_search "Python requests library documentation"
```
