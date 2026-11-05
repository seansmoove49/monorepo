#!/bin/sh
# Status line: current directory, green (#a6e3a1, matches starship username), current folder bold
dir=$(jq -r .workspace.current_dir | sed "s|^$HOME|~|")
parent=${dir%/*}
base=${dir##*/}
if [ "$parent" = "$dir" ]; then
  printf '\033[1;38;2;166;227;161m%s\033[0m' "$dir"
else
  printf '\033[38;2;166;227;161m%s/\033[1;38;2;166;227;161m%s\033[0m' "$parent" "$base"
fi
