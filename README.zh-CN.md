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
- `jq`（macOS 内置）

## 安装

```bash
# 软链接到 skills 目录
ln -s "$(pwd)" ~/.claude/skills/claude_bottombar

# 注册为 status line
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

然后执行 `/reload-plugins`。

## 卸载

```bash
jq 'del(.statusLine)' ~/.claude/settings.json > ~/.claude/settings.json.tmp \
  && mv ~/.claude/settings.json.tmp ~/.claude/settings.json
rm ~/.claude/skills/claude_bottombar
```

## 安装步骤

```bash
git clone https://github.com/ALittleFox/claude_bottombar.git ~/.claude/skills/claude_bottombar
# 然后按上方安装步骤配置
```

## 目录结构

```
.claude-plugin/plugin.json    # 插件清单
bin/statusbar.sh              # 核心脚本 (bash + jq)
hooks/hooks.json              # SessionStart → 自动修正路径
hooks/fix-statusline.sh       # 写入 statusLine 绝对路径
skills/statusbar-plugin/     # 安装/卸载技能
```
