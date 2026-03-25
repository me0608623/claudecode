#!/usr/bin/env bash
set -euo pipefail

# Claude Code 完整環境安裝腳本
# 用法: ./install.sh [--all | --configs | --rules | --director-mode DIR | --plugins | --statusline | --charge DIR]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
CLAWDBOT_DIR="$HOME/.clawdbot"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
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
    log "Claude Code CLI: $(claude --version 2>/dev/null || echo 'unknown')"

    if ! command -v node &>/dev/null; then
        err "Node.js 未安裝"
        exit 1
    fi
    log "Node.js: $(node --version)"

    if ! command -v python3 &>/dev/null; then
        warn "Python3 未安裝（部分功能不可用）"
    else
        log "Python: $(python3 --version 2>&1)"
    fi

    if ! command -v jq &>/dev/null; then
        warn "jq 未安裝（hooks 需要）— sudo apt install jq"
    else
        log "jq: $(jq --version 2>&1)"
    fi
}

# ─── 配置檔安裝 ─────────────────────────────────
install_configs() {
    info "安裝核心配置檔到 ~/.claude/ ..."
    mkdir -p "$CLAUDE_DIR"

    for f in settings.json settings.local.json settings.claude.json CLAUDE.md; do
        if [ -f "$CLAUDE_DIR/$f" ]; then
            warn "$f 已存在，備份為 ${f}.bak"
            cp "$CLAUDE_DIR/$f" "$CLAUDE_DIR/${f}.bak"
        fi
        if [ -f "$SCRIPT_DIR/configs/$f" ]; then
            cp "$SCRIPT_DIR/configs/$f" "$CLAUDE_DIR/$f"
            log "$f"
        fi
    done

    log "核心配置安裝完成"
}

# ─── Rules 安裝 ─────────────────────────────────
install_rules() {
    info "安裝全域 Rules 到 ~/.claude/rules/ ..."
    local RULES_DIR="$CLAUDE_DIR/rules"

    if [ -d "$RULES_DIR" ]; then
        warn "rules/ 已存在，備份為 rules.bak/"
        rm -rf "$RULES_DIR.bak"
        mv "$RULES_DIR" "$RULES_DIR.bak"
    fi

    mkdir -p "$RULES_DIR"
    cp -r "$SCRIPT_DIR/rules/"* "$RULES_DIR/"

    local count
    count=$(find "$RULES_DIR" -name '*.md' -type f | wc -l)
    log "已安裝 $count 個 rule 文件"

    # 列出已安裝的分類
    for d in "$RULES_DIR"/*/; do
        if [ -d "$d" ]; then
            local dname
            dname=$(basename "$d")
            local dcount
            dcount=$(find "$d" -name '*.md' -type f | wc -l)
            echo "    $dname/ ($dcount 個)"
        fi
    done

    log "Rules 安裝完成"
}

# ─── Director Mode 安裝 ─────────────────────────
install_director_mode() {
    local PROJECT_DIR="${1:-.}"
    PROJECT_DIR=$(cd "$PROJECT_DIR" && pwd)
    local TARGET="$PROJECT_DIR/.claude"

    info "安裝 Director Mode 到 $PROJECT_DIR/.claude/ ..."

    # 備份
    if [ -d "$TARGET/skills" ] || [ -d "$TARGET/agents" ] || [ -d "$TARGET/hooks" ]; then
        local backup="$PROJECT_DIR/.claude-backup-$(date +%Y%m%d-%H%M%S)"
        warn "偵測到現有組件，備份到 $backup"
        mkdir -p "$backup"
        [ -d "$TARGET/skills" ] && cp -r "$TARGET/skills" "$backup/"
        [ -d "$TARGET/agents" ] && cp -r "$TARGET/agents" "$backup/"
        [ -d "$TARGET/hooks" ] && cp -r "$TARGET/hooks" "$backup/"
    fi

    # Skills
    mkdir -p "$TARGET/skills"
    local skill_count=0
    for d in "$SCRIPT_DIR/director-mode/skills/"*/; do
        if [ -d "$d" ]; then
            local sname
            sname=$(basename "$d")
            mkdir -p "$TARGET/skills/$sname"
            cp "$d"* "$TARGET/skills/$sname/" 2>/dev/null || true
            skill_count=$((skill_count + 1))
        fi
    done
    log "Skills: $skill_count 個"

    # Agents
    mkdir -p "$TARGET/agents"
    local agent_count=0
    for f in "$SCRIPT_DIR/director-mode/agents/"*.md; do
        if [ -f "$f" ]; then
            cp "$f" "$TARGET/agents/"
            agent_count=$((agent_count + 1))
        fi
    done
    log "Agents: $agent_count 個"

    # Hooks
    mkdir -p "$TARGET/hooks"
    local hook_count=0
    for f in "$SCRIPT_DIR/director-mode/hooks/"*; do
        if [ -f "$f" ]; then
            cp "$f" "$TARGET/hooks/"
            chmod +x "$TARGET/hooks/$(basename "$f")"
            hook_count=$((hook_count + 1))
        fi
    done
    log "Hooks: $hook_count 個"

    # 合併 hooks 設定到 settings.local.json
    local SETTINGS_FILE="$TARGET/settings.local.json"
    local DM_SETTINGS="$SCRIPT_DIR/configs/settings.local.director-mode.json"

    if [ -f "$DM_SETTINGS" ] && command -v jq &>/dev/null; then
        if [ -f "$SETTINGS_FILE" ]; then
            # 合併 hooks 設定
            local tmp
            tmp=$(mktemp)
            jq -s '.[0] * {hooks: .[1].hooks} * {plansDirectory: .[1].plansDirectory}' \
                "$SETTINGS_FILE" "$DM_SETTINGS" > "$tmp" 2>/dev/null && mv "$tmp" "$SETTINGS_FILE"
            log "hooks 設定已合併到 settings.local.json"
        else
            cp "$DM_SETTINGS" "$SETTINGS_FILE"
            log "settings.local.json 已建立（含 hooks 設定）"
        fi
    else
        warn "無法自動合併 hooks 設定（需要 jq）"
        echo "    請手動將 configs/settings.local.director-mode.json 的 hooks 區塊"
        echo "    合併到 $SETTINGS_FILE"
    fi

    # Plans 目錄
    mkdir -p "$TARGET/plans"

    echo ""
    log "Director Mode 安裝完成！"
    echo ""
    echo "    已安裝到: $TARGET/"
    echo "    Skills:   $skill_count 個 slash 指令"
    echo "    Agents:   $agent_count 個專家 agent"
    echo "    Hooks:    $hook_count 個自動化腳本"
    echo ""
    echo "    輸入 / 查看所有可用指令"
}

