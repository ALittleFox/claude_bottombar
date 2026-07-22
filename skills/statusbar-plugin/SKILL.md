---
name: statusbar-plugin
description: Install, configure, or uninstall the claude_bottombar status line plugin.
---

# Status Bar Plugin (claude_bottombar)

A Claude Code status bar showing project directory, git branch, token usage, model name, MCP servers, and active LSP servers.

## Install

1. Verify the plugin is in place: `ls ~/.claude/skills/claude_bottombar/bin/statusbar.sh`
2. Read `~/.claude/settings.json`
3. Add the `statusLine` field:

```json
"statusLine": {
  "type": "command",
  "command": "<path>/bin/statusbar.sh",
  "padding": 1,
  "refreshInterval": 30
}
```

Replace `<path>` with the absolute path from step 1.

4. Write the updated JSON and run `/reload-plugins`.

## Uninstall

1. Read `~/.claude/settings.json`
2. Remove `statusLine` with `jq 'del(.statusLine)'` and write back
3. Run `/plugin uninstall claude_bottombar`

**Important**: Remove statusLine from settings BEFORE uninstalling, otherwise a zombie entry remains.
