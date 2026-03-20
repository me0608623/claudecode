#!/usr/bin/env bash
set -euo pipefail

# Claude Code 快速安裝腳本
# 用法: ./install.sh [--all | --configs | --plugins | --mcp | --skills | --statusline]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
CLAWDBOT_DIR="$HOME/.clawdbot"
AGENTS_DIR="$HOME/.agents/skills"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; }
info() { echo -e "${CYAN}[i]${NC} $1"; }

# ─── 前置檢查 ─────────────────────────────────
check_prereqs() {
    info "檢查前置需求..."

    if ! command -v claude &>/dev/null; then
        err "Claude Code CLI 未安裝"
        echo "  安裝指令: npm install -g @anthropic-ai/claude-code"
        echo "  然後執行: claude login"
        exit 1
    fi
    log "Claude Code CLI 已安裝: $(claude --version 2>/dev/null || echo 'unknown')"

    if ! command -v node &>/dev/null; then
        err "Node.js 未安裝"
        exit 1
    fi
    log "Node.js: $(node --version)"

    if ! command -v python3 &>/dev/null; then
        warn "Python3 未安裝（部分功能不可用）"
    else
        log "Python: $(python3 --version)"
    fi
}

# ─── 配置檔安裝 ─────────────────────────────────
install_configs() {
    info "安裝核心配置檔..."
    mkdir -p "$CLAUDE_DIR"

    # settings.json — 合併而非覆蓋
    if [ -f "$CLAUDE_DIR/settings.json" ]; then
        warn "settings.json 已存在，備份為 settings.json.bak"
        cp "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.bak"
    fi
    cp "$SCRIPT_DIR/configs/settings.json" "$CLAUDE_DIR/settings.json"
    log "settings.json"

    if [ -f "$CLAUDE_DIR/settings.local.json" ]; then
        warn "settings.local.json 已存在，備份為 settings.local.json.bak"
        cp "$CLAUDE_DIR/settings.local.json" "$CLAUDE_DIR/settings.local.json.bak"
    fi
    cp "$SCRIPT_DIR/configs/settings.local.json" "$CLAUDE_DIR/settings.local.json"
    log "settings.local.json"

    if [ -f "$CLAUDE_DIR/settings.claude.json" ]; then
        warn "settings.claude.json 已存在，備份"
        cp "$CLAUDE_DIR/settings.claude.json" "$CLAUDE_DIR/settings.claude.json.bak"
    fi
    cp "$SCRIPT_DIR/configs/settings.claude.json" "$CLAUDE_DIR/settings.claude.json"
    log "settings.claude.json"

    # CLAUDE.md
    if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
        warn "CLAUDE.md 已存在，備份"
        cp "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.bak"
    fi
    cp "$SCRIPT_DIR/configs/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    log "CLAUDE.md"

    log "核心配置安裝完成"
}

# ─── 狀態列安裝 ─────────────────────────────────
install_statusline() {
    info "安裝狀態列..."
    cp "$SCRIPT_DIR/statusline/statusline-command.sh" "$CLAUDE_DIR/statusline-command.sh"
    chmod +x "$CLAUDE_DIR/statusline-command.sh"
    log "statusline-command.sh"
}

# ─── Plugins 安裝 ─────────────────────────────────
install_plugins() {
    info "安裝 plugins..."

    # 新增自訂 marketplace
    info "新增 claude-code-skills marketplace..."
    claude plugins marketplace add claude-code-skills --source github --repo alirezarezvani/claude-skills 2>/dev/null || warn "marketplace 可能已存在"

    # 官方 plugins
    for plugin in frontend-design zapier ralph-loop; do
        info "安裝 $plugin..."
        claude plugins install "${plugin}@claude-plugins-official" 2>/dev/null || warn "$plugin 安裝失敗（可能已存在）"
    done

    # everything-claude-code
    info "安裝 everything-claude-code..."
    claude plugins install everything-claude-code@everything-claude-code 2>/dev/null || warn "可能已存在"

    # claude-code-skills bundles
    SKILLS=(
        engineering-skills
        engineering-advanced-skills
        product-skills
        marketing-skills
        ra-qm-skills
        pm-skills
        c-level-skills
        business-growth-skills
        finance-skills
        skill-security-auditor
        self-improving-agent
        content-creator
    )

    for skill in "${SKILLS[@]}"; do
        info "安裝 $skill..."
        claude plugins install "${skill}@claude-code-skills" 2>/dev/null || warn "$skill 安裝失敗（可能已存在）"
    done

    log "所有 plugins 安裝完成"
}

# ─── MCP Servers 配置 ────────────────────────────
install_mcp() {
    info "配置 MCP Servers..."
    echo ""
    warn "MCP Servers 需要手動設定路徑，請參考："
    echo "  mcp-servers/SETUP.md"
    echo ""
    echo "  快速指令："
    echo "    # Isaac Sim MCP (需先 clone 並安裝)"
    echo "    claude mcp add isaac-sim -- uv run --directory ~/nvidia-isaac-mcp nvidia-isaac-mcp"
    echo ""
    echo "    # Isaac Sim MCP (輕量版)"
    echo "    claude mcp add isaacsim-mcp -- ~/isaacsim-mcp-venv/bin/isaac-mcp-server"
    echo ""
}

# ─── Skills 安裝 ─────────────────────────────────
install_skills() {
    info "安裝自訂 skills..."

    # github-monitor
    mkdir -p "$CLAWDBOT_DIR/skills/github-monitor"
    cp "$SCRIPT_DIR/skills/github-monitor/github_monitor.py" "$CLAWDBOT_DIR/skills/github-monitor/"
    cp "$SCRIPT_DIR/skills/github-monitor/SKILL.md" "$CLAWDBOT_DIR/skills/github-monitor/"
    if [ -f "$SCRIPT_DIR/skills/github-monitor/cron_prompt.md" ]; then
        cp "$SCRIPT_DIR/skills/github-monitor/cron_prompt.md" "$CLAWDBOT_DIR/skills/github-monitor/"
    fi
    chmod +x "$CLAWDBOT_DIR/skills/github-monitor/github_monitor.py"
    log "github-monitor skill"

    # OpenClaw plugin list
    if [ -d "$CLAWDBOT_DIR/skills" ]; then
        cp "$SCRIPT_DIR/openclaw/plugin_list.json" "$CLAWDBOT_DIR/skills/"
        log "OpenClaw plugin_list.json"
    fi

    log "自訂 skills 安裝完成"
}

# ─── 主程式 ───────────────────────────────────────
main() {
    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║  Claude Code 配置快速安裝              ║"
    echo "║  github.com/me0608623/claudecode      ║"
    echo "╚══════════════════════════════════════╝"
    echo ""

    MODE="${1:---all}"

    check_prereqs

    case "$MODE" in
        --all)
            install_configs
            install_statusline
            install_plugins
            install_mcp
            install_skills
            ;;
        --configs)    install_configs ;;
        --plugins)    install_plugins ;;
        --mcp)        install_mcp ;;
        --skills)     install_skills ;;
        --statusline) install_statusline ;;
        *)
            echo "用法: $0 [--all | --configs | --plugins | --mcp | --skills | --statusline]"
            exit 1
            ;;
    esac

    echo ""
    log "安裝完成！重啟 Claude Code 以載入新配置。"
    info "詳細說明請參考 INVENTORY.md"
}

main "$@"
