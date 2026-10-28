## Skills

建新 skill 時，建在 dotfiles 的 `claude/skills/<name>/`，
再 `ln -s` 到 `~/.claude/skills/<name>`。不要直接建在 `~/.claude/skills/`。

dotfiles 的位置：
- container（e2）：`/proj/dotfiles`
- Mac host：`~/proj/dotfiles`（可直接跑 `claude/link.sh` 建 symlink）
