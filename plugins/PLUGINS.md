# Claude Code Plugins 安裝指南

## 一鍵安裝所有 plugins

```bash
# 1. 先新增自訂 marketplace
claude plugins marketplace add claude-code-skills --source github --repo alirezarezvani/claude-skills

# 2. 安裝官方 marketplace plugins
claude plugins install frontend-design@claude-plugins-official
claude plugins install zapier@claude-plugins-official
claude plugins install ralph-loop@claude-plugins-official

# 3. 安裝 everything-claude-code
claude plugins install everything-claude-code@everything-claude-code

# 4. 安裝 claude-code-skills（12 個 skill bundles）
claude plugins install engineering-skills@claude-code-skills
claude plugins install engineering-advanced-skills@claude-code-skills
claude plugins install product-skills@claude-code-skills
claude plugins install marketing-skills@claude-code-skills
claude plugins install ra-qm-skills@claude-code-skills
claude plugins install pm-skills@claude-code-skills
claude plugins install c-level-skills@claude-code-skills
claude plugins install business-growth-skills@claude-code-skills
claude plugins install finance-skills@claude-code-skills
claude plugins install skill-security-auditor@claude-code-skills
claude plugins install self-improving-agent@claude-code-skills
claude plugins install content-creator@claude-code-skills
```

## 啟用 plugins（settings.json 中）

安裝後需在 `~/.claude/settings.json` 中啟用：

```json
{
  "enabledPlugins": {
    "engineering-skills@claude-code-skills": true,
    "engineering-advanced-skills@claude-code-skills": true,
    "product-skills@claude-code-skills": true,
    "marketing-skills@claude-code-skills": true,
    "ra-qm-skills@claude-code-skills": true,
    "pm-skills@claude-code-skills": true,
    "c-level-skills@claude-code-skills": true,
    "business-growth-skills@claude-code-skills": true,
    "finance-skills@claude-code-skills": true,
    "skill-security-auditor@claude-code-skills": true,
    "self-improving-agent@claude-code-skills": true,
    "content-creator@claude-code-skills": true
  }
}
```

---

## Plugins 詳細說明

### 官方 Plugins

| Plugin | 說明 |
|--------|------|
| **frontend-design** | 前端 UI 設計輔助，幫助生成 UI 組件和佈局 |
| **zapier** | 與 Zapier 整合，可觸發自動化工作流 |
| **ralph-loop** | `/loop` 命令：定時執行 prompt（如每 5 分鐘 /foo） |

### Everything Claude Code (v1.8.0)

多語言 coding rules 集合，提供各種程式語言的最佳實踐規則。

來源：[affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code)

### Claude Code Skills (v2.1.2)

大型 skill 集合，12 個 bundle 共涵蓋 100+ 個獨立技能。

來源：[alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills)

| Bundle | 技能數 | 重點功能 |
|--------|--------|---------|
| engineering-skills | 23 | 架構、前後端、QA、DevOps、安全、AI/ML、Playwright、Stripe、AWS |
| engineering-advanced-skills | 25 | Agent 設計、RAG、MCP servers、CI/CD、DB 設計、可觀測性 |
| product-skills | 10 | PM (RICE)、Agile PO、UX 研究、UI 設計系統、競品分析 |
| marketing-skills | 42 | 內容、SEO、CRO、社群、成長、情報、銷售 |
| ra-qm-skills | 12 | ISO 13485、MDR、FDA 510(k)、ISO 27001、GDPR |
| pm-skills | 6 | Scrum Master、Jira (JQL)、Confluence、Atlassian Admin |
| c-level-skills | 10 | CEO/CTO/COO/CPO/CMO/CFO/CRO/CISO/CHRO + Mentor |
| business-growth-skills | 4 | 客戶成功、銷售工程、收入運營、合約撰寫 |
| finance-skills | 1 | 比率分析、DCF 估值、預算差異、滾動預測 |
| skill-security-auditor | 1 | 安全審計 |
| self-improving-agent | 1 | 自我改進循環（記憶分析、技能萃取） |
| content-creator | 1 | 內容創作 |

---

## 自訂 Learned Skills

這些 skills 需要手動複製到 `~/.agents/skills/`：

```bash
# auto-skill — 任務啟動時自動讀取知識庫
# 需另外取得，此 skill 包含用戶偏好等個人化設定

# find-skills — 技能發現機制
# 通常隨 auto-skill 一起安裝

# vercel-composition-patterns — React 19 組合模式
# 前端開發時自動觸發
```

---

## CLI-Anything Plugin

自訂 CLI 命令擴展框架，已安裝在 `~/.claude/plugins/cli-anything/`。

功能：test、refine、list、validate 等命令。
