# Claude Code Skills 完整說明文件

> 本文件整理 Claude Code 目前所有可用的 Skills（技能），包含內建 Skills 與自訂 Skills 的詳細說明。

---

## 目錄

- [使用方式](#使用方式)
- [內建 Skills](#內建-skills)
  - [update-config](#update-config)
  - [keybindings-help](#keybindings-help)
  - [simplify](#simplify)
  - [loop](#loop)
  - [schedule](#schedule)
  - [claude-api](#claude-api)
- [Plugin Skills — Ralph Loop](#plugin-skills--ralph-loop)
  - [ralph-loop:ralph-loop](#ralph-loopralph-loop)
  - [ralph-loop:cancel-ralph](#ralph-loopcancel-ralph)
  - [ralph-loop:help](#ralph-loophelp)
- [Plugin Skills — Obsidian](#plugin-skills--obsidian)
  - [obsidian:defuddle](#obsidiandefuddle)
  - [obsidian:json-canvas](#obsidianjson-canvas)
  - [obsidian:obsidian-bases](#obsidianobsidian-bases)
  - [obsidian:obsidian-cli](#obsidianobsidian-cli)
  - [obsidian:obsidian-markdown](#obsidianobsidian-markdown)
- [自訂 Skills](#自訂-skills)
  - [dr — 開發日記](#dr--開發日記)
  - [push — 實驗版本同步](#push--實驗版本同步)
  - [scan — 訓練進程掃描](#scan--訓練進程掃描)

---

## 使用方式

在 Claude Code 對話中，輸入 `/skill名稱` 即可觸發對應技能。例如：

```
/dr
/scan
/push
/loop 5m /scan
```

Claude 會自動辨識 slash command 並執行對應的 Skill。

---

## 內建 Skills

### update-config

**觸發：** `/update-config`

**用途：** 設定 Claude Code 的 `settings.json`，包含：

- 自動化行為（hooks）：「每次做 X 之前/之後執行 Y」
- 工具權限管理：允許或限制特定指令
- 環境變數設定
- Hook 問題排除

**適用情境：**
- 「每次 Claude 停止時顯示 X」
- 「允許 npm 指令」
- 「設定 DEBUG=true」
- 「將某權限移到 user settings」

> **注意：** 自動化行為需要 hooks 設定才能生效，無法只靠 memory/preferences 達成。

---

### keybindings-help

**觸發：** `/keybindings-help`

**用途：** 自訂鍵盤快捷鍵，修改 `~/.claude/keybindings.json`。

**適用情境：**
- 重新綁定 `ctrl+s`
- 新增 chord 快捷鍵
- 修改送出鍵
- 任何鍵盤快捷鍵自訂需求

---

### simplify

**觸發：** `/simplify`

**用途：** 審查已修改的程式碼，檢查重用性、品質與效率，並自動修正發現的問題。

**適用情境：**
- 寫完一段新功能後想做 code review
- 重構後確認程式碼品質
- 找出多餘或可複用的邏輯

---

### loop

**觸發：** `/loop [間隔] [指令]`

**用途：** 在固定時間間隔內重複執行某個 prompt 或 slash command。

**語法範例：**
```
/loop 5m /scan          # 每 5 分鐘執行一次 /scan
/loop 10m /dr           # 每 10 分鐘執行一次 /dr（預設間隔為 10 分鐘）
/loop 1h /simplify      # 每小時執行一次 /simplify
```

**適用情境：**
- 定期監控訓練進度
- 持續輪詢某個狀態
- 定時執行重複性任務

> **注意：** 僅用於需要周期性重複的任務，單次任務請直接執行。

---

### schedule

**觸發：** `/schedule`

**用途：** 建立、更新、列出或執行定時遠端代理（Remote Triggers），使用 cron 排程格式。

**功能：**
- 建立新的排程任務
- 更新現有排程
- 列出所有排程
- 手動觸發排程執行

**適用情境：**
- 設定每天早上自動產生 DR
- 建立定時掃描訓練的 cron job
- 管理自動化排程代理

---

### claude-api

**觸發：** `/claude-api`

**用途：** 載入 Anthropic SDK / Claude Agent SDK 的使用指南與範例程式碼，幫助開發基於 Claude API 的應用程式。

**自動觸發條件：**
- 程式碼中 import `anthropic`
- 程式碼中 import `@anthropic-ai/sdk`
- 程式碼中 import `claude_agent_sdk`
- 使用者詢問如何使用 Claude API 或 Anthropic SDK

> **注意：** 若程式碼使用 `openai` 或其他 AI SDK，不應觸發此 skill。

---

## Plugin Skills — Ralph Loop

### ralph-loop:ralph-loop

**觸發：** `/ralph-loop:ralph-loop`

**用途：** 在目前 session 中啟動 Ralph Loop 迭代迴圈。

**說明：** Ralph Loop 是一個迭代式的工作流程工具，適合需要多輪反覆修改與驗證的任務。

---

### ralph-loop:cancel-ralph

**觸發：** `/ralph-loop:cancel-ralph`

**用途：** 取消正在執行中的 Ralph Loop。

**適用情境：** 當 Ralph Loop 執行中需要中斷時使用。

---

### ralph-loop:help

**觸發：** `/ralph-loop:help`

**用途：** 顯示 Ralph Loop 外掛的完整功能說明與所有可用指令。

---

## Plugin Skills — Obsidian

### obsidian:defuddle

**觸發：** `/obsidian:defuddle` 或提供 URL 時自動觸發

**用途：** 使用 Defuddle CLI 從網頁中提取乾淨的 Markdown 內容，移除導覽列、廣告等雜訊。

**優點：** 比 WebFetch 更節省 token，適合讀取線上文章或文件。

**適用情境：**
- 使用者提供 URL 想要讀取或分析
- 線上文件、部落格文章、技術說明頁面

---

### obsidian:json-canvas

**觸發：** `/obsidian:json-canvas`

**用途：** 建立和編輯 JSON Canvas 檔案（`.canvas`），支援節點、邊、群組和連接。

**適用情境：**
- 處理 `.canvas` 檔案
- 建立視覺化 canvas、心智圖、流程圖
- 使用者提到 Obsidian 的 Canvas 功能

---

### obsidian:obsidian-bases

**觸發：** `/obsidian:obsidian-bases`

**用途：** 建立和編輯 Obsidian Bases（`.base` 檔案），支援視圖、篩選器、公式和摘要。

**適用情境：**
- 處理 `.base` 檔案
- 建立類似資料庫的筆記視圖
- 使用者提到 Bases、表格視圖、卡片視圖、篩選器或公式

---

### obsidian:obsidian-cli

**觸發：** `/obsidian:obsidian-cli`

**用途：** 使用 Obsidian CLI 與 Obsidian vault 互動，支援讀取、建立、搜尋和管理筆記。

**功能：**
- 筆記的 CRUD 操作
- 任務管理
- 屬性（Properties）管理
- 外掛和主題開發（重載外掛、執行 JavaScript、捕獲錯誤、截圖、DOM 檢查）

**適用情境：**
- 從命令列管理 Obsidian vault
- 搜尋 vault 內容
- 開發和除錯 Obsidian 外掛

---

### obsidian:obsidian-markdown

**觸發：** `/obsidian:obsidian-markdown`

**用途：** 建立和編輯 Obsidian Flavored Markdown，支援 Obsidian 特有語法。

**支援語法：**
- Wikilinks（`[[連結]]`）
- 嵌入（`![[嵌入]]`）
- Callouts（`> [!note]`）
- Properties（YAML frontmatter）
- 標籤（`#標籤`）

**適用情境：**
- 在 Obsidian 中建立或編輯 `.md` 檔案
- 使用者提到 wikilinks、callouts、frontmatter、嵌入等 Obsidian 特有功能

---

## 自訂 Skills

### dr — 開發日記

**觸發：** `/dr`

**用途：** 產生今天的開發日記，整合 git 變動、設計決策、CLI 版本演進、訓練進度與分析，儲存到 `/home/aa/Documents/dr/`。

**執行流程：**

1. **讀取前次 DR** — 找到最近的日記檔案，了解上次訓練到哪裡、上次的設計決策與待處理事項
2. **收集今日 git 資訊** — 今日 commits、變動檔案、目前 branch 狀態
3. **收集訓練進度** — 目前執行中的訓練程序、GPU 狀態、各 run 的關鍵指標
4. **整理成日記格式** — 包含延續上次的脈絡
5. **儲存檔案** — 寫入 `/home/aa/Documents/dr/dev-diary-YYYY-MM-DD.md`

**日記內容包含：**
- 今日摘要（延續前次）
- Commits 記錄
- 變動檔案（按模組分組）
- 設計決策與筆記（重要的 why，不只是 what）
- CLI 版本演進表（`reward_mode`、`curriculum_version`、`dynamic_safety_mode` 等）
- 訓練進度（當前版本、執行中 runs、版本間比較）
- 歷史 Runs 摘要表
- 未完成 / 待處理事項
- GPU / 系統資源狀態

**CLI 版本追蹤（IsaacLab 訓練專用）：**

| Flag | 追蹤對象 |
|------|---------|
| `reward_mode` | v1 ~ v5，各版本獎勵函數設計 |
| `curriculum_version` | baseline_v1, goal_first_v1~v3 |
| `dynamic_safety_mode` | log_distance / closing_risk |
| 其他 flags | `--no_walls`, `--use_cadn`, `--use_safety_shield` 等 |

---

### push — 實驗版本同步

**觸發：** `/push`

**用途：** 將 5090 上的訓練相關程式碼整理成乾淨 branch，push 到 origin，並產出 5070 同步摘要。

**執行流程：**

1. **確認 runtime repo** — 確認當前 branch、未提交修改、HEAD 狀態
2. **建立本輪實驗檔案清單** — 區分必須納入 vs 應排除的檔案
3. **建立新 branch** — 格式 `exp/<核心設定簡述>`
4. **Commit 前 diff 摘要** — 每個檔案的改動摘要與實驗關係
5. **Commit** — 包含完整訓練指令的 commit message
6. **Push** — 推送到 remote
7. **產出同步摘要** — 寫入 `SYNC_TO_5070.md`
8. **輸出 5070 快速同步指令** — TARGET_BRANCH、TARGET_COMMIT、EXACT_TRAINING_COMMAND

**Branch 命名格式：**
```
exp/<核心設定簡述>
# 例：exp/v6-openended-nowalls-6144-baseline
```

**Commit Message 格式：**
```
exp: <本輪實驗摘要>

Reward: <版本>
Curriculum: <版本>
Key changes:
- <變更1>
- <變更2>

For 5070 sync — run with:
<完整訓練指令>
```

**必定排除的檔案：**
- `logs/`、`wandb/`、`checkpoints/` — 訓練輸出
- `*.pt`、`*.zip` — 大型二進位檔
- `__pycache__/` — Python 快取
- `.claude/` — Claude Code 設定
- `TRAINING_SNAPSHOT_*.md`、`REPRO_*.md` — 本機快照

---

### scan — 訓練進程掃描

**觸發：** `/scan`

**用途：** 對 IsaacLab Charge 導航專案進行全面訓練掃描：偵測執行中/已完成的 runs，分析指標趨勢，比對歷史數據，提出具體改善建議。

**執行流程（5 輪迭代）：**

#### 第一輪：資料收集
- 系統狀態：執行中的訓練程序、GPU 使用率
- 掃描 `/home/aa/IsaacLab/logs/skrl/` 目錄
- 讀取活躍 run 的詳細資料（`command.txt`、`params/agent.yaml`、`debug_metrics.csv`）

#### 第二輪：指標分析（第一次迭代）

分析四大面向：

| 面向 | 關鍵指標 |
|------|---------|
| **課程進度** | `stage`, `success_rate`, `collision_rate`, `timeout_rate` |
| **獎勵趨勢** | `total_reward`, `velocity_to_goal`, `collision_penalty` 等 |
| **行為診斷** | `freeze_ratio`, `oscillation_score`, `retreat_ratio`, `stuck_count` |
| **訓練穩定性** | `policy_loss`, `value_loss`, `entropy`, `grad_norm`, `fps` |

#### 第三輪：歷史比較（第二次迭代）
- 與同類型歷史 runs 比較相同 step 數的指標
- 消融實驗對照（同 family 不同 variant）
- 回顧修正第二輪結論

#### 第四輪：交叉驗證（第三次迭代）
- 驗證每個結論的因果推論（至少 2 個指標支持）
- 時間一致性確認
- 按影響程度分類問題優先級

#### 第五輪：輸出報告

```
🔴 CRITICAL — 訓練可能失敗或嚴重浪費資源
🟡 WARNING  — 效率不佳但仍在進步
🟢 INFO     — 觀察到的趨勢，不需立即處理
```

報告輸出格式包含：
- 掃描範圍（活躍 runs 數、分析迭代次數）
- 每個 run 的狀態（step、課程階段、持續時間）
- 關鍵指標（最近 10 epoch 平均）
- 各優先級問題與建議
- 超參數調整建議
- 與歷史最佳 Run 比較

**debug_metrics.csv 欄位分組（103 欄）：**

| 群組 | 關鍵欄位 |
|------|---------|
| Curriculum | `stage`, `success_rate`, `collision_rate`, `n_goals`, `n_static`, `n_dynamic` |
| Reward | `total_reward`, `velocity_to_goal`, `safe_progress`, `reaching_goal`, `collision_penalty` |
| Termination | `goal_reached_%`, `collision_%`, `timeout_%` |
| Ablation | `stuck_count`, `freeze_ratio`, `oscillation_score`, `retreat_ratio`, `d_safe_mean` |
| Training | `policy_loss`, `value_loss`, `entropy`, `grad_norm`, `fps` |

---

## 快速參考表

| 指令 | 類別 | 說明 |
|------|------|------|
| `/update-config` | 內建 | 設定 settings.json（hooks、權限、env vars） |
| `/keybindings-help` | 內建 | 自訂鍵盤快捷鍵 |
| `/simplify` | 內建 | 審查並改善已修改的程式碼 |
| `/loop [間隔] [指令]` | 內建 | 定時重複執行指令（預設 10 分鐘） |
| `/schedule` | 內建 | 建立/管理 cron 排程遠端代理 |
| `/claude-api` | 內建 | Anthropic SDK / Claude API 使用指南 |
| `/ralph-loop:ralph-loop` | Plugin | 啟動 Ralph Loop 迭代迴圈 |
| `/ralph-loop:cancel-ralph` | Plugin | 取消 Ralph Loop |
| `/ralph-loop:help` | Plugin | Ralph Loop 說明 |
| `/obsidian:defuddle` | Plugin | 從網頁提取乾淨 Markdown |
| `/obsidian:json-canvas` | Plugin | 建立/編輯 Canvas 檔案 |
| `/obsidian:obsidian-bases` | Plugin | 建立/編輯 Obsidian Bases |
| `/obsidian:obsidian-cli` | Plugin | 操作 Obsidian vault |
| `/obsidian:obsidian-markdown` | Plugin | 建立/編輯 Obsidian Markdown |
| `/dr` | 自訂 | 產生開發日記，儲存到 `/home/aa/Documents/dr/` |
| `/push` | 自訂 | 整理實驗 code，建 branch 並 push，產出 5070 同步摘要 |
| `/scan` | 自訂 | 深度掃描 IsaacLab 訓練進程，提出改善建議 |

---

*文件生成日期：2026-03-27*
