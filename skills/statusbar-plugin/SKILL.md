---
name: statusbar-plugin
description: Install, configure, or uninstall the statusbar plugin status line.
---

# Status Bar Plugin

A minimal Claude Code status bar showing current working directory and active MCP servers.

## Install

To install the status bar:

1. Run `ls ~/.claude/plugins/statusbar/bin/statusbar.sh` to verify the plugin files are in place.
2. Read `~/.claude/settings.json`.
3. Add or update the `statusLine` field:

```json
"statusLine": {
  "type": "command",
  "command": "<absolute-path>/bin/statusbar.sh",
  "padding": 1
}
```

Replace `<absolute-path>` with the actual install path (typically `~/.claude/plugins/statusbar`). Use the full absolute path, not `~`.

4. Write the updated JSON back to `~/.claude/settings.json`.
5. On the next SessionStart, the hook will verify and fix the path automatically.
6. The status bar will appear at the bottom of Claude Code after the next assistant response.

## Uninstall

To uninstall the status bar:

1. Read `~/.claude/settings.json`.
2. Remove the `statusLine` key entirely using `jq 'del(.statusLine)'`.
3. Write the updated JSON back.
4. Run `/plugin uninstall statusbar` to remove the plugin files.

**Important**: Always remove the statusLine from settings BEFORE running `/plugin uninstall`, otherwise a zombie statusLine entry will remain in your settings.
