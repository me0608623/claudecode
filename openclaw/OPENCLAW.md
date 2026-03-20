# OpenClaw 配置說明

> OpenClaw 是獨立於 Claude Code 的多代理平台，此處僅記錄與 Claude Code 交互的部分。

## 與 Claude Code 相關的設定

### GitHub Monitor Skill
位於 `~/.clawdbot/skills/github-monitor/`，Claude Code 和 OpenClaw 共用。

```bash
# 複製 skill 到 OpenClaw
cp -r skills/github-monitor ~/.clawdbot/skills/

# 為 alex agent 建立 symlink
ln -sf ~/.clawdbot/skills/github-monitor ~/.clawdbot/agents/alex/skills/github-monitor
```

### Plugin List
`plugin_list.json` 定義了 3 個 GitHub 監控插件（mcp-github-explorer、browser-use-connector、trend-analyzer）。

```bash
cp openclaw/plugin_list.json ~/.clawdbot/skills/
```

## OpenClaw 安裝（如需要）

```bash
npm install -g openclaw@latest
openclaw doctor --fix
```
