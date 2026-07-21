# statusbar

Claude Code 原生状态栏插件，在终端底部持续显示当前项目目录、git 分支和活跃 MCP 服务器。

## 效果

```
──  cloude-plugin-info (git: main)  Tok: 12.3K/200K  ──
──  MCP: [ codegraph: ●, memory: ● ]                 ──
```

## 安装

```bash
# 软链接到 skills 目录（实时调试）
ln -s $(pwd) ~/.claude/skills/statusbar

# 写入 statusLine 配置
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

然后 `/reload-plugins`。

## 卸载

```bash
# 移除 statusLine
jq 'del(.statusLine)' ~/.claude/settings.json > ~/.claude/settings.json.tmp \
  && mv ~/.claude/settings.json.tmp ~/.claude/settings.json

# 移除插件
rm ~/.claude/skills/statusbar
```

## 结构

```
├── .claude-plugin/plugin.json
├── bin/statusbar.sh          # 核心脚本 (bash + jq)
├── hooks/hooks.json          # SessionStart 钩子
├── hooks/fix-statusline.sh   # 自动修正路径
├── skills/statusbar-plugin/  # 安装/卸载技能
└── .gitignore
```
