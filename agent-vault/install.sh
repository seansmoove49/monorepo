#!/usr/bin/env bash
# Link agent-vault files into place. Safe to re-run.
#   ./install.sh            apply
#   ./install.sh --dry-run  show what would change
set -euo pipefail

VAULT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE="$HOME/.claude"
AGENTS="$HOME/.agents"
STAMP="$(date +%Y%m%d-%H%M%S)"
DRY=0
[[ "${1:-}" == "--dry-run" ]] && DRY=1

run() { if (( DRY )); then echo "  would: $*"; else "$@"; fi; }

# link SRC DEST: symlink DEST -> SRC, backing up anything else already there.
link() {
  local src="$1" dest="$2"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "ok      $dest"
    return
  fi
  if [[ -e "$dest" || -L "$dest" ]]; then
    echo "backup  $dest -> $dest.backup-$STAMP"
    run mv "$dest" "$dest.backup-$STAMP"
  fi
  echo "link    $dest -> $src"
  run mkdir -p "$(dirname "$dest")"
  run ln -s "$src" "$dest"
}

echo "== skills"
for skill in "$VAULT"/skills/*/; do
  name="$(basename "$skill")"
  link "${skill%/}" "$CLAUDE/skills/$name"
  # Codex reads ~/.agents/skills. Only link there if the folder exists.
  [[ -d "$AGENTS/skills" ]] && link "${skill%/}" "$AGENTS/skills/$name"
done

echo "== claude"
link "$VAULT/claude/CLAUDE.md" "$CLAUDE/CLAUDE.md"
# Linked per file so runtime files (e.g. hook caches) stay out of the vault.
for dir in hooks scripts agents commands; do
  [[ -d "$VAULT/claude/$dir" ]] || continue
  for f in "$VAULT/claude/$dir"/*; do
    [[ -f "$f" ]] && link "$f" "$CLAUDE/$dir/$(basename "$f")"
  done
done

# settings.json is rewritten by Claude Code, so merge into it instead of linking.
base="$VAULT/claude/settings.base.json"
if [[ -f "$base" ]]; then
  echo "== settings"
  if (( DRY )); then
    echo "  would: merge $base into $CLAUDE/settings.json"
  else
    cp "$CLAUDE/settings.json" "$CLAUDE/settings.json.backup-$STAMP"
    # `*` replaces arrays, so union permissions.allow to keep rules added locally.
    jq -s '.[0] as $cur | .[1] as $base | ($cur * $base)
      | if $base.permissions.allow then
          .permissions.allow = ((($cur.permissions.allow // []) + $base.permissions.allow) | unique)
        else . end' "$CLAUDE/settings.json" "$base" > "$CLAUDE/settings.json.tmp"
    mv "$CLAUDE/settings.json.tmp" "$CLAUDE/settings.json"
    echo "merged  $base"
  fi
fi
