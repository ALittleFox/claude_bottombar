# claude_bottombar

零依赖 Claude Code 状态栏插件 — 一目了然显示项目目录、git 分支、Token 用量和 MCP 服务器。

## 效果预览

```
✻ Worked for 34s

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
❯ commit this
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   ──  cloude-plugin-info (git: main)  Tok: 0K/1000K  ──
   ──  MCP: [ codegraph: ○, Figma Desktop: ○ ]  ──
  ⏵⏵ accept edits on (shift+tab to cycle)
```

- `●` 绿色 = 本会话已调用，`○` 灰色 = 已配置未调用
- MCP 列表从配置文件即时读取，首次打开即显示

## 工作原理

- 从 stdin 读取 Claude Code 提供的 status line JSON
- 扫描 `~/.claude.json` + `<cwd>/.mcp.json` 获取已配置的 MCP 服务器
- 对照 transcript JSONL 标记哪些服务器已被调用
- 输出两行 ANSI 彩色文本

## 环境要求

- `bash`
- `jq` — 各平台安装命令：

| 平台 | 命令 |
|------|------|
| macOS | `brew install jq`，或装 Xcode CLI 自带 `/usr/bin/jq` |
| Linux (Debian/Ubuntu) | `sudo apt install jq` |
| Linux (Arch) | `sudo pacman -S jq` |
| Linux (Fedora) | `sudo dnf install jq` |
| Windows | `scoop install jq` 或 `choco install jq` |

## 安装

### 方式一：手动克隆

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

### 方式二：复制到 Skills 目录

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

### 方式三：Marketplace

```bash
/plugin marketplace add https://github.com/ALittleFox/claude_bottombar.git
/plugin install claude_bottombar@<marketplace-name>
```

## 卸载

```bash
jq 'del(.statusLine)' ~/.claude/settings.json > ~/.claude/settings.json.tmp \
  && mv ~/.claude/settings.json.tmp ~/.claude/settings.json
rm ~/.claude/skills/claude_bottombar
```

## 目录结构

```
.claude-plugin/plugin.json    # 插件清单
bin/statusbar.sh              # 核心脚本 (bash + jq)
hooks/hooks.json              # SessionStart → 自动修正路径
hooks/fix-statusline.sh       # 写入 statusLine 绝对路径
skills/statusbar-plugin/     # 安装/卸载技能
```
