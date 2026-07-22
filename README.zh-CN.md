# claude_bottombar

零依赖 Claude Code 状态栏插件 — 一目了然显示项目目录、git 分支、Token 用量、MCP 服务器和 LSP 服务器。

## 效果预览


```
✻ Worked for 34s

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
❯ commit this
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   ──  cloude-plugin-info (git: main)  Tok: 20%  ──
   ──  MCP: [ codegraph: ○, Figma Desktop: ○ ]  ──
   ──  LSP: [ typescript ]                      ──
  ⏵⏵ accept edits on (shift+tab to cycle)
```


- **第一行**：项目名、git 分支、Token 用量
- **第二行**：MCP 服务器列表，`●` 已调用，`○` 未调用
- **第三行**：当前项目激活的 LSP 服务器（根据文件类型自动检测，无匹配时隐藏）

## 工作原理

- 从 stdin 读取 Claude Code 提供的 status line JSON
- 扫描 `~/.claude.json` + `<cwd>/.mcp.json` 获取已配置的 MCP 服务器
- 对照 transcript JSONL 标记哪些 MCP 已被调用
- 从 enabledPlugins 检测 LSP 插件，按项目文件类型过滤
- 输出 ANSI 彩色文本

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

> **为什么需要 `jq` 步骤？** Claude Code 插件无法在清单中声明 `statusLine`，必须直接写入 `~/.claude/settings.json`。下方 jq 命令会完成这个操作，`/reload-plugins` 后状态栏即可显示。如果跳过，SessionStart 钩子会在下次 Claude Code 重启时自动补上。

安装后执行 `/reload-plugins` 激活。

### 方式一：手动克隆

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

### 方式二：复制到 Skills 目录

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

### 方式三：Marketplace

> **已知问题**：Claude Code 当前从 marketplace 克隆时使用 SSH 而非 HTTPS，可能因 host key 验证失败而无法安装。这是[已知 Bug](https://github.com/anthropics/claude-code/issues/26588)。
>
> **临时方案** — 强制 Git 对 GitHub 使用 HTTPS：
> ```bash
> git config --global url."https://github.com/".insteadOf "git@github.com:"
> ```
> ⚠️ **恢复命令**（还原 SSH）：
> ```bash
> git config --global --unset url."https://github.com/".insteadOf
> ```

从 GitHub 安装：

```bash
/plugin marketplace add https://github.com/ALittleFox/claude_bottombar.git
/plugin install claude_bottombar@claude_bottombar
```

通过 Claude Plugin Hub：

```bash
npx claudepluginhub alittlefox/claude_bottombar
```

或手动添加：

```bash
/plugin marketplace add https://www.claudepluginhub.com/api/plugins/alittlefox-claude-bottombar/marketplace.json
/plugin install alittlefox-claude-bottombar@cpd-alittlefox-claude-bottombar
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
skills/statusbar-plugin/      # 安装/卸载技能
```
