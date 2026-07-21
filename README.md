# claude_bottombar

A zero-dependency Claude Code status bar — shows project, git branch, token usage, and MCP servers at a glance.

## Preview

```
✻ Worked for 34s

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
❯ commit this
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   ──  cloude-plugin-info (git: main)  Tok: 0K/1000K  ──
   ──  MCP: [ codegraph: ○, Figma Desktop: ○ ]  ──
  ⏵⏵ accept edits on (shift+tab to cycle)
```

- `●` green = MCP called this session, `○` dim = configured but idle
- MCP list is read from config files immediately — no warm-up needed

## How It Works

- Reads status line JSON from stdin (provided by Claude Code)
- Scans `~/.claude.json` + `<cwd>/.mcp.json` for configured MCP servers
- Cross-references transcript JSONL to mark which servers have been called
- Outputs two ANSI-colored lines

## Requirements

- `bash`
- `jq` (bundled with macOS)

## Install

```bash
# Symlink into skills directory
ln -s "$(pwd)" ~/.claude/skills/claude_bottombar

# Register as status line provider
jq '. + {
  statusLine: {
    type: "command",
    command: "'$(pwd)'/bin/statusbar.sh",
    padding: 1,
    refreshInterval: 30
  }
}' ~/.claude/settings.json > ~/.claude/settings.json.tmp \
  && mv ~/.claude/settings.json.tmp ~/.claude/settings.json
```

Then run `/reload-plugins`.

## Uninstall

```bash
jq 'del(.statusLine)' ~/.claude/settings.json > ~/.claude/settings.json.tmp \
  && mv ~/.claude/settings.json.tmp ~/.claude/settings.json
rm ~/.claude/skills/claude_bottombar
```

## Remote Install

```bash
git clone https://github.com/ALittleFox/claude_bottombar.git ~/.claude/skills/claude_bottombar
# then follow the install steps above
```

## Structure

```
.claude-plugin/plugin.json    # manifest
bin/statusbar.sh              # core script (bash + jq)
hooks/hooks.json              # SessionStart → auto fix path
hooks/fix-statusline.sh       # rewrites statusLine to absolute path
skills/statusbar-plugin/      # install / uninstall skill
```
