# Claude Code 配置備份與快速安裝指南

> 任的 Claude Code 完整環境配置，可在新電腦上快速還原。
>
> 最後更新：2026-03-21

## 快速開始

```bash
# 1. Clone 此 repo
git clone git@github.com:me0608623/claudecode.git
cd claudecode

# 2. 執行安裝腳本
chmod +x install.sh
./install.sh
```

## 目錄結構

```
claudecode/
├── README.md                    # 本文件
├── install.sh                   # 一鍵安裝腳本
├── configs/                     # Claude Code 配置檔
│   ├── settings.json            # 主設定（plugins、permissions）
│   ├── settings.local.json      # 本地權限白名單
│   ├── settings.claude.json     # Claude 模型設定
│   └── CLAUDE.md                # 全域指令
├── statusline/                  # 狀態列
│   └── statusline-command.sh    # 繁中狀態列腳本
├── mcp-servers/                 # MCP Server 配置
│   └── mcp-servers.json         # MCP server 定義（需調整路徑）
├── skills/                      # 自訂技能
│   └── github-monitor/          # GitHub 趨勢追蹤 skill
│       ├── SKILL.md
│       └── github_monitor.py
├── plugins/                     # 插件資訊
│   └── PLUGINS.md               # 已安裝插件清單與安裝指令
└── openclaw/                    # OpenClaw 相關配置
    ├── plugin_list.json         # GitHub 監控插件定義
    └── OPENCLAW.md              # OpenClaw 設定說明
```

## 環境需求

- Linux (Ubuntu 22.04+ / WSL2) 或 macOS
- Node.js >= 22
- Python >= 3.10
- Claude Code CLI (`npm install -g @anthropic-ai/claude-code`)
- Anthropic Pro/Team 訂閱

## 各檔案說明

詳見 [INVENTORY.md](INVENTORY.md)