# ─── Charge 專案 Skills ─────────────────────────
install_charge() {
    local PROJECT_DIR="${1:-.}"
    PROJECT_DIR=$(cd "$PROJECT_DIR" && pwd)
    local TARGET="$PROJECT_DIR/.claude"

    info "安裝 Charge 專案 Skills 到 $TARGET/ ..."
    mkdir -p "$TARGET/skills"

    local count=0
    for f in "$SCRIPT_DIR/project-skills/charge/"*.md; do
        if [ -f "$f" ]; then
            local fname
            fname=$(basename "$f")
            if [ "$fname" = "instructions.md" ]; then
                # instructions.md 放到 .claude/ 根目錄
                if [ -f "$TARGET/instructions.md" ]; then
                    warn "instructions.md 已存在，備份"
                    cp "$TARGET/instructions.md" "$TARGET/instructions.md.bak"
                fi
                cp "$f" "$TARGET/instructions.md"
                log "instructions.md"
            else
                cp "$f" "$TARGET/skills/"
                count=$((count + 1))
            fi
        fi
    done
    log "Charge Skills: $count 個"
}

# ─── 狀態列安裝 ─────────────────────────────────
install_statusline() {
    info "安裝狀態列..."
    if [ -f "$SCRIPT_DIR/statusline/statusline-command.sh" ]; then
        cp "$SCRIPT_DIR/statusline/statusline-command.sh" "$CLAUDE_DIR/statusline.sh"
        chmod +x "$CLAUDE_DIR/statusline.sh"
        log "statusline.sh"
    else
        warn "statusline-command.sh 不存在"
    fi
}

