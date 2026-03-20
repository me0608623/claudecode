#!/usr/bin/env bash
# Claude Code statusLine command — 繁體中文標籤版
# 參考格式：sirmalloc/ccstatusline

input=$(cat)

# --- 基本資訊 ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -z "$cwd" ] && cwd=$(pwd)
# 將 home 目錄縮寫為 ~
home_dir="$HOME"
short_cwd="${cwd/#$home_dir/\~}"

model=$(echo "$input" | jq -r '.model.display_name // empty')
session=$(echo "$input" | jq -r '.session_name // empty')
version=$(echo "$input" | jq -r '.version // empty')

# --- 脈絡視窗 ---
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# --- 速率限制 ---
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# --- Vim 模式 ---
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')

# --- Git 分支（跳過鎖定） ---
git_branch=""
if [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# --- 顏色定義 ---
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
# 前景色
C_CYAN='\033[36m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
C_BLUE='\033[34m'
C_MAGENTA='\033[35m'
C_WHITE='\033[37m'

# --- 輸出組裝 ---
parts=()

# 目錄（藍色）
parts+=("$(printf "${BOLD}${C_BLUE}%s${RESET}" "$short_cwd")")

# Git 分支（綠色）
if [ -n "$git_branch" ]; then
    parts+=("$(printf "${C_GREEN}分支:${RESET}${C_GREEN}%s${RESET}" "$git_branch")")
fi

# 模型（青色）
if [ -n "$model" ]; then
    parts+=("$(printf "${C_CYAN}模型:${RESET}%s" "$model")")
fi

# 脈絡使用率
if [ -n "$used" ]; then
    used_int=$(printf '%.0f' "$used")
    if [ "$used_int" -ge 80 ]; then
        ctx_color="${C_RED}"
    elif [ "$used_int" -ge 50 ]; then
        ctx_color="${C_YELLOW}"
    else
        ctx_color="${C_GREEN}"
    fi
    parts+=("$(printf "${ctx_color}脈絡:${used_int}%%${RESET}")")
fi

# 速率限制
rate_parts=""
if [ -n "$five_pct" ]; then
    five_int=$(printf '%.0f' "$five_pct")
    rate_parts="5時:${five_int}%"
fi
if [ -n "$week_pct" ]; then
    week_int=$(printf '%.0f' "$week_pct")
    [ -n "$rate_parts" ] && rate_parts="${rate_parts} "
    rate_parts="${rate_parts}週:${week_int}%"
fi
if [ -n "$rate_parts" ]; then
    parts+=("$(printf "${C_MAGENTA}限額:${RESET}${C_MAGENTA}%s${RESET}" "$rate_parts")")
fi

# Vim 模式
if [ -n "$vim_mode" ]; then
    case "$vim_mode" in
        INSERT)  vim_color="${C_GREEN}"  ;;
        NORMAL)  vim_color="${C_YELLOW}" ;;
        *)       vim_color="${C_WHITE}"  ;;
    esac
    parts+=("$(printf "${vim_color}[%s]${RESET}" "$vim_mode")")
fi

# 會話名稱（若有）
if [ -n "$session" ]; then
    parts+=("$(printf "${DIM}會話:${session}${RESET}")")
fi

# 版本（若有，暗色）
if [ -n "$version" ]; then
    parts+=("$(printf "${DIM}v%s${RESET}" "$version")")
fi

# 用空格連接所有部分
output=""
for part in "${parts[@]}"; do
    [ -n "$output" ] && output="${output} | "
    output="${output}${part}"
done

printf '%s\n' "$output"
