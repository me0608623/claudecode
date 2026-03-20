---
name: github-monitor
description: 搜尋、追蹤、分類 GitHub 上的熱門/快速增長專案，匹配用戶興趣領域
---

# GitHub Monitor v2

## 使用時機
- 搜尋 GitHub 上的熱門或快速增長專案
- 按用戶興趣分類（AI Agent、MCP、Robotics、RL、點雲、Flutter、量化、DevOps）
- 定期掃描生態系產出報告
- 追蹤重點專案的 star 增長趨勢

## 命令

### trending — 找最近 N 天的趨勢專案
```bash
python3 ~/.clawdbot/skills/github-monitor/github_monitor.py trending --days 7 --limit 10
```

### discover — 全分類廣泛掃描（星數最多 + 近期趨勢）
```bash
python3 ~/.clawdbot/skills/github-monitor/github_monitor.py discover
```

### report — 完整報告（趨勢 + 追蹤 + 分類 + 精選）
```bash
python3 ~/.clawdbot/skills/github-monitor/github_monitor.py report
```

### search — 按關鍵字或 topic 搜尋
```bash
python3 ~/.clawdbot/skills/github-monitor/github_monitor.py search --query "mcp server tool"
python3 ~/.clawdbot/skills/github-monitor/github_monitor.py search --topic reinforcement-learning
```

### analyze — 深度分析單一專案
```bash
python3 ~/.clawdbot/skills/github-monitor/github_monitor.py analyze --repo "owner/repo"
```

### track — 檢查追蹤專案狀態與增長
```bash
python3 ~/.clawdbot/skills/github-monitor/github_monitor.py track
```

## 分類系統

| ID | 領域 |
|----|------|
| ai-agent | AI Agent / LLM 工具 |
| mcp-server | MCP Server / Claude 生態系 |
| robotics | 機器人 / ROS 2 / SLAM |
| rl-sim | 強化學習 / 模擬器 (Isaac Sim) |
| 3d-pointcloud | 點雲 / 3D 感測 |
| flutter-mobile | Flutter / 行動應用 |
| quant-trading | 量化交易 / 金融科技 |
| devops-infra | DevOps / Docker |

## 輸出格式
- `--format table`（預設）：Markdown 表格
- `--format json`：結構化 JSON
- `--format markdown`（report 專用）：完整 Markdown 報告

## 檔案結構
```
~/.clawdbot/skills/github-monitor/
├── github_monitor.py      # 主程式
├── SKILL.md               # 技能說明
├── cache/                  # 報告快取（保留 7 天）
└── snapshots/              # Star 快照（保留 30 天，用於增長計算）
```
