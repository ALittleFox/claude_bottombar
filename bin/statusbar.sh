#!/usr/bin/env bash
set -euo pipefail

# --- Read stdin JSON -------------------------------------------------
INPUT_JSON=$(cat)

# --- Extract fields --------------------------------------------------
CWD=$(echo "$INPUT_JSON" | jq -r '.cwd // "?"')

# --- Extract git branch -------------------------------------------------
GIT_BRANCH=$(cd "$CWD" 2>/dev/null && git branch --show-current 2>/dev/null)

# Use only the project directory name
DIR_NAME=$(basename "$CWD")
TRANSCRIPT=$(echo "$INPUT_JSON" | jq -r '.transcript_path // ""')
TOK_IN=$(echo "$INPUT_JSON" | jq -r '.context_window.current_usage.input_tokens // 0')
TOK_TOTAL=$(echo "$INPUT_JSON" | jq -r '.context_window.context_window_size // 0')

# --- Detect active MCP servers from transcript -----------------------
MCP_SERVERS=""
if [[ -n "$TRANSCRIPT" && -f "$TRANSCRIPT" ]]; then
    MCP_SERVERS=$(tail -n 500 "$TRANSCRIPT" 2>/dev/null | jq -r '
        select(.type == "assistant")
        | (.message.content // [])[]
        | select(.type == "tool_use")
        | .name
        | select(startswith("mcp__"))
        | ltrimstr("mcp__")
        | split("__")[0]
        | if startswith("plugin_") then
            (split("_")[1:] | join("_"))
          else . end
    ' 2>/dev/null | sort -u | paste -sd "," -)
fi

# --- Format displays -------------------------------------------------
if [[ -z "$MCP_SERVERS" ]]; then
    if [[ -n "$TRANSCRIPT" && -f "$TRANSCRIPT" ]]; then
        MCP_DISPLAY="MCP: none"
    else
        MCP_DISPLAY="MCP: --"
    fi
else
    MCP_DISPLAY="MCP: $MCP_SERVERS"
fi

if [[ "$TOK_TOTAL" -gt 0 ]]; then
    TOK_DISPLAY="$(echo "scale=1; $TOK_IN/1000" | bc)K/$(echo "scale=0; $TOK_TOTAL/1000" | bc)K"
else
    TOK_DISPLAY="--"
fi

# Build directory display: dirname (git: branch)
if [[ -n "$GIT_BRANCH" ]]; then
    DIR_DISPLAY="${DIR_NAME} (git: ${GIT_BRANCH})"
else
    DIR_DISPLAY="${DIR_NAME}"
fi

# --- ANSI colors -----------------------------------------------------
DIM="\033[2m"
CYN="\033[36m"
GRN="\033[32m"
YLW="\033[33m"
RST="\033[0m"

# --- Output ----------------------------------------------------------
printf "${DIM}──${RST}  ${CYN}%s${RST}  ${GRN}%s${RST}  ${YLW}Tok: %s${RST}  ${DIM}──${RST}\n" \
    "$DIR_DISPLAY" "$MCP_DISPLAY" "$TOK_DISPLAY"
