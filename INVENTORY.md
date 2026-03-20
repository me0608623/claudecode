# Claude Code 完整配置清單

> 盤點日期：2026-03-21

---

## 1. 核心配置檔案

| 檔案 | 安裝位置 | 用途 |
|------|---------|------|
| `settings.json` | `~/.claude/settings.json` | 主設定：啟用 12 個 skill plugins、plugin marketplace、bypassPermissions |
| `settings.local.json` | `~/.claude/settings.local.json` | 本地權限白名單：60+ bash 命令 |
| `settings.claude.json` | `~/.claude/settings.claude.json` | Claude 模型偏好：預設 opus |
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | 全域系統指令：繁中、Action Mode、ROS2/Isaac 專用規則 |
| `statusline-command.sh` | `~/.claude/statusline-command.sh` | 繁中狀態列：目錄、git 分支、模型、脈絡%、速率限制、vim 模式 |

---

## 2. MCP Servers（2 個）

### isaac-sim（NVIDIA 官方 MCP）
- **類型：** stdio
- **啟動：** `uv run --directory /path/to/nvidia-isaac-mcp nvidia-isaac-mcp`
- **工具數：** 16 個（create_prim, spawn_robot, simulation_control 等）
- **安裝：**
  ```bash
  git clone https://github.com/NVIDIA-Omniverse/IsaacSim-MCP.git nvidia-isaac-mcp
  cd nvidia-isaac-mcp && pip install -e .
  ```
- **需求：** Isaac Sim running on port 9876

### isaacsim-mcp（VSCode 擴展版）
- **類型：** stdio
- **啟動：** `/path/to/isaacsim-mcp-venv/bin/isaac-mcp-server`
- **工具數：** 3 個（check_connection, execute_code, get_errors）
- **安裝：**
  ```bash
  python -m venv isaacsim-mcp-venv
  source isaacsim-mcp-venv/bin/activate
  pip install isaacsim-mcp
  ```
- **需求：** Isaac Sim running on port 8226

---

## 3. 已安裝 Plugins（marketplace）

### 官方 Marketplace (claude-plugins-official)
來源：`anthropics/claude-plugins-official`

| Plugin | 版本 | 用途 |
|--------|------|------|
| frontend-design | b664e152af57 | 前端 UI 設計輔助 |
| zapier | 1.0.0 | Zapier 自動化整合 |
| ralph-loop | b664e152af57 | 循環/定期執行 prompt |

### Everything Claude Code
來源：`affaan-m/everything-claude-code` v1.8.0

| Plugin | 用途 |
|--------|------|
| everything-claude-code | 多語言 coding rules 集合 |

### Claude Code Skills（12 個 skill bundles）
來源：`alirezarezvani/claude-skills` v2.1.2

| Skill | 用途 |
|-------|------|
| engineering-skills | 23 個工程技能（架構、前後端、QA、DevOps、安全、AI/ML） |
| engineering-advanced-skills | 25 個進階技能（Agent 設計、RAG、MCP、CI/CD、DB） |
| product-skills | 10 個產品技能（PM、UX、UI、競品分析） |
| marketing-skills | 42 個行銷技能（內容、SEO、CRO、成長） |
| ra-qm-skills | 12 個法規品質技能（ISO、MDR、FDA、GDPR） |
| pm-skills | 6 個專案管理技能（Scrum、Jira、Confluence） |
| c-level-skills | 10 個 C-level 顧問技能（CEO-CHRO） |
| business-growth-skills | 4 個業務成長技能（客戶成功、銷售） |
| finance-skills | 財務分析技能（DCF、預算、預測） |
| skill-security-auditor | 安全審計技能 |
| self-improving-agent | 1.0.0 — 自我改進 agent |
| content-creator | 內容創作技能 |

### CLI-Anything Plugin
位置：`~/.claude/plugins/cli-anything/`
- 自訂 CLI 命令擴展框架

---

## 4. 自訂 Skills（learned skills）

| Skill | 位置 | 用途 |
|-------|------|------|
| auto-skill | `~/.agents/skills/auto-skill/` | 任務啟動時自動讀取知識庫 |
| find-skills | `~/.agents/skills/find-skills/` | 技能發現與安裝 |
| vercel-composition-patterns | `~/.agents/skills/vercel-composition-patterns/` | React 19 組合模式 |
| github-monitor | `~/.clawdbot/skills/github-monitor/` | GitHub 趨勢追蹤（自建） |

---

## 5. 權限模式

- **預設：** `bypassPermissions`（完全信任，不提示確認）
- **白名單命令：** conda、python、flutter、systemctl（user）、openclaw、curl、jq、find、ls、tree 等 60+ 項

---

## 6. Plugin Blocklist

| Plugin | 原因 |
|--------|------|
| code-review@claude-plugins-official | 測試標記 |
| fizz@testmkt-marketplace | 安全測試標記 |

---

## 7. 功能旗標重點

| 功能 | 狀態 |
|------|------|
| MCP tool search | 啟用 |
| Streaming text | 啟用 |
| Code diff CLI | 啟用 |
| Tool result summarization | 啟用 |
| Worktree mode | 啟用 |
| Auto mode | 停用（偏好 Action Mode） |
| Prompt cache 1h | 啟用 |

---

## 8. Git 配置

```ini
[user]
  name = me0608623
  email = me0608623@gmail.com
[url "git@github.com:"]
  insteadOf = https://github.com/
```

gh CLI 已配置 credential helper。
