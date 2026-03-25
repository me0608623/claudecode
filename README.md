# Claude Code 完整環境配置

> 跨機器快速還原 Claude Code 開發環境 — 含 Director Mode、全域 Rules、專案 Skills。
>
> 最後更新：2026-03-25

## 快速安裝

```bash
git clone git@github.com:me0608623/claudecode.git
cd claudecode
chmod +x install.sh

# 完整安裝（全域配置 + Director Mode + Rules + Plugins）
./install.sh --all

# 只安裝 Director Mode 到指定專案
./install.sh --director-mode /path/to/project

# 只安裝全域 Rules
./install.sh --rules

# 只安裝 Plugins
./install.sh --plugins
```

## 目錄結構

```
claudecode/
├── README.md                          # 本文件
├── install.sh                         # 安裝腳本
├── INVENTORY.md                       # 完整元件清單
│
├── configs/                           # ~/.claude/ 全域配置
│   ├── settings.json                  # 主設定（plugins、permissions）
│   ├── settings.local.json            # 本地權限白名單
│   ├── settings.claude.json           # Claude 模型偏好
│   ├── settings.local.director-mode.json  # Director Mode hooks 設定範本
│   └── CLAUDE.md                      # 全域系統指令
│
├── rules/                             # ~/.claude/rules/ 全域開發規範
│   ├── common/                        # 通用規範（9 個文件）
│   │   ├── coding-style.md            #   程式碼風格
│   │   ├── git-workflow.md            #   Git 工作流程
│   │   ├── testing.md                 #   測試要求
│   │   ├── performance.md             #   效能優化
│   │   ├── patterns.md                #   設計模式
│   │   ├── hooks.md                   #   Hooks 系統
│   │   ├── agents.md                  #   Agent 協作
│   │   ├── security.md                #   安全規範
│   │   └── skills-reference-zh.md     #   指令中文對照表
│   ├── python/                        # Python 規範
│   ├── typescript/                    # TypeScript 規範
│   └── golang/                        # Go 規範
│
├── director-mode/                     # Director Mode Lite 組件
│   ├── skills/     (31 個)            #   Slash 指令（中文描述）
│   ├── agents/     (14 個)            #   專家 Agents
│   └── hooks/      (5 個)             #   自動化 Hooks
│
├── project-skills/                    # 專案特定 Skills（範本）
│   └── charge/                        #   Charge 導航機器人專案
│       ├── charge-context.md          #     專案上下文
│       ├── charge-debug.md            #     除錯指南
│       ├── charge-obs.md              #     觀測空間
│       ├── charge-reward.md           #     獎勵函數
│       └── instructions.md            #     .claude/instructions.md 範本
│
├── statusline/                        # 狀態列腳本
├── mcp-servers/                       # MCP Server 配置
├── skills/                            # 其他自訂 Skills
│   └── github-monitor/               #   GitHub 趨勢追蹤
├── plugins/                           # Plugin 安裝說明
└── openclaw/                          # OpenClaw 配置
```

## 安裝選項

| 選項 | 說明 | 安裝位置 |
|------|------|---------|
| `--all` | 全部安裝 | `~/.claude/` + 目前目錄 |
| `--configs` | 核心配置檔 | `~/.claude/` |
| `--rules` | 全域開發規範 | `~/.claude/rules/` |
| `--director-mode [DIR]` | Director Mode 組件 | `DIR/.claude/` |
| `--plugins` | Marketplace plugins | Claude CLI |
| `--statusline` | 繁中狀態列 | `~/.claude/` |
| `--charge [DIR]` | Charge 專案 skills | `DIR/.claude/` |

## Director Mode 功能一覽

### Skills（31 個指令，中文描述）

| 分類 | 指令 |
|------|------|
| 開發流程 | `/workflow` `/auto-loop` `/test-first` `/smart-commit` `/plan` |
| 分析除錯 | `/focus-problem` `/debugger` `/code-reviewer` |
| 文件產出 | `/doc-writer` `/changelog` |
| 環境檢查 | `/check-environment` `/project-health-check` `/project-init` |
| 驗證工具 | `/claude-md-check` `/agent-check` `/skill-check` `/hooks-check` `/mcp-check` |
| 範本產生 | `/agent-template` `/skill-template` `/hook-template` `/claude-md-template` |
| 進階功能 | `/evolving-loop` `/evolving-status` `/handoff-codex` `/handoff-gemini` `/interop-router` |
| 資訊查詢 | `/agents` `/skills` `/getting-started` |

### Agents（14 個專家）

| Agent | 用途 |
|-------|------|
| code-reviewer | 程式碼審查 |
| debugger | 除錯專家 |
| doc-writer | 文件撰寫 |
| requirement-analyzer | 需求分析 |
| completion-judge | 完成度判斷 |
| skill-synthesizer | 技能合成 |
| skill-evolver | 技能進化 |
| experience-extractor | 經驗提取 |
| evolving-orchestrator | 進化協調 |
| agents-expert | Agent 設計 |
| skills-expert | Skill 設計 |
| hooks-expert | Hook 設計 |
| claude-md-expert | CLAUDE.md 設計 |
| mcp-expert | MCP 配置 |

### Hooks（5 個自動化）

| Hook | 觸發時機 | 功能 |
|------|---------|------|
| auto-loop-stop.sh | Stop | Auto-loop 狀態檢查 |
| log-file-change.sh | PostToolUse (Write/Edit) | 檔案變更日誌 |
| log-bash-event.sh | PostToolUse (Bash) | Bash 事件日誌 |
| pre-tool-validator.sh | PreToolUse (Write/Edit) | 寫入前驗證 |
| _lib-changelog.sh | （共用函式庫） | Changelog 工具函式 |

## 環境需求

- Linux (Ubuntu 22.04+) 或 macOS
- Node.js >= 22
- Python >= 3.10
- Claude Code CLI (`npm install -g @anthropic-ai/claude-code`)
- jq（hooks 需要）
- Anthropic Pro/Team 訂閱

## 在另一台電腦上安裝

```bash
# 1. Clone
git clone git@github.com:me0608623/claudecode.git
cd claudecode

# 2. 安裝全域配置 + rules
./install.sh --configs
./install.sh --rules

# 3. 到你的專案目錄，安裝 Director Mode
cd /path/to/your/project
/path/to/claudecode/install.sh --director-mode .

# 4. （可選）安裝 plugins
/path/to/claudecode/install.sh --plugins

# 5. 重啟 Claude Code
claude
```

## 各檔案詳細說明

詳見 [INVENTORY.md](INVENTORY.md)
