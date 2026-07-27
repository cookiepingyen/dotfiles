#!/bin/bash
input=$(cat)

DIR=$(echo "$input" | jq -r '.workspace.current_dir')
MODEL=$(echo "$input" | jq -r '.model.display_name')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
QUOTA=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

BRANCH=$(git -C "$DIR" --no-optional-locks branch --show-current 2>/dev/null)
DIR_NAME=$(basename "$DIR")
PONYTAIL_MODE=$(cat ~/.claude/.ponytail-active 2>/dev/null)

# ANSI color codes
YELLOW='\033[33m'    # Orange/Yellow for directory
MAGENTA='\033[95m'   # Magenta/Purple for model
CYAN='\033[36m'      # Cyan for ponytail mode
RESET='\033[0m'

# Line 1: Directory | Branch | Ponytail mode (directory in yellow)
LINE1="${YELLOW}📁 ${DIR_NAME}${RESET} | 🌿 ${BRANCH}"
if [ -n "$PONYTAIL_MODE" ]; then
    LINE1="$LINE1 | ${CYAN}🐴 ponytail:${PONYTAIL_MODE}${RESET}"
fi
echo -e "$LINE1"

# Line 2: Model | Quota | Context (model in magenta)
LINE2="${MAGENTA}⚡ ${MODEL}${RESET}"

# Show quota if available
if [ -n "$QUOTA" ]; then
    LINE2="$LINE2 | 📊 $(printf '%.0f' "$QUOTA")% quota"
fi

LINE2="$LINE2 | 📝 ${PCT}% ctx"

echo -e "$LINE2"
