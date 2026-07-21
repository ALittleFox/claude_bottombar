# claude_bottombar

A zero-dependency Claude Code status bar — shows project, git branch, token usage, MCP servers, and active LSP servers at a glance.

## Preview

```
✻ Worked for 34s

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
❯ commit this
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   ──  cloude-plugin-info (git: main)  Tok: 0K/1000K  ──
   ──  MCP: [ codegraph: ○, Figma Desktop: ○ ]  ──
   ──  LSP: [ typescript ]                      ──
  ⏵⏵ accept edits on (shift+tab to cycle)
```

- **Line 1**: project name, git branch, token usage
- **Line 2**: MCP servers, `●` called this session / `○` idle
- **Line 3**: LSP servers active for the current project (auto-detected by file types; hidden when no match)

## How It Works

- Reads status line JSON from stdin (provided by Claude Code)
- Scans `~/.claude.json` + `<cwd>/.mcp.json` for MCP servers
- Cross-references transcript JSONL to mark which MCP servers have been called
- Detects LSP servers from enabled plugins, filters by project file types
- Outputs ANSI-colored lines

## Requirements

- `bash`
- `jq` — install via:

| Platform | Command |
|----------|---------|
| macOS | `brew install jq`, or Xcode CLI (ships `/usr/bin/jq`) |
| Linux (Debian/Ubuntu) | `sudo apt install jq` |
| Linux (Arch) | `sudo pacman -S jq` |
| Linux (Fedora) | `sudo dnf install jq` |
| Windows | `scoop install jq` or `choco install jq` |

## Install

### Method 1: Manual Clone

```bash
git clone https://github.com/ALittleFox/claude_bottombar.git /path/to/claude_bottombar
ln -s /path/to/claude_bottombar ~/.claude/skills/claude_bottombar

jq '. + {
  statusLine: {
    type: "command",
    command: "/path/to/claude_bottombar/bin/statusbar.sh",
    padding: 1,
    refreshInterval: 30
  }
}' ~/.claude/settings.json > ~/.claude/settings.json.tmp \
  && mv ~/.claude/settings.json.tmp ~/.claude/settings.json

/reload-plugins
```

### Method 2: Copy to Skills Directory

```bash
git clone https://github.com/ALittleFox/claude_bottombar.git
cp -r claude_bottombar ~/.claude/skills/claude_bottombar

jq '. + {
  statusLine: {
    type: "command",
    command: "'$HOME'/.claude/skills/claude_bottombar/bin/statusbar.sh",
    padding: 1,
    refreshInterval: 30
  }
}' ~/.claude/settings.json > ~/.claude/settings.json.tmp \
  && mv ~/.claude/settings.json.tmp ~/.claude/settings.json

/reload-plugins
```

### Method 3: Marketplace

```bash
/plugin marketplace add https://github.com/ALittleFox/claude_bottombar.git
/plugin install claude_bottombar@claude_bottombar
```

Or from Claude Plugin Hub:

```bash
npx claudepluginhub alittlefox/claude_bottombar
```

Or manually add ClaudePluginHub marketplace:

```bash
/plugin marketplace add https://www.claudepluginhub.com/api/plugins/alittlefox-claude-bottombar/marketplace.json
/plugin install alittlefox-claude-bottombar@cpd-alittlefox-claude-bottombar
```

## Uninstall

```bash
jq 'del(.statusLine)' ~/.claude/settings.json > ~/.claude/settings.json.tmp \
  && mv ~/.claude/settings.json.tmp ~/.claude/settings.json
rm ~/.claude/skills/claude_bottombar
```

## Structure

```
.claude-plugin/plugin.json    # manifest
bin/statusbar.sh              # core script (bash + jq)
hooks/hooks.json              # SessionStart → auto fix path
hooks/fix-statusline.sh       # rewrites statusLine to absolute path
skills/statusbar-plugin/      # install / uninstall skill
```
