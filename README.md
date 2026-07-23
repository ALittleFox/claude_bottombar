# claude_bottombar

A zero-dependency Claude Code status bar — shows project, git branch, token usage, MCP servers, and active LSP servers at a glance.

## Preview

```
✻ Worked for 34s

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
❯ commit this
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 /\_/\   ──  cloude-plugin-info (git: main)  Opus 4.6  Tok: 20%  ──
( o.o )  ──  MCP: [ codegraph: ○, Figma Desktop: ○ ]          ──
 > ^ <   ──  LSP: [ typescript ]                               ──
```

There's a little cat waiting for you at the bottom of the terminal.

- **Line 1**: project name, git branch, model, token usage — plus cat ears
- **Line 2**: MCP servers, `●` called / `○` idle — plus cat face
- **Line 3**: LSP servers active for the current project — plus cat body

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

> **Why the `jq` step?** Claude Code plugins cannot declare `statusLine` in their manifest — it must be written directly to `~/.claude/settings.json`. The `jq` command below does this so the status bar appears immediately after `/reload-plugins`. If you skip it, the SessionStart hook will auto-configure it on next Claude Code restart.

After installation, run `/reload-plugins` to activate.

### Method 1: Manual Clone

```bash
git clone https://github.com/ALittleFox/claude_bottombar.git /path/to/claude_bottombar
ln -s /path/to/claude_bottombar ~/.claude/skills/claude_bottombar

jq '. + {
  statusLine: {
    type: "command",
    command: "/path/to/claude_bottombar/bin/statusbar.sh",
    padding: 1,
    refreshInterval: 10
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
    refreshInterval: 10
  }
}' ~/.claude/settings.json > ~/.claude/settings.json.tmp \
  && mv ~/.claude/settings.json.tmp ~/.claude/settings.json

/reload-plugins
```

### Method 3: Marketplace

> **Known issue**: Claude Code currently uses SSH instead of HTTPS when cloning from marketplace, which may fail with host key errors. This is a [known bug](https://github.com/anthropics/claude-code/issues/26588).
>
> **Workaround** — force Git to use HTTPS for GitHub:
> ```bash
> git config --global url."https://github.com/".insteadOf "git@github.com:"
> ```
> ⚠️ **Revert** (restores SSH):
> ```bash
> git config --global --unset url."https://github.com/".insteadOf
> ```

From GitHub:

```bash
/plugin marketplace add https://github.com/ALittleFox/claude_bottombar.git
/plugin install claude_bottombar@claude_bottombar
```

Via Claude Plugin Hub:

```bash
npx claudepluginhub alittlefox/claude_bottombar
```

Or manually:

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
