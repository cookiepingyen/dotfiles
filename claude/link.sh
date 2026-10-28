#!/usr/bin/env zsh
# Symlink Claude Code config from this repo into ~/.claude.
# Existing non-symlink files are moved to ~/.claude/backups/link-<timestamp>/ first.
set -euo pipefail

src=${0:A:h}
dest=$HOME/.claude
backup=$dest/backups/link-$(date +%Y%m%d%H%M%S)

link() {
  local from=$1 to=$2
  if [[ -L $to ]]; then
    rm $to
  elif [[ -e $to ]]; then
    mkdir -p $backup
    mv $to $backup/
    echo "backed up $to -> $backup/"
  fi
  ln -s $from $to
  echo "linked $to -> $from"
}

mkdir -p $dest/skills

for f in CLAUDE.md settings.json statusline.sh; do
  link $src/$f $dest/$f
done

for skill in $src/skills/*(/); do
  link $skill $dest/skills/${skill:t}
done
