# GitHub 趨勢追蹤 — Cron Job Prompt

以下是可直接貼入 OpenClaw cron job 的 prompt。

---

## 方案 A：每週完整報告（建議 Commander 使用）

**排程：** 每週一 09:00 (cron: `0 9 * * 1`)
**Agent：** commander
**Session：** isolated
**Delivery：** discord channel

```
你是 Commander，執行每週 GitHub 生態系掃描任務。

步驟：
1) 執行完整報告：
   python3 ~/.clawdbot/skills/github-monitor/github_monitor.py report --format markdown

2) 閱讀報告輸出，根據以下 8 個分類整理精選清單：
   - AI Agent / LLM 工具
   - MCP Server / Claude 生態系
   - 機器人 / ROS 2 / SLAM / Navigation
   - 強化學習 / 模擬器 (Isaac Sim)
   - 點雲 / 3D 感測 / 電腦視覺
   - Flutter / 行動應用開發
   - 量化交易 / 金融科技
   - DevOps / 基礎設施 / Docker

3) 針對「適合度 >= 60/100」的專案，為每個撰寫 2-3 句中文介紹，說明：
   - 這個專案做什麼
   - 為什麼值得關注（技術亮點 / star 增長 / 社群活躍度）
   - 對我們的 OpenClaw / 機器人研究 / 量化交易有什麼具體用途

4) 在報告末尾加上「本週行動建議」：
   - 哪些專案建議立即試用？為什麼？
   - 哪些專案值得持續觀察？
   - 有沒有可以直接整合進 OpenClaw 的 MCP server 或 skill？

輸出格式：
📊 **GitHub 週報 — [日期]**

## 本週精選
[按分類列出，每個專案 2-3 句介紹]

## 趨勢觀察
[整體趨勢摘要：哪個領域最活躍、有沒有新興方向]

## 追蹤專案狀態
[追蹤清單的 star 增長與近期動態]

## 本週行動建議
[具體建議，附理由]

硬性規則：
- 繁體中文輸出
- 不輸出任何 API key 或 token
- 不推薦已 archived 的專案
- 若 GitHub API 限流，回報限流狀態並輸出已快取的資料
```

---

## 方案 B：每日快速掃描（建議 Main 或 Alex 使用）

**排程：** 每天 08:00 (cron: `0 8 * * *`)
**Agent：** main
**Session：** isolated
**Delivery：** discord channel

```
你是 Main Agent，執行每日 GitHub 趨勢快掃。

步驟：
1) 執行趨勢掃描：
   python3 ~/.clawdbot/skills/github-monitor/github_monitor.py trending --days 3 --limit 8 --format table

2) 執行追蹤專案檢查：
   python3 ~/.clawdbot/skills/github-monitor/github_monitor.py track --format table

3) 快速整理輸出，只列出「值得注意」的項目（適合度 >= 50 或 star 增長顯著）。

4) 若發現任何專案符合以下條件，標記為「🔥 緊急關注」：
   - 3 天內 star 增長 > 500
   - 是新的 MCP server 且可直接用於 Claude/OpenClaw
   - 與 Isaac Sim / ROS 2 / 量化交易直接相關的新框架

輸出格式：
📡 **GitHub 日報 — [日期]**
[趨勢表格]
[追蹤狀態表格]
[若有🔥標記項目，額外說明]

硬性規則：
- 精簡輸出，不超過 20 行
- 繁體中文
- 若無特別發現，回報「今日無特別趨勢變化」即可
```

---

## 方案 C：特定領域深度搜尋（Alex 按需執行）

**觸發：** 手動或由 Kevin 指派
**Agent：** alex

```
你是 Alex，執行 GitHub 深度搜尋任務。

目標領域：[由指派者填入，例如：「新的 ROS 2 SLAM 演算法」]

步驟：
1) 搜尋：
   python3 ~/.clawdbot/skills/github-monitor/github_monitor.py search --query "[目標關鍵字]" --limit 15 --format json

2) 對搜尋結果中 star > 50 的專案，逐一分析：
   python3 ~/.clawdbot/skills/github-monitor/github_monitor.py analyze --repo "owner/repo"

3) 產出技術評估報告：
   - 專案架構概述（語言、依賴、License）
   - 程式碼品質初判（最後 commit 時間、issue 處理速度、CI 狀態）
   - 與我們環境的相容性（Python 3.10、CUDA、Docker、ROS 2）
   - 整合難度評估（1-5 分）
   - 建議：直接用 / 需修改 / 僅參考 / 不推薦

輸出格式：
🔍 **深度搜尋報告 — [領域] — [日期]**

### 搜尋結果摘要
[表格]

### 詳細評估
[每個值得分析的專案一個段落]

### 結論與建議
[最終推薦清單，按優先順序排列]
```

---

## 如何加入 OpenClaw Cron

使用 OpenClaw CLI 或直接編輯 `~/.clawdbot/cron/jobs.json`：

```json
{
  "id": "github-weekly-report",
  "agentId": "commander",
  "name": "GitHub 週報",
  "enabled": true,
  "schedule": {
    "kind": "cron",
    "expr": "0 9 * * 1",
    "tz": "Asia/Taipei"
  },
  "sessionTarget": "isolated",
  "wakeMode": "next-heartbeat",
  "payload": {
    "kind": "agentTurn",
    "timeoutSeconds": 600,
    "message": "... (貼入方案 A 的 prompt) ..."
  },
  "delivery": {
    "mode": "announce",
    "channel": "discord",
    "to": "channel:YOUR_CHANNEL_ID"
  }
}
```
