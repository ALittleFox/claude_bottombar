#!/usr/bin/env bash
# Fix statusLine config in ~/.claude/settings.json on each session start.
# ${CLAUDE_PLUGIN_ROOT} resolves at hook execution time — this works around
# the limitation that it does NOT expand in statusLine.command itself.
set -euo pipefail

SETTINGS="$HOME/.claude/settings.json"
SCRIPT_PATH="${CLAUDE_PLUGIN_ROOT}/bin/statusbar.sh"

# Create settings.json if missing
if [[ ! -f "$SETTINGS" ]]; then
    echo '{}' > "$SETTINGS"
fi

# Idempotent: only rewrite if the path has changed
CURRENT=$(jq -r '.statusLine.command // ""' "$SETTINGS" 2>/dev/null)
if [[ "$CURRENT" != "$SCRIPT_PATH" ]]; then
    jq --arg path "$SCRIPT_PATH" \
        '. + {statusLine: {type: "command", command: $path, padding: 1, refreshInterval: 1}}' \
        "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"
fi
