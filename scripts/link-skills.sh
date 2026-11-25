#!/usr/bin/env bash
set -euo pipefail

# Links every skill under skills/ into the skill directories each harness
# reads:
#   - ~/.claude/skills: Claude Code
#   - ~/.agents/skills: Codex and other Agent Skills-compatible harnesses
#   - ~/.gemini/config/skills: Antigravity
# Each entry is a symlink into this repo, so a `git pull` keeps installed
# skills current. Re-run after adding, removing or renaming a skill.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
GEMINI_DEST="$HOME/.gemini/config/skills"
DESTS=("$HOME/.claude/skills" "$HOME/.agents/skills" "$GEMINI_DEST")

names=()
srcs=()
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  names+=("$(basename "$src")")
  srcs+=("$src")
done < <(find "$REPO/skills" -name SKILL.md -not -path '*/node_modules/*' -not -path '*/references/*' -print0)

for DEST in "${DESTS[@]}"; do
  # If $DEST is a symlink that resolves into this repo, we'd end up writing the
  # per-skill symlinks back into the repo's own skills/ tree. Detect and bail
  # out instead of polluting the working copy.
  if [ -L "$DEST" ]; then
    resolved="$(readlink -f "$DEST")"
    case "$resolved" in
      "$REPO"|"$REPO"/*)
        echo "error: $DEST is a symlink into this repo ($resolved)." >&2
        echo "Remove it (rm \"$DEST\") and re-run; the script will recreate it as a real dir." >&2
        exit 1
        ;;
    esac
  fi

  mkdir -p "$DEST"

  # Drop links into this repo that no longer resolve: skills moved or removed.
  find "$DEST" -maxdepth 1 -type l -lname "$REPO/*" ! -exec test -e {} \; -print -delete

  for i in "${!names[@]}"; do
    name="${names[$i]}"
    src="${srcs[$i]}"
    target="$DEST/$name"

    if [ "$DEST" = "$GEMINI_DEST" ] && { [ -e "$target" ] || [ -L "$target" ]; }; then
      if [ -L "$target" ]; then
        resolved_target="$(readlink -f "$target" 2>/dev/null || true)"
        case "$resolved_target" in
          "$REPO/skills/"*) ;;
          *)
            echo "warning: $target is not a skill link into this repo; leaving it untouched" >&2
            continue
            ;;
        esac
      else
        echo "warning: $target already exists and is not a symlink into this repo; leaving it untouched" >&2
        continue
      fi
    fi

    if [ -e "$target" ] && [ ! -L "$target" ]; then
      rm -rf "$target"
    fi

    ln -sfn "$src" "$target"
    echo "linked $name -> $src ($DEST)"
  done
done
