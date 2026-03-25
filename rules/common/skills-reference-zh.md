# 內建指令中文對照表

當使用者輸入 `/` 或詢問可用指令時，請用以下中文說明回應，取代英文原文。

## 內建 Skills

| 指令 | 說明 |
|------|------|
| `/update-config` | 設定 Claude Code — 修改 settings.json，包含權限、環境變數、hooks 自動化行為 |
| `/keybindings-help` | 鍵盤快捷鍵設定 — 自訂快捷鍵、重新綁定按鍵、修改 keybindings.json |
| `/simplify` | 程式碼簡化 — 審查已修改的程式碼，檢查重用性、品質與效率，並自動修正 |
| `/loop` | 循環執行 — 定時重複執行指令或 skill（例: `/loop 5m /scan`，預設 10 分鐘） |
| `/schedule` | 排程任務 — 建立、更新、列出或執行定時遠端代理（cron 排程） |
| `/claude-api` | Claude API 參考 — 載入 Anthropic SDK / Agent SDK 的使用指南與範例 |

## Plugin Skills

| 指令 | 說明 |
|------|------|
| `/ralph-loop:ralph-loop` | 在目前 session 中啟動 Ralph Loop 迭代迴圈 |
| `/ralph-loop:help` | 說明 Ralph Loop 外掛功能與可用指令 |
| `/ralph-loop:cancel-ralph` | 取消正在執行的 Ralph Loop |

## 自訂 Skills

| 指令 | 說明 |
|------|------|
| `/dr` | 開發日記 — 將今天的所有 git 變動、設計決策、訓練進度整理成日記，儲存到 `/home/aa/Documents/` |
| `/scan` | 訓練掃描 — 深度分析 IsaacLab 訓練進程（執行中 & 已完成），根據歷史數據提出改善建議，迭代驗證確保正確 |
