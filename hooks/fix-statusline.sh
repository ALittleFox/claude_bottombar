#!/usr/bin/env bash
set -euo pipefail

SETTINGS="$HOME/.claude/settings.json"
SCRIPT_PATH="${CLAUDE_PLUGIN_ROOT}/bin/statusbar.sh"

# Ensure settings.json exists
if [[ ! -f "$SETTINGS" ]]; then
    echo '{}' > "$SETTINGS"
fi

# Write statusLine config pointing to our script (idempotent)
CURRENT=$(jq -r '.statusLine.command // ""' "$SETTINGS" 2>/dev/null)
if [[ "$CURRENT" != "$SCRIPT_PATH" ]]; then
    jq --arg path "$SCRIPT_PATH" \
        '. + {statusLine: {type: "command", command: $path, padding: 1, refreshInterval: 10}}' \
        "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"
fi
