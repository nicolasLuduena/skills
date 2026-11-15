#!/usr/bin/env bash
set -euo pipefail

# Links machine/opencode/commands/* into ~/.config/opencode/commands/, as
# symlinks into this repo, so a `git pull` keeps them current. A real file
# already at a target is moved aside to <target>.bak first. Safe to run again.

REPO="$(cd "$(dirname "$0")/.." && pwd)"

link() {
  local src="$1" target="$2"
  mkdir -p "$(dirname "$target")"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$target.bak"
    echo "moved $target aside to $target.bak"
  fi
  ln -sfn "$src" "$target"
  echo "linked $target -> $src"
}

for src in "$REPO"/machine/opencode/commands/*; do
  link "$src" "$HOME/.config/opencode/commands/$(basename "$src")"
done
