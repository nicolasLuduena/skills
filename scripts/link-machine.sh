#!/usr/bin/env bash
set -euo pipefail

# Links the machine config under machine/ into the places each tool reads:
#   - machine/firstmate/**            -> ~/firstmate/** (or $FM_HOME/**)
#   - machine/no-mistakes/config.yaml -> ~/.no-mistakes/config.yaml (or $NM_HOME/)
# Each entry is a symlink into this repo, so a `git pull` keeps the config
# current and an edit a tool makes lands here, ready to commit. A real file
# already at a target is moved aside to <target>.bak first: if a tool replaced
# a link with its own file, diff the .bak against this repo's copy.
# Safe to run again. machine/README.md walks through a new machine.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FM="${FM_HOME:-$HOME/firstmate}"
NM="${NM_HOME:-$HOME/.no-mistakes}"

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

if [ -d "$FM" ]; then
  while IFS= read -r -d '' src; do
    link "$src" "$FM/${src#"$REPO/machine/firstmate/"}"
  done < <(find "$REPO/machine/firstmate" -type f -print0)
else
  echo "skipped firstmate: no $FM (clone https://github.com/kunchenguid/firstmate there first)" >&2
fi

link "$REPO/machine/no-mistakes/config.yaml" "$NM/config.yaml"