# ─── Plugins 安裝 ─────────────────────────────────
install_plugins() {
    info "安裝 plugins..."

    # 自訂 marketplace
    info "新增 claude-code-skills marketplace..."
    claude plugins marketplace add claude-code-skills --source github --repo alirezarezvani/claude-skills 2>/dev/null || warn "marketplace 可能已存在"

    # 官方 plugins
    for plugin in frontend-design zapier ralph-loop; do
        info "安裝 $plugin..."
        claude plugins install "${plugin}@claude-plugins-official" 2>/dev/null || warn "$plugin 可能已存在"
    done

    # everything-claude-code
    info "安裝 everything-claude-code..."
    claude plugins install everything-claude-code@everything-claude-code 2>/dev/null || warn "可能已存在"

    # claude-code-skills bundles
    local SKILL_BUNDLES=(
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

    for skill in "${SKILL_BUNDLES[@]}"; do
        info "安裝 $skill..."
        claude plugins install "${skill}@claude-code-skills" 2>/dev/null || warn "$skill 可能已存在"
    done

    log "所有 plugins 安裝完成"
}

# ─── MCP Servers 說明 ────────────────────────────
install_mcp() {
    info "MCP Servers 配置說明"
    echo ""
    warn "MCP Servers 需要手動設定，請參考 mcp-servers/SETUP.md"
    echo ""
    echo "  快速指令："
    echo "    # Isaac Sim MCP (需先 clone 並安裝)"
    echo "    claude mcp add isaac-sim -- uv run --directory ~/nvidia-isaac-mcp nvidia-isaac-mcp"
    echo ""
    echo "    # Isaac Sim MCP (輕量版)"
    echo "    claude mcp add isaacsim-mcp -- ~/isaacsim-mcp-venv/bin/isaac-mcp-server"
    echo ""
}

# ─── 自訂 Skills ─────────────────────────────────
install_custom_skills() {
    info "安裝自訂 skills..."

    # github-monitor
    if [ -d "$SCRIPT_DIR/skills/github-monitor" ]; then
        mkdir -p "$CLAWDBOT_DIR/skills/github-monitor"
        cp "$SCRIPT_DIR/skills/github-monitor/"* "$CLAWDBOT_DIR/skills/github-monitor/" 2>/dev/null || true
        chmod +x "$CLAWDBOT_DIR/skills/github-monitor/github_monitor.py" 2>/dev/null || true
        log "github-monitor skill"
    fi

    # OpenClaw plugin list
    if [ -f "$SCRIPT_DIR/openclaw/plugin_list.json" ]; then
        mkdir -p "$CLAWDBOT_DIR/skills"
        cp "$SCRIPT_DIR/openclaw/plugin_list.json" "$CLAWDBOT_DIR/skills/"
        log "OpenClaw plugin_list.json"
    fi

    log "自訂 skills 安裝完成"
}

# ─── 使用說明 ────────────────────────────────────
show_usage() {
    echo ""
    echo -e "${BOLD}Claude Code 完整環境安裝腳本${NC}"
    echo ""
    echo "用法: $0 <選項> [目錄]"
    echo ""
    echo "選項:"
    echo "  --all                全部安裝（全域配置 + Director Mode + Rules + Plugins）"
    echo "  --configs            安裝核心配置到 ~/.claude/"
    echo "  --rules              安裝全域 Rules 到 ~/.claude/rules/"
    echo "  --director-mode DIR  安裝 Director Mode 到指定專案的 .claude/"
    echo "  --plugins            安裝 Marketplace plugins"
    echo "  --statusline         安裝繁中狀態列"
    echo "  --charge DIR         安裝 Charge 專案 skills 到指定專案"
    echo "  --mcp                顯示 MCP Servers 設定說明"
    echo "  --custom-skills      安裝自訂 skills（github-monitor 等）"
    echo ""
    echo "範例:"
    echo "  $0 --all                          # 全部安裝"
    echo "  $0 --director-mode /home/aa/myproject  # 安裝 Director Mode"
    echo "  $0 --configs --rules              # 只裝全域配置和 rules"
    echo ""
}

# ─── 主程式 ───────────────────────────────────────
main() {
    echo ""
    echo "╔════════════════════════════════════════════╗"
    echo "║  Claude Code 完整環境安裝                    ║"
    echo "║  github.com/me0608623/claudecode            ║"
    echo "╚════════════════════════════════════════════╝"
    echo ""

    if [ $# -eq 0 ]; then
        show_usage
        exit 0
    fi

    check_prereqs

    while [ $# -gt 0 ]; do
        case "$1" in
            --all)
                install_configs
                install_statusline
                install_rules
                install_director_mode "."
                install_plugins
                install_custom_skills
                install_mcp
                shift
                ;;
            --configs)
                install_configs
                shift
                ;;
            --rules)
                install_rules
                shift
                ;;
            --director-mode)
                local dir="${2:-.}"
                install_director_mode "$dir"
                shift 2
                ;;
            --plugins)
                install_plugins
                shift
                ;;
            --statusline)
                install_statusline
                shift
                ;;
            --charge)
                local dir="${2:-.}"
                install_charge "$dir"
                shift 2
                ;;
            --mcp)
                install_mcp
                shift
                ;;
            --custom-skills)
                install_custom_skills
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                err "未知選項: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    echo ""
    log "安裝完成！重啟 Claude Code 以載入新配置。"
    info "詳細說明請參考 README.md 和 INVENTORY.md"
}

main "$@"
