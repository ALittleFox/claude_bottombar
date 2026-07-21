#!/usr/bin/env bash
set -euo pipefail

# --- Read stdin JSON -------------------------------------------------
INPUT_JSON=$(cat)

# --- Extract fields --------------------------------------------------
CWD=$(echo "$INPUT_JSON" | jq -r '.cwd // "?"')

# --- Extract git branch -------------------------------------------------
GIT_BRANCH=$(cd "$CWD" 2>/dev/null && git branch --show-current 2>/dev/null || true)

# Use only the project directory name
DIR_NAME=$(basename "$CWD")
TRANSCRIPT=$(echo "$INPUT_JSON" | jq -r '.transcript_path // ""')
TOK_IN=$(echo "$INPUT_JSON" | jq -r '.context_window.current_usage.input_tokens // 0')
TOK_TOTAL=$(echo "$INPUT_JSON" | jq -r '.context_window.context_window_size // 0')

# --- ANSI colors (define early, used in MCP formatting) ---------------
DIM=$'\033[2m'
CYN=$'\033[36m'
GRN=$'\033[32m'
YLW=$'\033[33m'
RST=$'\033[0m'

# --- Collect configured MCP servers from config files -----------------
MCP_CONFIGURED=""
# User-level MCPs (~/.claude.json)
if [[ -f "$HOME/.claude.json" ]]; then
    MCP_CONFIGURED+=$(jq -r '.mcpServers // {} | keys[]' "$HOME/.claude.json" 2>/dev/null)
    MCP_CONFIGURED+=$'\n'
fi
# Project-level MCPs (<cwd>/.mcp.json)
if [[ -f "$CWD/.mcp.json" ]]; then
    MCP_CONFIGURED+=$(jq -r '.mcpServers // {} | keys[]' "$CWD/.mcp.json" 2>/dev/null)
    MCP_CONFIGURED+=$'\n'
fi
# Deduplicate configured servers
MCP_CONFIGURED=$(echo "$MCP_CONFIGURED" | sed '/^$/d' | sort -u)

# --- Detect called MCP servers from transcript ------------------------
MCP_CALLED=""
if [[ -n "$TRANSCRIPT" && -f "$TRANSCRIPT" ]]; then
    MCP_CALLED=$(tail -n 500 "$TRANSCRIPT" 2>/dev/null | jq -r '
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
    ' 2>/dev/null | sort -u)
fi

# --- Format MCP display ------------------------------------------------
if [[ -z "$MCP_CONFIGURED" ]]; then
    MCP_DISPLAY="MCP: none"
else
    MCP_ITEMS=""
    while IFS= read -r server; do
        [[ -z "$server" ]] && continue
        # Green dot = called in this session, dim dot = connected but unused
        if echo "$MCP_CALLED" | grep -qxF "$server" 2>/dev/null; then
            STATUS="${GRN}●${RST}"
        else
            STATUS="${DIM}○${RST}"
        fi
        MCP_ITEMS+="${GRN}${server}${RST}: ${STATUS}, "
    done <<< "$MCP_CONFIGURED"
    MCP_ITEMS=$(echo "$MCP_ITEMS" | sed 's/, $//')
    MCP_DISPLAY="MCP: [ ${MCP_ITEMS} ]"
fi

if [[ "$TOK_TOTAL" -gt 0 ]]; then
    TOK_DISPLAY="$(echo "scale=1; $TOK_IN/1000" | bc)K/$(echo "scale=0; $TOK_TOTAL/1000" | bc)K"
else
    TOK_DISPLAY="--"
fi

# --- Collect configured LSP servers from enabledPlugins -----------------
LSP_CONFIGURED=""
if [[ -f "$HOME/.claude/settings.json" ]]; then
    LSP_CONFIGURED=$(jq -r '.enabledPlugins // {} | keys[] | select(contains("lsp"))' \
        "$HOME/.claude/settings.json" 2>/dev/null | sed 's/-lsp@.*//' | sort -u)
fi

# --- Filter LSP servers active for current project -----------------------
LSP_EXTENSIONS() {
    case "$1" in
        clangd)    echo "c h cpp hpp cc cxx" ;;
        pyright)   echo "py pyi" ;;
        typescript) echo "ts tsx js jsx" ;;
        *)         echo "" ;;
    esac
}
LSP_PROJECT_ACTIVE=""
if [[ -n "$LSP_CONFIGURED" ]]; then
    while IFS= read -r server; do
        [[ -z "$server" ]] && continue
        exts=$(LSP_EXTENSIONS "$server")
        if [[ -n "$exts" ]]; then
            # Build find pattern: -name "*.c" -o -name "*.h" ...
            find_args=""
            for ext in $exts; do
                find_args+=" -name \"*.$ext\" -o"
            done
            find_args="${find_args% -o}"  # strip trailing -o
            if eval "find \"$CWD\" -maxdepth 3 -type f $find_args 2>/dev/null | head -1 | grep -q ."; then
                LSP_PROJECT_ACTIVE+="${server}"$'\n'
            fi
        fi
    done <<< "$LSP_CONFIGURED"
    LSP_PROJECT_ACTIVE=$(echo "$LSP_PROJECT_ACTIVE" | sed '/^$/d' | sort -u)
fi

# --- Format LSP display --------------------------------------------------
LSP_DISPLAY=""
if [[ -n "$LSP_PROJECT_ACTIVE" ]]; then
    LSP_ITEMS=$(echo "$LSP_PROJECT_ACTIVE" | sed 's/^/'"${GRN}"'/; s/$/'"${RST}"'/' | paste -sd ',' - | sed 's/,/'"${RST}"', '"${GRN}"'/g')
    LSP_DISPLAY="LSP: [ ${LSP_ITEMS} ]"
fi

# Build directory display: dirname (git: branch)
if [[ -n "$GIT_BRANCH" ]]; then
    DIR_DISPLAY="${DIR_NAME} (git: ${GIT_BRANCH})"
else
    DIR_DISPLAY="${DIR_NAME}"
fi

# --- Output (dir, mcp, lsp) ------------------------------------------
printf "${DIM}──${RST}  ${CYN}%-30s${RST}  ${YLW}Tok: %s${RST}  ${DIM}──${RST}\n" \
    "$DIR_DISPLAY" "$TOK_DISPLAY"
printf "${DIM}──${RST}  %s  ${DIM}──${RST}\n" \
    "$MCP_DISPLAY"
if [[ -n "$LSP_DISPLAY" ]]; then
    printf "${DIM}──${RST}  %s  ${DIM}──${RST}\n" \
        "$LSP_DISPLAY"
fi
